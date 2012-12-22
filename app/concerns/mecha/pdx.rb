module Mecha
	class Pdx

		def self.words
		  %w( portland stumptown burnside voodoo zupans vikings viking salmon microbrew rogue deschutes
		      multnomah hood tabor rose omsi powells hoyt alberta mississippi ne nw sw se blazers
		      timbers max portlandia bird local hazelnut blackberry 1890s 90s cascades hawthorne wonder
		      crystal roseland aladdin lloyd pearl foodtruck bagdad baileys hopworks laurelwood fullsail
		      widmer bike )
		end

		def self.execute(options = {}) #{:username => 'foo', :password => 'blah', :booklist => #<booklist>}
			username 	= options.fetch(:username)
			password 	= options.fetch(:password)
			booklist 		= options.fetch(:booklist)

			booklist_page = navigate(:username => username, :password => password)
			create_courses_and_books(:booklist => booklist,:page => booklist_page)
		end

		private

			def self.navigate(options = {}) #{:username => 'foo', :password => 'blah'}

				username = options.fetch(:username)
				password = options.fetch(:password)

				if username.blank? || password.blank?
					raise Mecha::AuthenticationError
				end

				mecha = Mechanize.new
				mecha.follow_meta_refresh = true

				login_page = mecha.get('https://banweb.pdx.edu/pls/oprd/twbkwbis.P_WWWLogin')

				login_form = login_page.form('loginform')
				login_form.sid = username
				login_form.PIN = password
				
				main_page = login_form.submit

				if login_failed?(main_page)
					raise Mecha::AuthenticationError
				end

				registration_page = mecha.get('https://banweb.pdx.edu/pls/oprd/twbkwbis.P_GenMenu?name=bmenu.P_RegMnu')

				term_select_link = registration_page.link_with(:text => 'Student Detail Schedule')
				term_select_page = term_select_link.click

				term_form = term_select_page.forms[0]
				term_field = term_form.field_with(:name => 'term_in')
					available_terms = term_field.options.map(&:text)
					latest_term = available_terms.find_index {|term| term =~ /Winter 2013/i }
				term_field.options[latest_term].select
				schedule_page = term_form.submit

				booklist_link = schedule_page.link_with(:text => 'Booklist and course materials')
				booklist_submit_page = booklist_link.click

				booklist_page = booklist_submit_page.forms[0].submit
			end

			def self.create_courses_and_books(options = {}) #{:booklist => #<booklist>, :page => #<Mechanize::Page>}
				booklist 			= options.fetch(:booklist)
				booklist_page = options.fetch(:page)

				book_list = collect_elements(booklist_page)
				courses = []
				books = []
				book_list.each do |node|
					if node.name == "span"
						#then its a course!
	          courses << build_course(node,booklist)
					elsif node.name == "tr"
						#then its a book!
						course = courses[-1]
						books << build_book(node,course)
					end
				end
				{:courses => courses, :books => books}
			end

			def self.collect_elements(booklist_page)
				booklist_page.search("//table[starts-with(@id,'section')]/tbody/tr[contains(concat(' ',@class,' '),'book course')] | //span[@id='course-bookdisplay-coursename']")
			end

			# Course helper methods

			def self.build_course(node, booklist)
				course_info = node.content

	      booklist.courses.build(	:department => parse_course_department(course_info), 
			 												:number => parse_course_number(course_info), 
														  :section => parse_course_section(course_info), 
			 												:instructor => parse_course_instructor(course_info))
			end

			def self.parse_course_department(course_info)
				parse_result(course_info,/(\S+) -/)
			end

			def self.parse_course_number(course_info)
				parse_result(course_info,/ - (\d+)/)
			end

			def self.parse_course_section(course_info)
				parse_result(course_info,/section (\d+)/)
			end

			def self.parse_course_instructor(course_info)
				parse_result(course_info,/\((.+)\)/)
			end

			# Book helper methods

			def self.build_book(book_node,course)
				course.books.build(:title => parse_book_title(book_node),
													 :author => parse_book_author(book_node),
													 :ean => parse_book_ean(book_node),
													 :edition => parse_book_edition(book_node),
													 :requirement => parse_book_requirement(book_node),
													 :bookstore_new_price => parse_book_new_price(book_node),
													 :bookstore_new_rental_price => parse_book_new_rental_price(book_node),
													 :bookstore_used_price => parse_book_used_price(book_node),
													 :bookstore_used_rental_price => parse_book_used_rental_price(book_node))
			end

			def self.parse_book_title(book_node)
				parse_node(book_node,"*[@class='book-title']")
			end

			def self.parse_book_author(book_node)
				parse_node(book_node,"*[@class='book-meta book-author']")
			end

			def self.parse_book_ean(book_node)
				parse_node(book_node,"*[@class='isbn']")
			end

			def self.parse_book_edition(book_node)
				edition = parse_node(book_node,"*[@class='book-meta book-edition']")
				parse_result(edition,/Edition.(\d+)/)
			end

			def self.parse_book_requirement(book_node)
				parse_node(book_node,"./td[@class='book-desc']/p[starts-with(@class,'book-')]")
			end

			def self.parse_book_new_price(book_node)
				price = parse_node(book_node,"./td[@class='book-pref']/table/tbody/tr[starts-with(@id,'tr-radio-sku-new')]/td[@class='price']/label")
				numberize_price(price)
			end

			def self.parse_book_new_rental_price(book_node)
				price = parse_node(book_node,"./td[@class='book-pref']/table/tbody/tr[starts-with(@id,'tr-radio-radio-sku-new-rental')]/td[@class='price']/label")
				numberize_price(price)
			end

			def self.parse_book_used_price(book_node)
				price = parse_node(book_node,"./td[@class='book-pref']/table/tbody/tr[starts-with(@id,'tr-radio-sku-used')]/td[@class='price']/label")
				numberize_price(price)
			end

			def self.parse_book_used_rental_price(book_node)
				price = parse_node(book_node,"./td[@class='book-pref']/table/tbody/tr[starts-with(@id,'tr-radio-radio-sku-used-rental')]/td[@class='price']/label")
				numberize_price(price)
			end

			# Parsing helpers

			def self.parse_node(node,xpath)
				result = node.search(xpath).first
				result.content if result
			end

			def self.parse_result(string,regex)
				match = string.match(regex) if string
				match[1] if match
			end

			def self.numberize_price(string)
				if string =~ /\$/
					number = string.gsub("$","")
					BigDecimal.new(number)
				else
					nil
				end
			end

			# Error handling

			def self.login_failed?(page)
				if page.search("//*[text()[contains(.,'Invalid User ID or Password')]]").empty?
					false
				else
					true
				end
			end

	end
end