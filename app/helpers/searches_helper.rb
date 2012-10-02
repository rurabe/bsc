module SearchesHelper

	def show_price(price)
		if price
			number_to_currency(price)
		else
			"N/A"
		end
	end


	def requirement_class(requirement)
		case requirement
		when "Required"
			"label-important"
		when "Recommended"
			"label-warning"
		when "Optional"
			"label-success"
		end
	end
end
