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
      
      def navigate(options={})      
        login(options)
        get_course_schedule
        get_books_page
      end
      
      # Navigate helpers
      def login(options)
        initial_login(options)
        aes_login
      end

      def initial_login(options)
        username = options.fetch(:username)
        password = options.fetch(:password)
        raise Mecha::AuthenticationError if username.blank? || password.blank?
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

      def get_course_schedule
        @mecha.post('https://www.sis.hawaii.edu/uhdad/bwskfshd.P_CrseSchdDetl','term_in' => '201330')
      end

      def get_books_page
        raise Mecha::NoClassesError if no_classes?
        @mecha.get(bookstore_url)
      end

      # Error definitions
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

       # Encryption Helpers
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
     
      # Master parse helpers
     

      # Parsers
      def course_and_book_data(page)
        all_courses = course_data(page)
        get_course_nodes(page).map do |section|
          course = all_courses.find { |course| same_course?(course,section) }
          course[:sections_attributes] << build_section(section)
        end
        all_courses
      end

      def same_course?(course,section)
        course[:department] == parse_course_department(section.text) && course[:number] == parse_course_number(section.text)
      end

      def course_data(page)
        get_course_nodes(page).map { |c| build_course(c) }.uniq
      end

      def get_course_nodes(page)
        nodes = page.search("//div[@class='course_info']")
        raise Mecha::NoBooksError if no_books?(nodes)
        nodes
      end

      def build_course(node)
        course_info = parse_course_info(node)
        { :department          => parse_course_department(course_info), 
          :number              => parse_course_number(course_info), 
          :sections_attributes => [] }
      end

      def parse_course_info(node)
        node.search('./div[@class="term_bar"]/h2').text
      end

      def parse_course_department(course_info)
        parse_result(course_info,/Name:\s(\S+)\s/)
      end

      def parse_course_number(course_info)
        parse_result(course_info,/Name:\s\S+\s+(\d+)\w*\sSection:/)
      end

      def build_section(node)
        course_info = parse_course_info(node)
        { :school_unique_id => parse_section_school_unique_id(course_info),
          :instructor       => parse_section_instructor(course_info),
          :books_attributes => book_data(node) }
      end

      def book_data(node)
        quantity_of_books = node.search("./div[@class='material_info']").count
        quantity_of_books.times.map do |i|
          book_info_node = course_node.search("./div[@class='material_info'][#{i+1}]")
          pricing_node   = course_node.search("./div[@class='pricing_wrapper'][#{i+1}]")
          build_book(book_info_node,pricing_node)
        end
      end

      def parse_section_instructor(course_info)
        parse_result(course_info,/Instructor:\s+(\w+)\s+/)
      end

      def parse_section_school_unique_id(course_info)
        parse_result(course_info,/Course ID:\s+(\w+)\s+Location:/)
      end

      def build_book(material_info_node,pricing_node)
        { :title                       => parse_book_title(material_info_node),
          :author                      => parse_book_attribute(material_info_node,:Author),
          :ean                         => parse_book_attribute(material_info_node,:ISBN),
          :edition                     => parse_book_attribute(material_info_node,:Edition),
          :requirement                 => parse_book_requirement(material_info_node),
         #:notes                       => parse_book_notes(node)
          :bookstore_new_price         => parse_book_price(pricing_node,:new),
          :bookstore_used_price        => parse_book_price(pricing_node,:used)}
      end

      def parse_book_title(node)
        parse_node(node,'./h3')
      end

      def parse_book_attribute(node,attribute)
        parse_node(node,"./div/table/tr/td[@class='right_side']/span[../../td[@class='left_side']/text() = '#{attribute.to_s}']")
      end

      def parse_book_requirement(node)
        parse_node(node,'./div[@class="material_label"]/span')
      end

      def parse_book_price(node,condition)
        price = parse_node(node,"./div/div[@class='pricing_area']/div/div/div/p[@class='price']/span[../../p[@class='price_label']/text() = '#{condition.to_s.capitalize}']")
        numberize_price(price)
      end

      def parse_book_notes(node)
      end


      def parse_book_new_rental_price(book_node)
      end


      def parse_book_used_rental_price(book_node)
      end

  end
end