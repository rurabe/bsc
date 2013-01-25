module Mecha
	class Pdx < BasicMecha

		CURRENT_TERM = '201301'

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
				raise Mecha::AuthenticationError if username.blank? || password.blank?
				login_page = @mecha.get('https://banweb.pdx.edu/pls/oprd/twbkwbis.P_WWWLogin')
				login_form = login_page.form('loginform')
				login_form.sid = username
				login_form.PIN = password
				login_form.submit
			end

			def navigate_to_course_schedule
				raise Mecha::AuthenticationError if login_failed?
				@mecha.post('https://banweb.pdx.edu/pls/oprd/bwskfshd.P_CrseSchdDetl', 'term_in' => CURRENT_TERM )
			end

			def navigate_to_books_page
				booklist_link = @mecha.current_page.link_with(:text => 'Booklist and course materials')
				booklist_submit_page = booklist_link.click
				booklist_page = booklist_submit_page.forms[0].submit
			end

			# Error definitions #
			def login_failed?
				@mecha.current_page.search("//*[text()[contains(.,'Invalid User ID or Password')]]").present?
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
				number 		 = parse_course_number(course_node)
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

			def parse_book_requirement(book_node)
				parse_node(book_node,"./td[@class='book-desc']/p[starts-with(@class,'book-')]")
			end

			def parse_book_notes(book_node)
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