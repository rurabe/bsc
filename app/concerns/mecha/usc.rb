module Mecha
  class Usc
    include ParserHelpers
    attr_reader :mecha

    def initialize(options={})
      @mecha = Mechanize.new { |mecha| mecha.follow_meta_refresh = true }
    end
    
    def navigate(options={})
      login(options)
      get_courses

    end

    def login(options)
      username = options.fetch(:username)
      password = options.fetch(:password)
      raise Mecha::AuthenticationError if username.blank? || password.blank?
      login_page = @mecha.get('https://my.usc.edu/portal/Login')
      login_form = login_page.form
      login_form.j_username = username
      login_form.j_password = password
      continue_page = login_form.submit
      continue_page.form.submit
      
    end

    def get_courses
      course_nodes = get_course_page
      course_nodes.map { |node| parse_course_node(node) }
    end

    def get_course_page
      oasis_info = @mecha.get('https://camel2.usc.edu/OASISprtlchnlTest/PortalBridge.aspx')
      oasis_info.search('//ul[@class="info course_list"]/span/li')
    end

    def parse_course_node(node)
      { :department       => parse_class(node,:department), 
        :number           => parse_class(node,:number), 
        :section          => parse_course_section(node), 
      # :instructor       => parse_course_instructor(node),
        :school_unique_id => parse_course_section(node),
        :books_attributes => get_books(node) }
    end

    def parse_class(node,attribute)
      string = parse_node(node,'./h4/strong')
      match = string.match(/^(\D+) (\d+)$/) if string
      results = { :department => match[1], :number => match[2] } if match
      results[attribute]
    end

    def parse_course_section(node)
      parse_node(node,'./table/tr/td[@class="section"]')
    end

    def get_books(node)
      section = parse_course_section(node)
      book_nodes = query_for_booklist(section)
      book_nodes.map { |node| parse_book_node(node) }
    end

    def query_for_booklist(section)
      sec = clean_section(section)
      booklist = @mecha.get("http://web-app.usc.edu/soc/20131/section.html?i=#{sec}&t=20131")
      book_nodes = booklist.search('//li[@class="books"]/ul/li')      
    end

    def clean_section(raw_section)
      raw_section.gsub(/\D/,'')
    end

    def parse_book_node(node)
      { :title                       => parse_book_title(node),
        :author                      => parse_book_author(node),
        :ean                         => parse_book_ean(node),
      # :edition                     => parse_book_edition(node),
        :requirement                 => parse_book_requirement(node),
        :bookstore_new_price         => parse_new_book_price(node),
        :bookstore_used_price        => parse_used_book_price(node)}
    end

    def parse_book_title(node)
      parse_node(node,'./em')
    end

    def parse_book_ean(node)
      parse_node(node,'./text()[preceding-sibling::strong[text()="ISBN:"]][1]')
    end

    def parse_new_book_price(node)
      price = parse_node(node,'./text()[preceding-sibling::strong[text()="New:"]][1]')
      numberize_price(price)
    end

    def parse_used_book_price(node)
      price = parse_node(node,'./text()[preceding-sibling::strong[text()="Used:"]][1]')
      numberize_price(price)
    end

    def parse_book_requirement(node)
      parse_node(node,'./text()[preceding-sibling::em][1]').to_s.gsub(/[()]/,"")
    end

    def parse_book_author(node)
      parse_node(node,'./text()[following-sibling::em][1]')
    end


  end
end