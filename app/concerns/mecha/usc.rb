module Mecha
  class Usc
    include ParserHelpers
    attr_reader :mecha, :books_page

    def self.words
      %w( trojan tommy coliseum leavey doheny evk parkside cafe84 )
    end

    def initialize(options={})
      @mecha = Mechanize.new { |mecha| mecha.follow_meta_refresh = true }
      @books_page = navigate(options)
    end

    def parse(page=@books_page)
      courses = get_course_nodes(page)
      courses.map do |course|
        course_hash = build_course(course)
        course_hash
      end
    end

    # private
    
      def navigate(options={})
        login(options)
        get_course_page
      end

      # Navigation helpers
      def login(options={})
        initial_login(options)
        continue_login
      end

      def initial_login(options={})
        username = options.fetch(:username)
        password = options.fetch(:password)
        raise Mecha::AuthenticationError if username.blank? || password.blank?
        login_page = @mecha.get('https://my.usc.edu/portal/Login')
        login_form = login_page.form
        login_form.j_username = username
        login_form.j_password = password
        login_form.submit
        raise Mecha::AuthenticationError if login_failed?
      end

      def continue_login
        @mecha.current_page.form.submit
        @mecha.get('https://my.usc.edu/portal/render.userLayoutRootNode.uP') 
      end

      def get_course_page
        @mecha.current_page.link_with(:href => "https://camel2.usc.edu/OASISprtlchnlTest/PortalBridge.aspx").click
      end

      # Error handlers
      def login_failed?
        @mecha.current_page.search('//p[text()="Authentication Failed"]').present?
      end

      # Master parse helper
      def get_course_nodes(page)
        page.search('//ul[@class="info course_list"]/span/li')
      end

      # Parsers
      def build_course(node)
        { :department       => parse_course_department(node), 
          :number           => parse_course_number(node), 
          :section          => parse_course_section(node), 
        # :instructor       => parse_course_instructor(node),
          :school_unique_id => parse_course_section(node),
          :books_attributes => get_books(node) }
      end

      def parse_course_department(node)
        string = parse_node(node,'./h4/strong')
        parse_result(string, /^(\w+) \w+$/)
      end

      def parse_course_number(node)
        string = parse_node(node,'./h4/strong')
        parse_result(string, /^\w+ (\w+)$/)
      end

      def parse_course_section(node)
        parse_node(node,'./table/tr/td[@class="section"]')
      end

      def get_books(node)
        section = parse_course_section(node)
        book_nodes = query_for_booklist(section)
        book_nodes.map { |node| build_book(node) }
      end

      def query_for_booklist(section)
        sec = clean_section(section)
        booklist = @mecha.get("http://web-app.usc.edu/soc/20131/section.html?i=#{sec}&t=20131")
        book_nodes = booklist.search('//li[@class="books"]/ul/li')      
      end

      def clean_section(raw_section)
        raw_section.gsub(/\D/,'')
      end

      def build_book(node)
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

      def parse_book_author(node)
        parse_node(node,'./text()[following-sibling::em][1]')
      end

      def parse_book_ean(node)
        parse_node(node,'./text()[preceding-sibling::strong[text()="ISBN:"]][1]')
      end

      def parse_book_requirement(node)
        parse_node(node,'./text()[preceding-sibling::em][1]').to_s.gsub(/[()]/,"")
      end

      def parse_new_book_price(node)
        price = parse_node(node,'./text()[preceding-sibling::strong[text()="New:"]][1]')
        numberize_price(price)
      end

      def parse_used_book_price(node)
        price = parse_node(node,'./text()[preceding-sibling::strong[text()="Used:"]][1]')
        numberize_price(price)
      end

  end
end