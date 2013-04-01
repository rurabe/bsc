module Bookstore
  class CartQuery

    def  initialize(params)
      @books = params[:books]
    end


    def link
      @books.first[:link]
    end
  end
end