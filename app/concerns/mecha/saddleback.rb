module Mecha
  class Saddleback
    include ParserHelpers
    attr_reader :mecha, :books_page

    CURRENT_TERM = '20131'
    CURRENT_TERM_TEXT = 'Spring 2013'

    def self.words
      %w( oc gauchos newport )
    end

    def initialize(options={})
      @mecha = Mechanize.new { |mecha| mecha.follow_meta_refresh = true }
      @books_page = navigate(options)
    end

    def parse(page=@books_page)
      courses_and_books_data(page)
    end

    # private

      def navigate(options={})
        login(options)
        get_courses_page
        select_current_semester
      end

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

      def get_courses_page
        @mecha.get('https://mysite.socccd.edu/Portal/MySite/Classes/CurrentClassesNew.aspx')
      end

      def select_current_semester
        page = @mecha.current_page
        key = page.form.field('ctl00$BodyContent$CurrentClasses$Semesters').options.find { |key| key.text == CURRENT_TERM_TEXT }
        page.form.field('ctl00$BodyContent$CurrentClasses$Semesters').value = key
        page.form.submit
      end

      def get_course_nodes(page)
        page.search("//table[@class='grid']/tr[contains(concat(' ',@id,' '),'PendingClasses')]")
      end

      def course_data(page)
        get_course_nodes(page).map do |course|
          build_course(course)
        end.uniq
      end

      def courses_and_books_data(page)
        threads = []
        all_courses = course_data(page)
        get_course_nodes(page).map do |section|
          course = all_courses.find { |c| same_course?(c,section) }
          threads << Thread.new { course[:sections_attributes] << build_section(section) }
        end
        threads.map { |t| t.join }
        all_courses
      end

      def same_course?(course,section)
        course[:department] == parse_course_department(section) && course[:number] == parse_course_number(section)
      end

      def build_course(node)
        { :department           => parse_course_department(node),
          :number               => parse_course_number(node),
          :sections_attributes  => [] }
      end

      def parse_course_department(node)
        string = parse_node(node,".//td[preceding-sibling::td[./span[contains(concat(' ',@id,' '),'SectionID')]]][1]")
        parse_result(string,/(\w+) \w+/)
      end

      def parse_course_number(node)
        string = parse_node(node,".//td[preceding-sibling::td[./span[contains(concat(' ',@id,' '),'SectionID')]]][1]")
        parse_result(string,/\w+ (\w+)/)
      end

      def build_section(node)
        { :school_unique_id => parse_section_unique_school_id(node),
          :instructor       => parse_section_instructor(node),
          :books_attributes => get_books(node) }
      end

      def parse_section_unique_school_id(node)
        parse_node(node,".//span[contains(concat(' ',@id,' '),'SectionID')]")
      end

      def parse_section_instructor(node)
        parse_node(node,".//span[contains(concat(' ',@id,' '),'Instructor')]")
      end

      def get_books(node)
        get_book_nodes(node).map { |node| build_book(node) }
      end

      def get_book_nodes(node)
        params = build_book_params(node)
        junk_mecha = Mechanize.new { |mecha| mecha.follow_meta_refresh = true }
        page = junk_mecha.post('http://www.bkstr.com/webapp/wcs/stores/servlet/booklookServlet',params)
        page.search(".//ul[preceding-sibling::comment()[contains(concat(' ',.,' '),'start the bookResultsInfo')]]")
      end
        
      def build_book_params(node)
        { 'bookstore_id-1' => 296,
          'term_id-1'      => CURRENT_TERM,
          'div-1'          => nil,
          'dept-1'         => parse_course_department(node),
          'course-1'       => parse_course_number(node).rjust(3,"0"),
          'section-1'      => parse_section_unique_school_id(node) }
      end

      def build_book(node)
       {  :title                       => parse_book_title(node),
          :author                      => parse_book_author(node),
          :ean                         => parse_book_ean(node),
          :edition                     => parse_book_edition(node),
          :requirement                 => parse_book_requirement(node),
        # :notes                       => parse_book_notes(node), 
          :bookstore_new_price         => parse_new_book_price(node),
          :bookstore_used_price        => parse_used_book_price(node)}
      end

      def parse_book_title(node)
        string = parse_node(node,".//li/text()[contains(.,'TITLE')]")
        parse_result(string,/TITLE:([\w ]+)/)
      end

      def parse_book_author(node)
        string = parse_node(node,".//li[contains(concat(' ',text(),' '),'AUTHOR')]")
        parse_result(string,/AUTHOR:([\w ]+)/)
      end

      def parse_book_ean(node)
        string = parse_node(node,".//li[contains(concat(' ',text(),' '),'ISBN')]")
        parse_result(string,/ISBN:(\d+)/)
      end

      def parse_book_edition(node)
        string = parse_node(node,".//li[contains(concat(' ',text(),' '),'EDITION')]")
        parse_result(string,/AUTHOR:([\w ]+)/)
      end

      def parse_book_requirement(node)
        string = parse_node(node,".//preceding::h2[preceding-sibling::comment()[contains(.,'Iterate through the material')]][1]")
        string.titlecase if string
      end

      def parse_new_book_price(node)
        string = parse_node(node,".//li[contains(concat(' ',text(),' '),'NEW')]")
        parse_result(string,/NEW:\$([\d\.]+)/)
      end

      def parse_used_book_price(node)
        string = parse_node(node,".//li[contains(concat(' ',text(),' '),'USED:')][1]")
        parse_result(string,/USED:\$([\d\.]+)/)
      end
  end
end
