
module Mecha
	class PortlandState

		def self.navigate(options = {}) #{:username => 'foo', :password => 'blah'}
			username = options.fetch(:username)
			password = options.fetch(:password)

			mecha = Mechanize.new
			mecha.follow_meta_refresh = true

			login_page = mecha.get('https://banweb.pdx.edu/pls/oprd/twbkwbis.P_WWWLogin')

			login_form = login_page.form('loginform')
				login_form.sid = username
				login_form.PIN = password

			main_page = login_form.submit

			registration_page = mecha.get('https://banweb.pdx.edu/pls/oprd/twbkwbis.P_GenMenu?name=bmenu.P_RegMnu')

			term_select_link = registration_page.link_with(:text => 'Student Detail Schedule')
			term_select_page = term_select_link.click

			term_form = term_select_page.forms[0]
			term_form.field_with(:name => 'term_in').options[0].select
			schedule_page = term_form.submit

			booklist_link = schedule_page.link_with(:text => 'Booklist and course materials')
			booklist_submit_page = booklist_link.click

			booklist_page = booklist_submit_page.forms[0].submit
		end

		def self.create_courses_and_books(search, booklist_page)
			book_list = collect_elements(booklist_page)
			courses = []
			book_list.each do |node|
				if node.name == "span"
					#then its a course!
          courses << build_course(node,search)
				elsif node.name == "tr"
					#then its a book!
					course = courses[-1]
					build_book(node,course)
				end
			end
			courses
		end

		private

			def self.collect_elements(booklist_page)
				booklist_page.search("//table[starts-with(@id,'section')]/tbody/tr[contains(concat(' ',@class,' '),'book course')] | //span[@id='course-bookdisplay-coursename']")
			end

			# Course helper methods

			def self.build_course(node, search)
				course_info = node.content

	      search.courses.build(	:department => parse_course_department(course_info), 
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
													 :isbn_13 => parse_book_isbn_13(book_node),
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

			def self.parse_book_isbn_13(book_node)
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

	end
end