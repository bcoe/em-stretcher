module EventMachine::Stretcher
  class Server < Stretcher::Server
    # Handy way to query the server, returning *only* the body
    # Will fail with an exception when the status is not in the 2xx range.
    #
    # @param method [Symbol] HTTP method to execute.
    # @param path [String] full ES API URL to hit (http://127.0.0.1:9200/_status).
    # @param body [Hash] Hash ElasticSearch query body.
    # @param headers [Hash] additional headers.
    # @param options [Options]
    #  @param options.mashify [Boolean] should the response be turned into a Hashie::Mash?
    # @return [Deferrable] deferrable that yields ElasticSearch response.
    def request(method, path, params={}, body=nil, headers={}, options={})
      options = { :mashify => true }.merge(options)

      # Rather than setting up the default headers using the
      # Faraday middlewear, we set them here.
      http_params = {
        headers: headers.merge({
          :accept =>  'application/json',
          :user_agent => "Stretcher Ruby Gem #{Stretcher::VERSION}",
          "Content-Type" => "application/json"
        })
      }

      deferrable = EventMachine::DefaultDeferrable.new

      # Update params with GET and POST parameters.
      http_params[:query] = Stretcher::Util.clean_params(params) if params
      http_params[:body] = JSON.dump(body) if body

      # Execute :get, :post, :put, or :delete, returns a deferrable.
      http = EventMachine::HttpRequest.new(path).send(method,  http_params)

      # We return our own deferrable, so that we can parse results.
      http.callback do
        check_response(http, deferrable, options)
      end

      http.errback do |err|
        deferrable.fail(err)
      end

      deferrable
    end

    private

    # Internal use only
    # Check response codes from request
    def check_response(res, deferrable, options)
      status = res.response_header.status

      if status >= 200 && status <= 299
        if(options[:mashify])
          begin
            parsed_response = JSON.parse(res.response)
            deferrable.succeed(Hashie::Mash.new(parsed_response))
          rescue
            deferrable.succeed(res.response)
          end
        else
          deferrable.succeed(res.response)
        end
      elsif [404, 410].include? status
        err_str = "Error processing request: (#{status})! #{res.req.method} URL: #{res.req.uri}"
        err_str << "\n Resp Body: #{res.response}"
        deferrable.fail(Stretcher::RequestError::NotFound.new(err_str))
      else
        err_str = "Error processing request (#{status})! #{res.req.method} URL: #{res.req.uri}"
        err_str << "\n Resp Body: #{res.response}"
        deferrable.fail(Stretcher::RequestError.new(err_str))
      end
    end

  end
end
