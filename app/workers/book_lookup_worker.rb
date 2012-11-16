class BookLookupWorker
	include Sidekiq::Worker

	def perform(vendor,search_id)
		search = Search.find(search_id)
		data = search.lookup(vendor).ui_data.to_json
		PrivatePub.publish_to("/" + search.slug,"BOOKSUPPLYCO.importData(#{data})")
	end
end