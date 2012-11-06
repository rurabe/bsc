module Amazon
	class	BooksQuery
		def initialize(search)
			@search = search
			@parsed_response = nil
			control
		end

		def control
			query = Amazon::ItemLookup.new(build_item_lookup_params)
			@parsed_response = query.parsed_response
			update_books
		end

		def update_books
			@search.books.each do |book|
				attributes = @parsed_response[book.ean]
				book.update_attributes(attributes)
			end
		end

		def build_item_lookup_params
			{
				:new => 	pluck_attributes,
				:used => 	pluck_attributes
			}
		end

		def pluck_attributes
			@search.books.pluck(:ean)
		end


	end
end