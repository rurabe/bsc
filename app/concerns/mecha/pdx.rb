module Mecha
  class Pdx < BasicMecha

    CURRENT_TERM = '201302'

    def self.words
      %w( portland stumptown burnside voodoo zupans vikings ipa salmon microbrew rogue deschutes
          multnomah hood tabor rose omsi powells hoyt alberta mississippi ne nw sw se blazers
          timbers max portlandia bird local hazelnut blackberry 1890s 90s cascades hawthorne wonder
          crystal roseland aladdin lloyd pearl foodtruck bagdad baileys hopworks laurelwood fullsail
          widmer bike coop rain northface nike organic )
    end

    private
      # Hardpoints #
      def navigate(options = {}) #{:username => 'foo', :password => 'blah'}
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
      def login(options = {})
        username = options.fetch(:username)
        password = options.fetch(:password)
        raise Mecha::AuthenticationError, self if username.blank? || password.blank?
        login_page = @mecha.get('https://sso.pdx.edu/cas/login?service=https%3A%2F%2Fwls.banner.pdx.edu%3A443%2Fssomanager%2Fc%2FSSB')
        login_form = login_page.form
        login_form.username = username
        login_form.password = password
        login_form.submit
      end

      def navigate_to_course_schedule
        raise Mecha::AuthenticationError, self if login_failed?
        @mecha.post('https://banweb.pdx.edu/pls/oprd/bwskfshd.P_CrseSchdDetl', 'term_in' => CURRENT_TERM )
      end

      def navigate_to_books_page
        @link = @mecha.current_page.link_with(:text => 'Booklist and course materials').click
        booklist_page = @link.forms[0].submit
      end

      # Error definitions #
      def login_failed?
        @mecha.current_page.search("//*[text()[contains(.,'The credentials you provided cannot be determined to be authentic')]]").present?
      end

      # Course_data helpers #
      def build_all_courses(page)
        get_course_nodes(page).map { |course| build_course(course) }
      end

      def get_course_nodes(page)
        all_nodes = page.search("//div[@id='course-bookdisplay']//h3//span").to_a
        all_nodes.uniq { |course_node| parse_course_school_unique_id(course_node) }
      end

      # Section_data helpers #  
      def get_section_nodes(course_node)
        department = parse_course_department(course_node)
        number     = parse_course_number(course_node)
        course_node.search("//div[@id='course-bookdisplay']//h3//span[text()[contains(.,'#{department} - #{number}')]]")
      end

      # Book_data helpers #
      def get_book_nodes(section_node)
        section_node.search("//*[preceding-sibling::h3[.//span/text()='#{section_node.text}']][1]//tr[contains(concat(' ',@class,' '),'book course')]")
      end

      # Course parsers #
      def parse_course_school_unique_id(course_node)
        "#{parse_course_department(course_node)}-#{parse_course_number(course_node)}"
      end

      def parse_course_department(course_node)
        parse_result(course_node.text,/(\w+)\W+\w+/)
      end

      def parse_course_number(course_node)
        parse_result(course_node.text,/\w+\W+(\w+)/)
      end

      # Section parsers #
      def parse_section_school_unique_id(section_node)
        parse_result(section_node.text,/section (\d+)/)
      end

      def parse_section_instructor(section_node)
        parse_result(section_node.text,/\((.+)\)/)
      end

      # Book parsers #
      def parse_book_title(book_node)
        parse_node(book_node,".//*[@class='book-title']")
      end

      def parse_book_author(book_node)
        parse_node(book_node,"*[@class='book-meta book-author']")
      end

      def parse_book_ean(book_node)
        parse_node(book_node,"*[@class='isbn']")
      end

      def parse_book_edition(book_node)
        edition = parse_node(book_node,"*[@class='book-meta book-edition']")
        parse_result(edition,/Edition.(\d+)/)
      end

      def parse_book_link(book_node)
        @link.uri.to_s
      end

      def parse_book_requirement(book_node)
        parse_node(book_node,"./td[@class='book-desc']/p[starts-with(@class,'book-')]")
      end

      def parse_book_notes(book_node)
      end 

      def parse_new_offer_vendor(book_node)
        "PSU Bookstore"
      end
      alias_method :parse_used_offer_vendor, :parse_new_offer_vendor

      def parse_new_offer_price(book_node)
        price = parse_node(book_node,".//td[@class='price']/label[./../../td//text()[contains(.,'New') and not(contains(.,'Rental'))]]")
        numberize_price(price)
      end

      def parse_used_offer_price(book_node)
        price = parse_node(book_node,".//td[@class='price']/label[./../../td//text()[contains(.,'Used') and not(contains(.,'Rental'))]]")
        numberize_price(price)
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
        "Not available"
      end
      alias_method :parse_used_offer_availability, :parse_new_offer_availability

      def parse_new_offer_shipping_time(book_node)
      end
      alias_method :parse_used_offer_shipping_time, :parse_new_offer_shipping_time

      def parse_new_offer_comments(book_node)
      end
      alias_method :parse_used_offer_comments, :parse_new_offer_comments

      def parse_new_offer_link(book_node)
        parse_book_link(book_node)
      end
      alias_method :parse_used_offer_link, :parse_new_offer_link

      # Not in use right now
      def parse_offer_new_rental_price(book_node)
        price = parse_node(book_node,".//td[@class='price']/label[./../../td//text()[contains(.,'New') and contains(.,'Rental')]]")
        numberize_price(price)
      end

      def parse_offer_used_rental_price(book_node)
        price = parse_node(book_node,".//td[@class='price']/label[./../../td//text()[contains(.,'Used') and contains(.,'Rental')]]")
        numberize_price(price)
      end
  end
end