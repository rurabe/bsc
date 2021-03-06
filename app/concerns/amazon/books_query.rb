module Amazon
	class	BooksQuery
		attr_reader :parsed_response
		def initialize(booklist)
			@booklist = booklist
			@parsed_response = nil
			control
		end

		def control
			query = Amazon::ItemLookup.new(build_item_lookup_params)
			@parsed_response = query.parsed_response
			p @parsed_response
			update_books
		end

		def update_books
			@booklist.books.each do |book|
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
			@booklist.books.pluck(:ean)
		end


	end
end