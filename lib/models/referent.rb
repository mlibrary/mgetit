require "i18n"
require "truncate_to_db_limit"

# Note: There are a few actual attributes stored as Columns in referent --
# these were originally used for identifying a Referent identifying the
# 'same thing' as an incoming OpenURL, to re-use it. But we don't re-use
# cached referents anymore. So these attributes are NOT USED -- actual
# values are over in ReferentValues. But the attributes are left for now
# (and set) merely for making it easier to eyeball the database by hand:
# atitle, title, issn, isbn, volume, year. (why no issue/page number? hell
# if i know).
class Referent < ActiveRecord::Base
  # for shortcut metadata manipulations
  include MetadataHelper

  has_many :requests
  has_many :referent_values
  has_many :permalinks

  # We really should get rid of these 'mirror' attributes, but
  # in the meantime truncate them.
  include TruncateToDbLimit
  truncate_to_db_limit :volume, :year, :issn, :isbn

  # Pass in :permalink => :force to force creation of a permalink, otherwise
  # no permalink is created by this method, one can be lazily created when
  # needed.
  def self.create_by_context_object(co, options = {})
    clean_up_context_object(co)

    rft = Referent.new

    # Wrap everything in a transaction for better efficiency, at least
    # with MySQL, I think.

    Referent.transaction do
      rft.set_values_from_context_object(co)

      # Permalinks created on-demand later. But if set config to :force, can
      # force old behavior.
      if options[:permalink] == :force
        permalink = Permalink.new_with_values!(rft, co.referrer.identifier)
      end

      # Add shortcuts.
      rft.referent_values.each do |val|
        rft.atitle = val.normalized_value if val.key_name == "atitle" and val.metadata?
        rft.title = val.normalized_value if val.key_name.match(/^[bj]?title$/) and val.metadata?
        rft.issn = val.normalized_value.gsub(/[^\d]/, "")[0, 8] if val.key_name == "issn" and val.metadata?
        rft.isbn = val.normalized_value.gsub(/[^\d]/, "")[0, 13] if val.key_name == "isbn" and val.metadata?
        rft.volume = val.normalized_value if val.key_name == "volume" and val.metadata?
        rft.year = val.normalized_value.gsub(/[^\d]/, "")[0, 4] if val.key_name == "date" and val.metadata?
      end
      rft.save!

      # Apply referent filters
      rfr_id = ""
      rfr_id = co.referrer.identifier if co.referrer && !co.referrer.identifier.blank?
      # UmlautController.umlaut_config.lookup!("referent_filters", []).each do |filter_config|
      [].each do |filter_config|
        regexp = filter_config[:match]
        filter = filter_config[:referent_filter]
        if regexp&.match?(rfr_id)
          filter.filter(rft) if filter.respond_to?(:filter)
        end
      end
    end
    rft
  end

  # Okay, we need to do some pre-processing on weird context objects
  # sent by, for example, firstSearch. Remove invalid identifiers.
  # Also will adjust context objects according to configured
  # umlaut refernet filters (see config.app_config.referent_filters in
  # environment.rb )
  # Mutator: Modifies ContextObject arg passed in.
  def self.clean_up_context_object(co)
    # First, remove any empty DOIs! or other empty identifiers?
    # LOTS of sources send awful empty identifiers.
    # That's not a valid identifier!
    empty_ids = co.referent.identifiers.find_all { |i| i =~ Regexp.new("^[^:]+:[^/:]*(/|:)?$") }
    empty_ids.each { |e| co.referent.delete_identifier(e) }

    # Now look for ISSN identifiers that are on article_level. FirstSearch
    # gives us ISSN identifiers incorrectly on article level cites.
    issn_ids = co.referent.identifiers.find_all { |i| i =~ /^urn:ISSN/ }
    issn_ids.each do |issn_id|
      # Long as we're at it, add an rft.issn if one's not there.
      issn_data = issn_id.slice((9..issn_id.length)) # actual ISSN without identifier prefix
      co.referent.set_metadata("issn", issn_data) if co.referent.get_metadata("issn").blank? && !issn_data.blank?

      # And remove it as an identifier unless we know this is journal-level
      # cite.
      unless co.referent.get_metadata("genre") == "journal"
        co.referent.delete_identifier(issn_id)
      end
    end

    # Clean up OCLC numbers from old bad formats that may have snuck in to an info url incorrectly. # also delete preceding 0's
    oclcnum_ids = co.referent.identifiers.find_all { |i| i =~ /^info:oclcnum/ }
    oclcnum_ids.each do |oclcnum_id|
      # FIXME Does this regex need "ocn" as well?
      if oclcnum_id =~ /^info:oclcnum\/(ocm0*|ocn0*|on0*|\(OCoLC\)0*|ocl70*|0+)(.*)$/
        # Delete the original, take out just the actual oclcnum, not
        # those old prefixes. or preceding 0s.
        co.referent.delete_identifier(oclcnum_id)
        co.referent.add_identifier("info:oclcnum/#{$2}")
      end
    end
  end

  # private use. Adds a referent_value and returns it, does NOT persist
  # it to db. referent_value is constructed with ActiveRecord build, and
  # will be saved when Referent (self) is saved, works on persisted or
  # unpersisted Referent.
  def build_referent_value(key_name, value)
    referent_values.build(
      key_name: key_name,
      value: value,
      normalized_value: ReferentValue.normalize(value),
      private_data: (key_name == "private_data"),
      metadata: (key_name != "identifier" && key_name != "format")
    )
  end

  # Populate the referent_values table with a ropenurl contextobject object
  # Note, does NOT save self, self may still be unsaved.
  def set_values_from_context_object(co)
    rft = co.referent

    # Multiple identifiers are possible!
    rft.identifiers.each do |id_string|
      build_referent_value("identifier", id_string)
    end
    if rft.format
      build_referent_value("format", rft.format)
    end
    if rft.private_data
      # this comes in as "pid" or "rft_dat", we store it in
      # our database as "private_data", sorry, easiest way to
      # fit this in at the moment.
      build_referent_value("private_data", rft.private_data)
    end

    rft.metadata.each { |key, value|
      next unless value.present?
      # Sometimes value is an array, for DC for instance. Do the best we
      # can.
      Array(value).each do |v|
        build_referent_value(key, v)
      end
    }
  end

  # pass in a Referent, or a ropenurl ContextObjectEntity that has a metadata
  # method. Or really anything with a #metadata method returning openurl-style
  # keys and values.
  # Method returns true iff the keys in common to both metadata packages
  # have equal (==) values.
  def metadata_intersects?(arg)
    # if it's empty, good enough.
    return true unless arg

    intersect_keys = metadata.keys & arg.metadata.keys
    # Take out keys who's values are blank. If one is blank but not
    # both, we can still consider that a match.
    intersect_keys.delete_if { |k| metadata[k].blank? || arg.metadata[k].blank? }

    self_subset = metadata.reject { |k, v| !intersect_keys.include?(k) }
    arg_subset = arg.metadata.reject { |k, v| !intersect_keys.include?(k) }

    self_subset == arg_subset
  end

  # Creates a hash of values from referrent_values, to assemble what was
  # spread accross differnet db rows into one easy-lookup hash, for
  # easy access. See also #to_citation for a different hash, specifically
  # for use in View to print citation. And #to_context_object.
  def metadata
    metadata = {}
    referent_values.each { |val|
      metadata[val.key_name] = val.value if val.metadata? and !val.private_data?
    }
    metadata
  end

  def private_data
    referent_values
    priv_data = {}
    referent_values.each { |val|
      priv_data[val.key_name] = val.value if val.private_data?
    }
    priv_data
  end

  def identifiers
    referent_values
    identifiers = []
    referent_values.each { |val|
      if val.key_name == "identifier"
        identifiers << val.value
      end
    }
    identifiers
  end

  def add_identifier(id)
    unless identifiers.find { |i| i == id }
      Referent.connection_pool.with_connection do
        referent_values.create(key_name: "identifier", value: id, normalized_value: ReferentValue.normalize(id), metadata: false, private_data: false).save!
      end
    end
  end

  def format
    referent_values.to_a.find { |val| val.key_name == "format" }.try(:value)
  end

  # Some shortcuts for pulling out/manipulating specific especially
  # useful data elements.

  # finds and normalizes an LCCN. If multiple LCCNs are in the record,
  # returns the first one. Returns a NORMALIZED lccn, but does NOT do
  # validation. see:
  # http://info-uri.info/registry/OAIHandler?verb=GetRecord&metadataPrefix=reg&identifier=info:lccn/
  def lccn
    get_lccn(self)
  end

  # Gets an ISSN, makes sure it's a valid ISSN or else returns nil.
  # So will return a valid ISSN (NOT empty string) or nil.
  def issn
    get_issn(self)
  end

  def isbn
    get_isbn(self)
  end

  def oclcnum
    get_oclcnum(self)
  end

  def doi
    get_doi(self)
  end

  # Creates an OpenURL::ContextObject assembling all the data in this
  # referrent.
  def to_context_object
    co = OpenURL::ContextObject.new

    # Got to initialize the referent entity properly for our format.
    # OpenURL sucks, this is confusing, yes.
    fmt_uri = "info:ofi/fmt:xml:xsd:" + self.format
    co.referent = OpenURL::ContextObjectEntity.new_from_format(fmt_uri)
    rft = co.referent

    # Now set all the values.
    referent_values.each do |val|
      if val.metadata?
        rft.set_metadata(val.key_name, val.value)
        next
      end
      rft.send("set_" + val.key_name, val.value) if rft.respond_to?("set_" + val.key_name)
    end
    co
  end

  # Creates a hash for use in View code to display a citation
  #
  # TODO, move to_citation, type_of_thing, and container_type_of_thing OUT
  # of Refernet, to helper module or own class.
  def to_citation
    citation = {}
    # call self.metadata once and use the array for efficiency, don't
    # keep calling it. profiling shows it DOES make a difference.
    my_metadata = metadata

    if my_metadata["atitle"].present?
      citation[:title] = my_metadata["atitle"]
      ["title", "btitle", "jtitle"].each do |t_type|
        if my_metadata[t_type].present?
          citation[:container_title] = my_metadata[t_type]
          break
        end
      end
    else # only top-level thing, no sub-thing
      ["title", "btitle", "jtitle"].each do |t_type|
        if my_metadata[t_type].present?
          citation[:title] = my_metadata[t_type]
          break
        end
      end
    end

    citation[:title_label] = I18n.t("umlaut.citation.title_of_x", x: type_of_thing, default: "umlaut.citation.title_label")
    citation[:container_label] = container_type_of_thing

    # add publisher for books
    if /book/i.match?(my_metadata["genre"])
      citation[:pub] = my_metadata["pub"] unless my_metadata["pub"].blank?
    end

    citation[:issn] = issn if issn
    citation[:isbn] = isbn if isbn

    ["volume", "issue", "date"].each do |key|
      citation[key.to_sym] = my_metadata[key]
    end

    if my_metadata["au"].present?
      citation[:author] = my_metadata["au"].strip
    elsif my_metadata["aulast"]
      citation[:author] = my_metadata["aulast"].strip
      if my_metadata["aufirst"].present?
        citation[:author] += ", " + my_metadata["aufirst"].strip
      elsif my_metadata["auinit"].present?
        citation[:author] += ", " + my_metadata["auinit"].strip
      else
        if my_metadata["auinit1"].present?
          citation[:author] += ", " + my_metadata["auinit1"].strip
        end
        if my_metadata["auinitm"].present?
          citation[:author] += my_metadata["auinitm"].strip
        end
      end
    elsif my_metadata["aucorp"]
      citation[:author] = my_metadata["aucorp"]
    end
    if my_metadata["spage"]
      citation[:page] = my_metadata["spage"]
      citation[:page] += " - " + my_metadata["epage"] if !my_metadata["epage"].blank?
    end
    citation[:identifiers] = []
    identifiers.each do |id|
      citation[:identifiers] << id unless id.blank? || id.match(/^tag:/)
    end
    citation
  end

  def type_of_thing
    metadata = self.metadata

    key = metadata["genre"]
    key = self.format if key.blank?
    key = key.downcase

    if key == "journal" && metadata["atitle"].present?
      key = "article"
    end

    if key == "book" && metadata["atitle"].present?
      key = "bookitem"
    end

    label = I18n.t(key, scope: "umlaut.citation.genre", default: "")
    label = nil if label.blank?

    label
  end

  # Like type_of_thing, but if it's a contained item, give container name instead.
  def container_type_of_thing
    i18n_key = case metadata["genre"]
    when "article" then "journal"
    when "bookitem" then "book"
    else metadata["genre"] || self.format
    end

    label = I18n.t(i18n_key, scope: "umlaut.citation.genre", default: "")
    label = nil if label.blank?

    label
  end

  def remove_value(key)
    referent_values.where(key_name: key).to_a.each do |rv|
      rv.delete
      referent_values.delete(rv)
    end
  end

  # options => { :overwrite => false } to only enhance if not already there
  def enhance_referent(key, value, metadata = true, private_data = false, options = {})
    ActiveRecord::Base.connection_pool.with_connection do
      return if value.nil?

      matches = referent_values.to_a.find_all do |rv|
        # We ignore #metadata and #private_data matches in overwriting
        # existing value. We used to take them into account, but it triggered
        # a bug in Jruby, and pretty much isn't neccesary, those fields
        # are pretty useless and mostly not used and should prob be removed.
        (rv.key_name == key) # && (rv.metadata == metadata) && (rv.private_data == private_data)
      end

      matches.each do |rv|
        unless options[:overwrite] == false || rv.value == value
          rv.value = value
          rv.save!
        end
      end

      if matches.length == 0
        val = referent_values.create(key_name: key, value: value, normalized_value: ReferentValue.normalize(value), metadata: metadata, private_data: private_data)
        val.save!
      end

      if /(^[ajb]?title$)|(^is[sb]n$)|(^volume$)|(^date$)/.match?(key)
        case key
        when "date" then self.year = ReferentValue.normalize(value)
        when "volume" then self.volume = ReferentValue.normalize(value)
        when "issn" then self.issn = ReferentValue.normalize(value)
        when "isbn" then self.isbn = ReferentValue.normalize(value)
        when "atitle" then self.atitle = ReferentValue.normalize(value)
        else self.title = ReferentValue.normalize(value)
        end
        save!
      end
    end
  end
end
