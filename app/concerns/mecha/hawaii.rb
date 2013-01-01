module Mecha
  class Hawaii

    def self.words
      %w(rainbow warriors manoa aloha dole metcalf stansheriff kuykendall klum murakami anuenue 
         halawai kahawai kuahine laulima noelani wainani hamilton)
    end

    def initialize(options={})
      @booklist_page = navigate(options)
    end

    def parse(page)
      courses = get_course_nodes(page)
      courses.map do |course|
        course_hash = build_course(course)
        course_hash[:books_attributes].replace(parse_course_books(course))
        course_hash
      end
    end

    private
      
      def navigate(options={})      
        username = options.fetch(:username)
        password = options.fetch(:password)

        if username.blank? || password.blank?
          raise Mecha::AuthenticationError
        end

        mecha = Mechanize.new
        mecha.follow_meta_refresh = true

        login_page = mecha.get('https://www.sis.hawaii.edu/uhdad/twbkwbis.P_WWWLogin')

        login_form = login_page.form('uhloginform')
          login_form.sid = username
          login_form.pin = password
        aes_page = login_form.submit

        aes_login_form = aes_page.form('loginform')

        key    = aes_key_from_cookies(mecha.cookie_jar.jar)
        cipher = aes_page.form.field('cipherhex').value

        main_page = mecha.post('https://www.sis.hawaii.edu/uhdad/twbkwbis.P_ValLogin', aes_decrypt(key,cipher))

        course_detail_page = mecha.post('https://www.sis.hawaii.edu/uhdad/bwskfshd.P_CrseSchdDetl','term_in' => '201330')

        bookstore_page = mecha.get(bookstore_url(course_detail_page))
      end

      # Master parse helpers
      def parse_course_books(course_node)
        quantity_of_books = course_node.search("./div[@class='material_info']").count
        quantity_of_books.times.map do |i|
          book_info_node = course_node.search("./div[@class='material_info'][#{i+1}]")
          pricing_node   = course_node.search("./div[@class='pricing_wrapper'][#{i+1}]")
          build_book(book_info_node,pricing_node)
        end
      end

      # Bookstore Url Generator
      def bookstore_url(page)
        'http://www.bookstore.hawaii.edu/manoa/SelectCourses.aspx?src=2&type=2&stoid=105&trm=SPRING%2013&cid=' + get_crns(page).to_s
      end

        def get_crns(page)
          nodes = page.search("//td[../th[@class='ddlabel']/acronym/text()[.='CRN']]")
          nodes.map { |node| node.content }.join(",") if nodes.present?
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
        match_data = data.match /\d+ (\w+)\t(\w+)<*/
        { :sid => match_data[1], :pin => match_data[2] }
      end

      # Parsers
      def get_course_nodes(page)
        page.search("//div[@class='course_info']")
      end

      def get_isbns(page)
        page.search('//td/span[../../td[@class="left_side"]/text()[.="ISBN"]]')
      end

      def build_course(node)
        course_info = node.search('./div[@class="term_bar"]/h2').text
        { :department       => parse_course_department(course_info), 
          :number           => parse_course_number(course_info), 
          :section          => parse_course_section(course_info), 
          :instructor       => parse_course_instructor(course_info),
          :school_unique_id => parse_school_unique_id(course_info),
          :books_attributes => [] }
      end

      def parse_course_department(course_info)
        parse_result(course_info,/Name:\s(\S+)\s/)
      end

      def parse_course_number(course_info)
        parse_result(course_info,/Name:\s\S+\s+(\S+)\sSection:/)
      end

      def parse_course_section(course_info)
        parse_result(course_info,/Section:\s+\d+\s+(\w+)/)
      end

      def parse_course_instructor(course_info)
        parse_result(course_info,/Instructor:\s+(\w+)\s+/)
      end

      def parse_school_unique_id(course_info)
        parse_result(course_info,/Course ID:\s+(\w+)\s+Location:/)
      end

      def build_book(material_info_node,pricing_node)
        { :title                       => parse_book_title(material_info_node),
          :author                      => parse_book_attribute(material_info_node,:Author),
          :ean                         => parse_book_attribute(material_info_node,:ISBN),
          :edition                     => parse_book_attribute(material_info_node,:Edition),
          :requirement                 => parse_book_requirement(material_info_node),
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

      # Parse helpers
      def parse_node(node,xpath)
        result = node.search(xpath).first
        result.text.strip if result
      end

      def parse_result(string,regex)
        match = string.match(regex) if string
        match[1].strip if match
      end

      def numberize_price(string)
        if string =~ /\$/
          number = string.gsub("$","")
          BigDecimal.new(number)
        else
          nil
        end
      end

  end
end