
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
      def course_and_book_data(page)
        threads = []
        all_courses = courses_data(page)
        get_section_nodes(page).each do |section|
          course = all_courses.find { |course| same_course?(course,section) }
          threads << Thread.new { course[:sections_attributes] << build_section(section) }
        end
        threads.map { |t| t.join }
        all_courses
      end

      def same_course?(course,section)
        course[:department] == parse_course_department(section) && course[:number] == parse_course_number(section)
      end

      def get_section_nodes(page)
        page.search('//ul[@class="info course_list"]/span/li')
      end

      def courses_data(page)
        get_section_nodes(page).map do |course|
          build_course(course)
        end.uniq
      end

      def generate_headline(course)
        "#{course[:department]} #{course[:number]}"
      end

      # Parsers
      def build_course(node)
        { :department          => parse_course_department(node), 
          :number              => parse_course_number(node), 
          :sections_attributes => [] }
      end

      def parse_course_headline(node)
        parse_result(parse_node(node,'./h4/strong'),/^(\w+ \w+)$/)
      end

      def parse_course_department(node)
        parse_result(parse_course_headline(node), /^(\w+) \w+$/)
      end

      def parse_course_number(node)
        parse_result(parse_course_headline(node), /^\w+ (\w+)$/)
      end

      def parse_section_unique_id(node)
        parse_node(node,'.//table/tr/td[../td[@class="type"]/text()="Lecture" and @class="section"]') || parse_node(node,'.//table/tr/td[@class="section"]')
      end

      def parse_section_instructor(node)
        
      end

      def book_data(node)
        section_id = parse_section_unique_id(node)
        book_nodes = query_for_booklist(section_id)
        book_nodes.map { |node| build_book(node) }
      end

      def query_for_booklist(section)
        junk_mecha = Mechanize.new { |mecha| mecha.follow_meta_refresh = true }
        sec = clean_section(section)
        booklist = junk_mecha.get("http://web-app.usc.edu/soc/section.html?i=#{sec}&t=#{CURRENT_TERM}")
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
          :notes                       => parse_book_notes(node), 
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

      def parse_book_notes(node)
        parse_node(node,'./text()[preceding-sibling::br[preceding-sibling::text()[preceding-sibling::strong[text()="Used:"]]]][1]')
      end

      def parse_new_book_price(node)
        price = parse_node(node,'./text()[preceding-sibling::strong[text()="New:"]][1]')
        numberize_price(price)
      end

      def parse_used_book_price(node)
        price = parse_node(node,'./text()[preceding-sibling::strong[text()="Used:"]][1]')
        numberize_price(price)
      end

      
      def parse_book_new_rental_price(book_node)
      end


      def parse_book_used_rental_price(book_node)
      end

  end
end