class AmazonWorker
	include Sidekiq::Worker

	def perform(search_id)
		search = Search.find(search_id)
		PrivatePub.publish_to("/" + search.slug,"alert('yo')")
	end
end