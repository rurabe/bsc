module BooklistsHelper


	def requirement_class(requirement)
		case requirement
		when "Required"
			"label-important"
		when "Recommended"
			"label-warning"
		when "Optional"
			"label-success"
		when "Choose"
			"label-warning"
		end
	end

	def titleize(title)
		title.gsub(/\.$/,"").titlecase
	end
end
