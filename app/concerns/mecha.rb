module Mecha
	class AuthenticationError < StandardError
		def message
			"There was an error with your username or password. You might want to check that out and try again."
		end
	end

end