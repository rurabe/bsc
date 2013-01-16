module Mecha
	class Pdx
		include ParserHelpers
		attr_reader :mecha, :books_page

		CURRENT_TERM = '201301'

		def self.words
		  %w( portland stumptown burnside voodoo zupans vikings ipa salmon microbrew rogue deschutes
		      multnomah hood tabor rose omsi powells hoyt alberta mississippi ne nw sw se blazers
		      timbers max portlandia bird local hazelnut blackberry 1890s 90s cascades hawthorne wonder
		      crystal roseland aladdin lloyd pearl foodtruck bagdad baileys hopworks laurelwood fullsail
		      widmer bike coop rain northface nike organic )
		end

		def initialize(options = {})
			@mecha = Mechanize.new { |mecha| mecha.follow_meta_refresh = true }
			@books_page = navigate(options)
		end

		def parse(page=@books_page)
			courses_and_books_data(page)
		end

		private

			def navigate(options = {}) #{:username => 'foo', :password => 'blah'}
				login(options)
				get_course_schedule
				get_books_page
			end

			 # Navigate helpers
			def login(options = {})
				username = options.fetch(:username)
				password = options.fetch(:password)
				raise Mecha::AuthenticationError if username.blank? || password.blank?
				login_page = @mecha.get('https://banweb.pdx.edu/pls/oprd/twbkwbis.P_WWWLogin')
				login_form = login_page.form('loginform')
				login_form.sid = username
				login_form.PIN = password
				login_form.submit
				raise Mecha::AuthenticationError if login_failed?
			end

			def get_course_schedule
				@mecha.post('https://banweb.pdx.edu/pls/oprd/bwskfshd.P_CrseSchdDetl', 'term_in' => CURRENT_TERM )
			end

			def get_books_page
				booklist_link = @mecha.current_page.link_with(:text => 'Booklist and course materials')
				booklist_submit_page = booklist_link.click
				booklist_page = booklist_submit_page.forms[0].submit
			end

			# Error definitions
			def login_failed?
				@mecha.current_page.search("//*[text()[contains(.,'Invalid User ID or Password')]]").present?
			end

			def get_course_nodes(page)
				page.search('//div[@id="course-bookdisplay"]//h3//span')
			end

			def courses_and_books_data(page)
				all_courses = courses_data(page)
				get_course_nodes(page).each do |section|
					course = all_courses.find { |course| same_course?(course,section) }
					course[:sections_attributes] << build_section(section)
				end
				all_courses
			end

			def same_course?(course,section)
				course[:department] == parse_course_department(section.text) && course[:number] == parse_course_number(section.text)
			end

			def courses_data(page)
				get_course_nodes(page).map do |course|
					build_course(course)
				end.uniq
			end

			# Parse helpers
			def collect_elements(page)
				page.search("//table[starts-with(@id,'section')]/tbody/tr[contains(concat(' ',@class,' '),'book course')] | //span[@id='course-bookdisplay-coursename']")
			end

			# Course helper methods
			def build_course(node)
				course_info = node.text
	      { :department 			 	 => parse_course_department(course_info), 
					:number 						 => parse_course_number(course_info), 
					:sections_attributes => [] }
			end

			def parse_course_department(course_info)
				parse_result(course_info,/(\S+) -/)
			end

			def parse_course_number(course_info)
				parse_result(course_info,/ - (\d+)/)
			end

			def build_section(node)
				section_info = node.text
				{	:school_unique_id => parse_section_school_unique_id(section_info),
					:instructor 			=> parse_section_instructor(section_info),
					:books_attributes => book_data(node)	}
			end

			def parse_section_school_unique_id(section_info)
				parse_result(section_info,/section (\d+)/)
			end

			def parse_section_instructor(section_info)
				parse_result(section_info,/\((.+)\)/)
			end

			def book_data(section)
				get_book_nodes(section).map { |book_node| build_book(book_node) }
			end

			def get_book_nodes(section)
				section.search("//*[preceding-sibling::h3[.//span/text()='#{section.text}']][1]//tr[contains(concat(' ',@class,' '),'book course')]")
			end

			# Book helper methods
			def build_book(node)
				{:title 											=> parse_book_title(node),
				 :author 											=> parse_book_author(node),
				 :ean 												=> parse_book_ean(node),
				 :edition 										=> parse_book_edition(node),
				 :requirement 								=> parse_book_requirement(node),
			 # :notes												=> parse_book_notes(node),
				 :bookstore_new_price 				=> parse_book_new_price(node),
				 :bookstore_new_rental_price 	=> parse_book_new_rental_price(node),
				 :bookstore_used_price 				=> parse_book_used_price(node),
				 :bookstore_used_rental_price => parse_book_used_rental_price(node)}
			end

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

			def parse_book_requirement(book_node)
				parse_node(book_node,"./td[@class='book-desc']/p[starts-with(@class,'book-')]")
			end

			def parse_book_new_price(book_node)
				price = parse_node(book_node,"./td[@class='book-pref']/table/tbody/tr[starts-with(@id,'tr-radio-sku-new')]/td[@class='price']/label")
				numberize_price(price)
			end

			def parse_book_new_rental_price(book_node)
				price = parse_node(book_node,"./td[@class='book-pref']/table/tbody/tr[starts-with(@id,'tr-radio-radio-sku-new-rental')]/td[@class='price']/label")
				numberize_price(price)
			end

			def parse_book_used_price(book_node)
				price = parse_node(book_node,"./td[@class='book-pref']/table/tbody/tr[starts-with(@id,'tr-radio-sku-used')]/td[@class='price']/label")
				numberize_price(price)
			end

			def parse_book_used_rental_price(book_node)
				price = parse_node(book_node,"./td[@class='book-pref']/table/tbody/tr[starts-with(@id,'tr-radio-radio-sku-used-rental')]/td[@class='price']/label")
				numberize_price(price)
			end
	    

	end
end