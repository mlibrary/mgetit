class RequestPresenter < SimpleDelegator

  CITATION_ATTRIBUTES = %i{
    title author date container_title volume issue page
    issn isbn
  }

  CITATION_ATTRIBUTES.each do |attr|
    define_method attr do
      return @citation[attr]
    end
  end

  attr_reader :type, :pmid, :doi

  def initialize(request)
    rft = request.referent
    @type = rft.type_of_thing
    @citation = rft.to_citation
    @disambiguation = !!request.service_responses.to_a.find { |response| response.service_type_value.name == :disambiguation }
    @pmid = @citation[:identifiers].map { |id| id.start_with?('info:pmid') ? id.slice(10, id.length) : nil }.compact.first
    @doi  = @citation[:identifiers].map { |id| id.start_with?('info:doi') ? id.slice(9, id.length) : nil}.compact.first
    super(request)
  end

  def unambiguous?
    !@disambiguation
  end

  def disambiguation?
    @disambiguation
  end

  def container_type
    @container_type ||= case @type
    when 'Book Chapter'
      'Book'
    else
      'Journal'
    end
  end

end
