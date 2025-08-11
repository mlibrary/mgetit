require "active_support"
require "titlecase"

require_relative "link_resolver/preprocess_query_string"
require_relative "link_resolver/proxy"

require_relative "link_resolver/lib_key"
require_relative "link_resolver/alma"
require_relative "link_resolver/catalog"
require_relative "link_resolver/primo"

require_relative "link_resolver/referent_presenter"
require_relative "link_resolver/article_presenter"
# require_relative 'link_resolver/journal_presenter'
# require_relative 'link_resolver/book_presenter'
# require_relative 'link_resolver/chapter_presenter'
require_relative "link_resolver/service_response_presenter"
require_relative "link_resolver/presenter"

require_relative "marc_helper"
require_relative "metadata_helper"
require_relative "umlaut_http"
require_relative "link_resolver/google_book_search"
