module Mecha
  class BasicMecha
    # BasicMecha is the template for all other mechas. Mechas are designed to be different,
    # but many parts of the mecha are shared and are thus defined here.

    # It does mean, however, that there needs to be careful coordination between what is defined
    # in this file versus in other files. Here are the interface points:

    # Methods all mecha need
    #   -navigate: takes login info and returns courses_page
    #   -course_data: takes the courses_page and returns struc. data
    #   -section_data: takes the course_node and returns struc. data ab sections
    #   -book_data: takes the section node and returns struc. data about books


    attr_reader :mecha, :courses_page
    
    def initialize(options = {})
      @mecha = Mechanize.new { |mecha| mecha.follow_meta_refresh = true }
      @courses_page = navigate(options)
    end

    def parse(page=@courses_page)
      course_data(page)
    end

    private

      def build_course(course_node)
        { :school_unique_id           => parse_course_school_unique_id(course_node),
          :department                 => parse_course_department(course_node), 
          :number                     => parse_course_number(course_node), 
          :sections_attributes        => section_data(course_node) }
      end

      def build_section(section_node)
        { :school_unique_id           => parse_section_school_unique_id(section_node),
          :instructor                 => parse_section_instructor(section_node),
          :books_attributes           => book_data(section_node)  }
      end

      def build_book(book_node)
        {:title                       => parse_book_title(book_node),
         :author                      => parse_book_author(book_node),
         :ean                         => parse_book_ean(book_node),
         :edition                     => parse_book_edition(book_node),
         :requirement                 => parse_book_requirement(book_node),
         :notes                       => parse_book_notes(book_node),
         :bookstore_new_price         => parse_book_new_price(book_node),
         :bookstore_new_rental_price  => parse_book_new_rental_price(book_node),
         :bookstore_used_price        => parse_book_used_price(book_node),
         :bookstore_used_rental_price => parse_book_used_rental_price(book_node)}
      end

      # Parser helper methods
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
          BigDecimal.new(number) if number.to_f > 0
        else
          nil
        end
      end
  end


	class AuthenticationError < StandardError
		def message
			"There was an error with your username or password. You might want to check that out and try again."
		end
	end

  class NoClassesError < StandardError
    def message
      "The system is reporting that you aren't registered for any classes. Check to make sure you're signed up and come back!"
    end
  end

  class ClassesNotInSystemError < StandardError
    def message
      "Sorry! We can't find your classes in the system. We can only find books for classes in the system."
    end
  end

  class ServiceDownError < StandardError
    def message
      "It looks like the school's website is down right now (and we need it to do our magic). Check back soon and it should be working again."
    end
  end

  class NoBooksError < StandardError
    def message
      "It doesn't look like you have any books listed for your courses (or they haven't been posted yet)."
    end
  end
end