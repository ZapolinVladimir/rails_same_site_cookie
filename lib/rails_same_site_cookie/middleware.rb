require 'rails_same_site_cookie/user_agent_checker'

module RailsSameSiteCookie
  class Middleware

    COOKIE_SEPARATOR = "\n".freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      puts "STATUS", status
      puts "HEADERS", headers
      puts "BODY", body.inspect
      regex = RailsSameSiteCookie.configuration.user_agent_regex
      if headers['Location'].present? && headers['Location'].include?('admin/oauth/authorize')

      else
        if headers['Set-Cookie'].present? 
  #         and (regex.nil? or regex.match(env['HTTP_USER_AGENT']))
          parser = UserAgentChecker.new(env['HTTP_USER_AGENT'])
          puts "PARSER", parser
          if parser.send_same_site_none?
            cookies = headers['Set-Cookie'].split(COOKIE_SEPARATOR)
            ssl = Rack::Request.new(env).ssl?

            cookies.each do |cookie|
              next if cookie.blank?
  #             if ssl and not cookie =~ /;\s*secure/i
               if not cookie =~ /;\s*secure/i
                cookie << '; secure'
              end

              unless cookie =~ /;\s*samesite=/i
                cookie << '; SameSite=None'
              end

            end

            headers['Set-Cookie'] = cookies.join(COOKIE_SEPARATOR)
            puts "HEADERS RESULT", headers
          end
        end
      end


      [status, headers, body]
    end

  end
end
