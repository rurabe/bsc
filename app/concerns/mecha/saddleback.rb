module Mecha
  class Saddleback < BasicMecha


    CURRENT_TERM = '20131'
    CURRENT_TERM_TEXT = 'Spring 2013'

    def self.words
      %w( oc gauchos newport mission viejo ladera lasflores avery marguerite south mysite crown
          lakeforest eltoro trabuco cotodecaza cardinal gold college arroyo library capistrano quad
          orange )
    end

    private
      # Hardpoints #
      def navigate(options={})
        login(options)
        navigate_to_courses_page
        navigate_to_current_semester
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
        form = @mecha.get('https://mysite.socccd.edu/Portal/Default.aspx').form
        @mecha.post('https://mysite.socccd.edu/Portal/Default.aspx?code=1',build_login_params(form,options))
      end

      def build_login_params(form,options={})
        { '_LASTFOCUS'        => nil,
          '_SCROLLPOS'        => '0|0',
          '__EVENTTARGET'     => nil,
          '__EVENTARGUMENT'   => nil,
          '__VIEWSTATE'       => form.field('__VIEWSTATE').value,
          '__EVENTVALIDATION' => form.field('__EVENTVALIDATION').value,
          'UserName'          => options.fetch(:username),
          'Password'          => options.fetch(:password),
          'LoginUser.x'       => 0,
          'LoginUser.y'       => 0 }
      end

      def navigate_to_courses_page
        @mecha.get('https://mysite.socccd.edu/Portal/MySite/Classes/CurrentClassesNew.aspx')
      end

      def navigate_to_current_semester
        page = @mecha.current_page
        key = page.form.field('ctl00$BodyContent$CurrentClasses$Semesters').options.find { |key| key.text == CURRENT_TERM_TEXT }
        page.form.field('ctl00$BodyContent$CurrentClasses$Semesters').value = key
        page.form.submit
      end

      # Course_data helpers #
      def build_all_courses(page)
        threads = []
        get_course_nodes(page).map do |course|
          threads << Thread.new { build_course(course) }
        end
        threads.map { |t| t.join.value }
      end

      def get_course_nodes(page)
        all_nodes = page.search("//table[@class='grid']/tr[contains(concat(' ',@id,' '),'PendingClasses')]").to_a
        all_nodes.uniq { |course_node| parse_course_school_unique_id(course_node) }
      end

      # Section_data helpers #
      def get_section_nodes(course_node)
        department = parse_course_department(course_node)
        number     = parse_course_number(course_node)
        course_node.search("//table[@class='grid']/tr[contains(concat(' ',@id,' '),'PendingClasses') and contains(.,'#{department} #{number}')]")
      end

      # Book_data helpers #
      def get_book_nodes(node)
        page = query_for_book(node)
        page.search(".//ul[preceding-sibling::comment()[contains(concat(' ',.,' '),'start the bookResultsInfo')]]")
      end

      def query_for_book(node)
        junk_mecha = Mechanize.new { |mecha| mecha.follow_meta_refresh = true }
        page = junk_mecha.post('http://www.bkstr.com/webapp/wcs/stores/servlet/booklookServlet',build_book_params(node))
      end
        
      def build_book_params(node)
        { 'bookstore_id-1' => 296,
          'term_id-1'      => CURRENT_TERM,
          'div-1'          => nil,
          'dept-1'         => parse_course_department(node),
          'course-1'       => parse_course_number(node).rjust(3,"0"),
          'section-1'      => parse_section_school_unique_id(node) }
      end

      # Course parsers #
      def parse_course_school_unique_id(course_node)
        "#{parse_course_department(course_node)}-#{parse_course_number(course_node)}"
      end

      def parse_course_department(course_node)
        string = parse_node(course_node,".//td[preceding-sibling::td[./span[contains(concat(' ',@id,' '),'SectionID')]]][1]")
        parse_result(string,/(\w+) \w+/)
      end

      def parse_course_number(course_node)
        string = parse_node(course_node,".//td[preceding-sibling::td[./span[contains(concat(' ',@id,' '),'SectionID')]]][1]")
        parse_result(string,/\w+ (\w+)/)
      end

      # Section parsers #
      def parse_section_school_unique_id(section_node)
        parse_node(section_node,".//span[contains(concat(' ',@id,' '),'SectionID')]")
      end

      def parse_section_instructor(section_node)
        parse_node(section_node,".//span[contains(concat(' ',@id,' '),'Instructor')]")
      end

      # Book parsers #
      def parse_book_title(book_node)
        string = parse_node(book_node,".//li/text()[contains(.,'TITLE')]")
        parse_result(string,/TITLE:(.+)/)
      end

      def parse_book_author(book_node)
        string = parse_node(book_node,".//li[contains(concat(' ',text(),' '),'AUTHOR')]")
        parse_result(string,/AUTHOR:([\w ]+)/)
      end

      def parse_book_ean(book_node)
        string = parse_node(book_node,".//li[contains(concat(' ',text(),' '),'ISBN')]")
        parse_result(string,/ISBN:(\d+)/)
      end

      def parse_book_edition(book_node)
        string = parse_node(book_node,".//li[contains(concat(' ',text(),' '),'EDITION')]")
        parse_result(string,/AUTHOR:([\w ]+)/)
      end

      def parse_book_requirement(book_node)
        string = parse_node(book_node,".//preceding::*[(self::h2 or self::h3) and following::comment()[contains(.,'retrieve material')]][1]")
        requirement = parse_result(string,/(required|choose|recommended|optional)/im) if string
        requirement.titlecase if requirement
      end

      def parse_book_notes(book_node)
      end

      def parse_book_new_price(book_node)
        string = parse_node(book_node,".//li[contains(concat(' ',text(),' '),'NEW')]")
        parse_result(string,/NEW:\$([\d\.]+)/)
      end

      def parse_book_used_price(book_node)
        string = parse_node(book_node,".//li[contains(concat(' ',text(),' '),'USED:')][1]")
        parse_result(string,/USED:\$([\d\.]+)/)
      end

      def parse_book_new_rental_price(book_node)
      end


      def parse_book_used_rental_price(book_node)
      end
  end
end
