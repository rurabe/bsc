module Mecha
	class AuthenticationError < StandardError
		def message
			"There was an error with your username or password. Check it out and try again."
		end
	end

end