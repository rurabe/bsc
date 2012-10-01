module SearchesHelper

	def show_price(price)
		if price
			number_to_currency(price)
		else
			"N/A"
		end
	end
end
