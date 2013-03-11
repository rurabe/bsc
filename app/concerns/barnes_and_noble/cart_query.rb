module BarnesAndNoble
  class CartQuery
    def initialize(params)
      @books = params[:books]
    end

    def link
      base_url + build_params + additional_params
    end

    def build_params
      @books.each_with_index.map do |book,i|
        parameterize_book(book,i)
      end.join('&')
    end

    def parameterize_book(book,i)
      book_params(book,i).map { |k,v| "#{k}#{i+1}=#{v}" }.join('&')
    end

    def book_params(book,i)
      {
        :ean          => book[:vendor_book_id],
        :productcode  => product_code(book),
        :qty          => 1
      }
    end

    def product_code(book)
      case book[:condition]
      when "new"  then "BK"
      when "used" then "MP"
      end
    end

    def base_url
      "http://cart4.barnesandnoble.com/op/request.aspx?"
    end

    def additional_params
      "&stage=fullCart&uiaction=multAddMoreToCart"
    end

  end
end