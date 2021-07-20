# This is enough to prevent errors from showing on the A-Z list page.
# The 360 Link api, as far as I can tell, does not include access to
# their A-Z list features.
module SearchMethods
  module Alma
    def find_by_group
      [[], 0]
    end

    def find_by_title
      [[], 0]
    end

    def self.fetch_urls?
      false
    end

    def self.fetch_urls
      []
    end
  end
end
