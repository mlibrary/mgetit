# Copyright (c) 2016, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

module LinkResolver
  module Alma
    # A null-option-list class that responds to `#enhance_metadata` and
    # `#add_service` appropriately.
    class FailedOptionList
      def initialize(exception)
        @exception = exception
      end

      def enhance_metadata(request)
      end

      def add_service(request, service)
        request.add_service_response(
          service: service,
          service_type_value: "site_message",
          type: "warning",
          message: "umlaut.message.three_sixty_link_unavailable"
        )
        false
      end
    end
  end
end
