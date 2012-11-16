class UsedBnBookLookupWorker
	include Sidekiq::Worker

	def perform(ean,search_id)
		search = Search.find(search_id)
		data = BarnesAndNoble::UsedBooks.new(ean).ui_data.to_json
		PrivatePub.publish_to("/" + search.slug,"BOOKSUPPLYCO.importData(#{data})")
	end
end