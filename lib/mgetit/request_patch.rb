# Copyright (c) 2016, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

module Mgetit
  module RequestPatch

    def self.included(base)
      base.instance_eval do
        # Called by self.find_or_create, if a new request _really_ needs to be created.
        def self.create_new_request!(args)
          # all of these are required
          params = args[:params]
          session = args[:session]
          a_rails_request = args[:rails_request]
          contextobj_fingerprint = args[:contextobj_fingerprint]
          context_object = args[:context_object]

          # We don't have a complete Request, but let's try finding
          # an already existing referent and/or referrer to use, if possible, or
          # else create new ones. 

          rft = nil
          if ( params['umlaut.referent_id'])
             rft = Referent.where(:id => params['umlaut.referent_id']).first
          end


          # No id given, or no object found? Create it. 
          unless (rft )
            rft = Referent.create_by_context_object(context_object)
          end

          # Create the Request
          req = Request.new
          req.session_id = a_rails_request.session_options[:id]
          req.contextobj_fingerprint = contextobj_fingerprint
          # Don't do this! It is a performance problem.
          # rft.requests << req
          # (rfr.requests << req) if rfr
          # Instead, say it like this:
          req.referent = rft
          req.referrer_id = context_object.referrer.identifier unless context_object.referrer.empty? || context_object.referrer.identifier.empty?

          # Save client ip
          req.client_ip_addr = params['req.ip'] || a_rails_request.remote_ip()
          req.client_ip_is_simulated = true if req.client_ip_addr != a_rails_request.remote_ip()
    
          # Save selected http headers, keep some out to avoid being too long to
          # serialize. This is in retrospect not a great design to save http hash,
          # should be individual columns of things we want to save. When we next make
          # Umlaut schema changes maybe. 
          #
          # One problem we're running into is exceeding width of db column. 
          # We'll only save REQUEST_URI AND HTTP_REFERER if they're not too long to try and avoid. 
          #
          # Also mark as "ISO-8859-1" to save space in the YAML encoding, current YAML uuencodes
          # 'binary' taking up too much space. HTTP headers are usually ascii, theoretically
          # can be ISO-8859-1, theoretically can but never are something else with proper marking,
          # we won't worry about. 
          req.http_env = {}
          a_rails_request.env.each do |k, v|
            if ((k.slice(0,5) == 'HTTP_' && k != 'HTTP_COOKIE' ) ||
              (k == 'REQUEST_URI') ||
              k == 'SERVER_NAME')
              k = k.dup.force_encoding("ISO-8859-1")
              v.force_encoding("ISO-8859-1")
              v.scrub!
              req.http_env[k] = v
            end
          end

          req.save!
          return req
        end
      end
    end
  end
end
