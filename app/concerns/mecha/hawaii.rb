module Mecha
	class Hawaii

		def self.words
			%w(rainbow warriors manoa aloha dole metcalf)
		end

		def initialize(options={})
			
		end

		def navigate(options={})			
			username = options.fetch(:username)
			password = options.fetch(:password)

			if username.blank? || password.blank?
				raise Mecha::AuthenticationError
			end

			mecha = Mechanize.new
			mecha.follow_meta_refresh = true

			login_page = mecha.get('https://www.sis.hawaii.edu/uhdad/twbkwbis.P_WWWLogin')

			login_form = login_page.form('uhloginform')
				login_form.sid = username
				login_form.PIN = password
			aes_page = login_form.submit

			key		 = aes_page.search(blah)
			cipher = aes_page.search(blah)

			main_page = mecha.post('https://www.sis.hawaii.edu/uhdad/twbkwbis.P_ValLogin', aes_decrypt(key,cipher))




			# mecha.get('https://www.sis.hawaii.edu/uhdad/twbkwbis.P_GenMenu?name=bmenu.P_MainMnu')

		end

		def aes_decrypt(key,data)
			decrypted_data = decrypt_hex(key,data)
			parse_decrypted_data(decrypted_data)
		end

		def decrypt_hex(key,data)
			aes = FastAES.new(hex_to_string(key))
			aes.decrypt(hex_to_string(data))
		end

			def hex_to_string(hex)
				bytes = hex_to_bytes(hex)
				bytes_to_string(bytes)
			end

			def hex_to_bytes(hex)
				hex.split('').each_slice(2).map {|b| b.join('').hex}
			end

			def bytes_to_string(bytes)
				bytes.map {|a| a.chr}.join("")
			end

		def parse_decrypted_data(data)
			match_data = data.match /\d+ (\w+)\t(\w+)<*/
			{ :sid => match_data[1], :pin => match_data[2] }
		end
	end
end