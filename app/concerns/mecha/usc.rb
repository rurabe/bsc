
module Mecha
  class Usc < BasicMecha

    CURRENT_TERM = "20131"

    def self.words
      %w( trojan tommy coliseum leavey doheny evk parkside cafe84 viterbi marshall thornton
          rossier annenberg new north pardee marks troy cardinal gold heritage vkc bovard 
          commons traddies nineoh therow uv century conquest lyons roski gould keck thornton
          taper leventhal psx psa psb psd figueroa expo vermont jefferson chanos deltaco
          la tirebiter watts birnkrant fluor carlsjr )
    end

    private
      # Hardpoints #
      def navigate(options={})
        login(options)
        navigate_to_course_page
      end

      def course_data(page)
        build_all_courses(page)
      end

      def section_data(course_node)
        get_section_nodes(course_node).map { |section_node| build_section(section_node) }
      end

      def book_data(section_node)
        get_book_nodes(section_node).map { |book_node| build_book(book_node) }
      end

      # Navigate helpers #
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

      def navigate_to_course_page
        @mecha.current_page.link_with(:href => "https://camel2.usc.edu/OASISprtlchnlTest/PortalBridge.aspx").click
      end

      # Error handlers #
      def login_failed?
        @mecha.current_page.search('//p[text()="Authentication Failed"]').present?
      end

      # Course_data helpers #
      def build_all_courses(page)
        threads = get_course_nodes(page).map { |course| lambda{ build_course(course) } }
        Automatron::Needle.thread(threads)
      end

      def get_course_nodes(page)
        all_nodes = page.search('//ul[@class="info course_list"]/span/li').to_a
        all_nodes.uniq { |course_node| parse_course_school_unique_id(course_node) }
      end

      # Section_data helpers #
      def get_section_nodes(course_node)
        course_node.search(".//tr[td]")
      end

      # Book_data helpers #
      def get_book_nodes(section_node)
        section_id = clean_section(parse_section_school_unique_id(section_node))
        query_for_booklist(section_id)
      end

      def query_for_booklist(section)
        junk_mecha = Mechanize.new { |mecha| mecha.keep_alive = false }
        booklist = junk_mecha.get("http://web-app.usc.edu/soc/section.html?i=#{section}&t=#{CURRENT_TERM}")
        book_nodes = booklist.search('//li[@class="books"]/ul/li')      
      end

      def clean_section(raw_section)
        raw_section.gsub(/\D/,'')
      end

      # Course parsers #
      def parse_course_school_unique_id(course_node)
        "#{parse_course_department(course_node)}-#{parse_course_number(course_node)}"
      end

      def parse_course_department(course_node)
        string = parse_node(course_node,".//h4/strong")
        parse_result(string, /^(\w+) \w+$/) if string
      end

      def parse_course_number(course_node)
        string = parse_node(course_node,".//h4/strong")
        parse_result(string, /^\w+ (\w+)$/) if string
      end

      # Section parsers #
      def parse_section_school_unique_id(section_node)
        parse_node(section_node,".//td[@class='section']")
      end

      def parse_section_instructor(section_no)
      end

      # Book parsers #
      def parse_book_title(book_node)
        parse_node(book_node,'./em')
      end

      def parse_book_author(book_node)
        parse_node(book_node,'./text()[following-sibling::em][1]')
      end

      def parse_book_ean(book_node)
        parse_node(book_node,'./text()[preceding-sibling::strong[text()="ISBN:"]][1]')
      end

      def parse_book_edition(book_node)
      end

      def parse_book_requirement(book_node)
        parse_node(book_node,'./text()[preceding-sibling::em][1]').to_s.gsub(/[()]/,"")
      end

      def parse_book_notes(book_node)
        parse_node(book_node,'./text()[preceding-sibling::br[preceding-sibling::text()[preceding-sibling::strong[text()="Used:"]]]][1]')
      end

      def parse_book_new_price(book_node)
        price = parse_node(book_node,'./text()[preceding-sibling::strong[text()="New:"]][1]')
        numberize_price(price)
      end

      def parse_book_used_price(book_node)
        price = parse_node(book_node,'./text()[preceding-sibling::strong[text()="Used:"]][1]')
        numberize_price(price)
      end

      def parse_book_new_rental_price(book_node)
      end

      def parse_book_used_rental_price(book_node)
      end
  end
end