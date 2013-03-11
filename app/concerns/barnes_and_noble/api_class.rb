module BarnesAndNoble
  class ApiClass < Automatron::ParserClass

    def send_request(params)
      response = Net::HTTP.get_response(api_build_uri(params))
      api_parse_response(response)
    end

    private

      def api_build_uri(params)
        operation = params.delete(:operation)
        url = base_url + operation.to_s.camelcase + "?" + api_build_params(params)
        URI(url)
      end

      def base_url
        "http://services.barnesandnoble.com/v03_00/"
      end

      def api_build_params(params)
        request_params(params).map { |key,value| "#{key.to_s.camelcase}=#{value}" }.join("&")
        
      end

      def request_params(params)
        default_api_params.merge(params)
      end

      def default_api_params
        { :app_id => ENV['BN_API_KEY'] }
      end

      def api_parse_response(response)
        Nokogiri::XML(response.body)
      end

        # Parser helpers

      def format_price(data)
        data.to_d if data
      end

      def parse_node(node,xpath)
        result = node.search(xpath) if node
        result.text.strip if result
      end
  end
end