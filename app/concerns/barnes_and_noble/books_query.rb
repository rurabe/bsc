module BarnesAndNoble
	class BooksQuery
		def initialize(search)
			@search = search
			@response = nil
			@parsed_response = nil
			control
		end

		def control
			query = BarnesAndNoble::ItemLookup.new(pluck_attributes)
			@response = query.response
			@parsed_response = query.parsed_response
			update_books
		end

		def update_books
			@search.books.each do |book|
				new_book_info = @parsed_response[book.ean]
				book.update_attributes(new_book_info)
			end
		end

		def pluck_attributes
			@search.books.pluck(:ean)
		end

	end
end