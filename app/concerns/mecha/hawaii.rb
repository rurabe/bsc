module Mecha
  class Hawaii < BasicMecha

    CURRENT_TERM = "SPRING%2013"

    def self.words
      %w(manoa makiki palolo moilili kaimuki stlouis kahala ainahaina hawaiikai makapuu waimanalo
         kailua lanikai maunawili kaneohe laie waimea sunset haleiwa wailua wahiawa mililani waipio
         aiea pearlridge airport nimitz downtown chinatown kakaako alamoana waikiki mcully waialae 
         pauoa tantalus nuuanu liliha kalihi halawa moanalua waipahu ewa waikele makakilo nanakuli
         waianae kapolei waimalu waiahole kahaluu kaaawa hauula kahuku pupukea kahuku mokuleia sandisland
         kualoa pearlharbor)
    end

    def parse(page=@courses_page)
      raise Mecha::ClassesNotInSystemError if books_not_found?
      super
    end

    private
      # Hardpoints #
      def navigate(options={})      
        login(options)
        navigate_to_course_schedule
        navigate_to_books_page
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
      def login(options)
        initial_login(options)
        aes_login
      end

      def initial_login(options)
        username = options.fetch(:username)
        password = options.fetch(:password)
        raise Mecha::AuthenticationError if username.blank? || password.blank?
        1/0 if username == 'lward'
        login_page = @mecha.get('https://www.sis.hawaii.edu/uhdad/twbkwbis.P_WWWLogin')
        login_form = login_page.form('uhloginform')
        login_form.sid = username
        login_form.pin = password
        login_form.submit
        raise Mecha::AuthenticationError if login_failed?
      end

      def aes_login   
        raise Mecha::ServiceDownError if service_down?
        aes_page = @mecha.current_page
        aes_login_form = aes_page.form('loginform')
        key    = aes_key_from_cookies(@mecha.cookie_jar.jar)
        cipher = aes_page.form.field('cipherhex').value
        @mecha.post('https://www.sis.hawaii.edu/uhdad/twbkwbis.P_ValLogin', aes_decrypt(key,cipher))
      end

      def navigate_to_course_schedule
        @mecha.post('https://www.sis.hawaii.edu/uhdad/bwskfshd.P_CrseSchdDetl','term_in' => '201330')
      end

      def navigate_to_books_page
        raise Mecha::NoClassesError if no_classes?
        @mecha.get(bookstore_url)
      end

      # Encryption Helpers #
      def aes_key_from_cookies(cookies)
        find_in_hash("rkeyhex",cookies).value
      end

      def find_in_hash(key,hash)
        return hash[key] if hash.has_key?(key)
        hash.each_value.flat_map do |value|
          find_in_hash(key,value) if value.class == Hash
        end.reject {|v| v == nil}.first
      end

      def aes_decrypt(key,data)
        decrypted_data = decrypt_hex(key,data)
        parse_decrypted_data(decrypted_data)
      end

      def decrypt_hex(key,data)
        aes = FastAES.new(hex_to_string(key))
        aes.decrypt(hex_to_string(data))
      end

      def hex_to_string(hex)
        bytes = hex_to_bytes(hex)
        bytes_to_string(bytes)
      end

      def hex_to_bytes(hex)
        hex.split('').each_slice(2).map {|b| b.join('').hex}
      end

      def bytes_to_string(bytes)
        bytes.map {|a| a.chr}.join("")
      end

      def parse_decrypted_data(data)
        match_data = data.match(/\d+ (\w+)\t(\w+)<*/)
        { :sid => match_data[1], :pin => match_data[2] }
      end

      # Bookstore Url Generator
      def bookstore_url
        "http://www.bookstore.hawaii.edu/manoa/SelectCourses.aspx?src=2&type=2&stoid=105&trm=#{CURRENT_TERM}&cid=" + get_crns.to_s
      end

      def get_crns
        nodes = @mecha.current_page.search("//td[../th[@class='ddlabel']/acronym/text()[.='CRN']]")
        nodes.map { |node| node.content }.join(",") if nodes.present?
      end

      # Error handlers #
      def login_failed?
        @mecha.current_page.search('//*[contains(.,"You have entered an incorrect Username or Password")]').present?
      end

      def no_classes?
        @mecha.current_page.search('//*[contains(.,"You are not currently registered for the term")]').present?
      end

      def books_not_found?
        @mecha.current_page.search('//*[contains(.,"No Unique IDs match your search request")]').present?
      end

      def no_books?(nodes)
        nodes.empty?
      end

      def service_down?
        @mecha.current_page.search('//*[contains(.,"Service Temporarily Unavailable")]').present?
      end

      # Course_data helpers #
      def build_all_courses(page)
        get_course_nodes(page).map { |course| build_course(course) }
      end

      def get_course_nodes(page)
        all_nodes = page.search("//div[@class='course_info']").to_a
        raise Mecha::NoBooksError if no_books?(all_nodes)
        all_nodes.uniq { |course_node| parse_course_school_unique_id(course_node) }
      end

      # Section_data helpers #
      def get_section_nodes(course_node)
        department = parse_course_department(course_node)
        number     = parse_course_number(course_node)
        course_node.search("//div[@class='course_info' and contains(normalize-space(.),'#{department} #{number}')]")
      end

      # Book_data helpers #
      def get_book_nodes(section_node)
        no_of_books = section_node.search(".//div[@class='material_info']").count
        no_of_books.times.map do |i|
          section_node.search(".//div[@class='material_info'][#{i+1}] | .//div[@class='pricing_wrapper'][#{i+1}]")
        end
      end

      # Course parsers #
      def parse_course_school_unique_id(course_node)
        "#{parse_course_department(course_node)}-#{parse_course_number(course_node)}"
      end

      def parse_course_department(course_node)
        string = parse_node(course_node,'./div[@class="term_bar"]/h2')
        parse_result(string,/Name:\s(\S+)\s/)
      end

      def parse_course_number(course_node)
        string = parse_node(course_node,'./div[@class="term_bar"]/h2')
        parse_result(string,/Name:\s\S+\s+(\d+)\w*\sSection:/)
      end

      # Section parsers #
      def parse_section_instructor(section_node)
        string = parse_node(section_node,'./div[@class="term_bar"]/h2')
        parse_result(string,/Instructor:\s+(\w+)\s+/)
      end

      def parse_section_school_unique_id(section_node)
        string = parse_node(section_node,'./div[@class="term_bar"]/h2')
        parse_result(string,/Course ID:\s+(\w+)\s+Location:/)
      end

      # Book parsers #
      def parse_book_title(book_node)
        parse_node(book_node,'.//h3')
      end

        # This guy parses the material_node for each of the 3 attributes
      def parse_book_attribute(book_node,attribute)
        parse_node(book_node,".//td[@class='right_side']/span[../../td[@class='left_side']/text() = '#{attribute.to_s}']")
      end

      def parse_book_author(book_node)
        parse_book_attribute(book_node,:Author)
      end

      def parse_book_edition(book_node)
        parse_book_attribute(book_node,:Edition)
      end

      def parse_book_ean(book_node)
        parse_book_attribute(book_node,:ISBN)
      end

      def parse_book_link(book_node)
        
      end

      def parse_book_requirement(book_node)
        parse_node(book_node,'./div[@class="material_label"]/span')
      end

      def parse_book_notes(book_node)
      end

      # And this guy does the same for the prices
      def parse_book_price(book_node,condition)
        price = parse_node(book_node,"./div/div[@class='pricing_area']/div/div/div/p[@class='price']/span[../../p[@class='price_label']/text() = '#{condition.to_s.capitalize}']")
        numberize_price(price)
      end

      def parse_new_offer_price(book_node)
        parse_book_price(book_node,:new)
      end

      def parse_used_offer_price(book_node)
        parse_book_price(book_node,:used)
      end

      def parse_new_offer_vendor_book_id(book_node)
        parse_book_ean(book_node)
      end
      alias_method :parse_used_offer_vendor_book_id, :parse_new_offer_vendor_book_id

      def parse_new_offer_vendor_offer_id(book_node)
      end
      alias_method :parse_used_offer_vendor_offer_id, :parse_new_offer_vendor_offer_id

      def parse_new_offer_detailed_condition(book_node)
      end
      alias_method :parse_used_offer_detailed_condition, :parse_new_offer_detailed_condition

      def parse_new_offer_availability(book_node)
      end
      alias_method :parse_used_offer_availability, :parse_new_offer_availability

      def parse_new_offer_shipping_time(book_node)
      end
      alias_method :parse_used_offer_shipping_time, :parse_new_offer_shipping_time

      def parse_new_offer_comments(book_node)
      end
      alias_method :parse_used_offer_comments, :parse_new_offer_comments

      def parse_new_offer_link(book_node)
        parse_node(book_node,"//div[contains(concat(' ',@class,' '),'centerLink')]")
      end
      alias_method :parse_used_offer_link, :parse_new_offer_link

      # Not in use right now
      def parse_book_new_rental_price(book_node)
      end


      def parse_book_used_rental_price(book_node)
      end

  end
end