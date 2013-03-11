module Amazon
  class ApiClass < Automatron::ParserClass

    def send_request(options={})
      url = prepare_url(options)
      response = Net::HTTP.get_response(url)
      Nokogiri::XML(response.body).remove_namespaces!
    end

    private

      def prepare_url(options={})
        base = 'http://webservices.amazon.com/onca/xml'
        params = canonical_params(options)
        signature = generate_signature(params)
        URI.parse("#{base}?#{params}&Signature=#{signature}")
      end

      def default_params
        {  :service => 'AWSECommerceService',
           :AWS_access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
           :associate_tag => ENV['AMAZON_ASSOCIATE_TAG'],
           :timestamp => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ") }
      end

      def canonical_params(options={})
        encode_params(options).map { |pair| "#{pair[0]}=#{pair[1]}" }.join("&")
      end

      def encode_params(options={})
        Hash[*sort_params(options).map { |e| url_encode(e.to_s) }]
      end

      def sort_params(options={})
        camelize_params(options).sort.flatten
      end

      def camelize_params(options={})
        combined_params(options).inject({}) { |h,(k,v)| h.merge!({k.to_s.camelize => v}); h }
      end

      def combined_params(options={})
        default_params.merge(options)
      end

      def url_encode(string)
        CGI.escape(string).gsub("%7E", "~").gsub("+", "%20") if string
      end
    
      def generate_signature(params)
        key    = ENV['AMAZON_SECRET_KEY']
        url    = "GET\nwebservices.amazon.com\n/onca/xml\n#{params}"
        digest = OpenSSL::Digest::SHA256.new
        URI.escape(Base64.encode64( OpenSSL::HMAC.digest(digest, key, url) ).strip, /[+=]/)
      end

  end
end