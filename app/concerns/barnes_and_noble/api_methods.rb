module BarnesAndNoble
	module ApiMethods
		API_KEY = "LS2948742"
		BASE_URL = "http://services.barnesandnoble.com/v03_00/"
		DEFAULT_PARAMS = {:app_id => "LS2948742"}

		def send_request(params)
			response = Net::HTTP.get_response(URI(build_url(params)))
		end

		def build_url(params)
			operation = params.delete(:operation)
			BASE_URL + operation.to_s.camelcase + "?" + build_params(params)
		end

		def build_params(params)
			request_params = DEFAULT_PARAMS.merge(params)
			request_params.map { |key,value| "#{key.to_s.camelcase}=#{value}" }.join("&")
		end
	end
end