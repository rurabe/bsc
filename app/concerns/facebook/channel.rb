module Facebook
	class Channel
		def self.call(env)
			[
	      200,
	      {
	        'Pragma'        => 'public',
	        'Cache-Control' => "max-age=#{1.year.to_i}",
	        'Expires'       => 1.year.from_now.to_s(:rfc822),
	        'Content-Type'  => 'text/html'
	      },
	      ['<script type="text/javascript" src="//connect.facebook.net/en_US/all.js"></script>']
	    ]
		end
	end
end