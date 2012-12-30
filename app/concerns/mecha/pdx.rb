module Mecha
	class Pdx

		def self.words
		  %w( portland stumptown burnside voodoo zupans vikings ipa salmon microbrew rogue deschutes
		      multnomah hood tabor rose omsi powells hoyt alberta mississippi ne nw sw se blazers
		      timbers max portlandia bird local hazelnut blackberry 1890s 90s cascades hawthorne wonder
		      crystal roseland aladdin lloyd pearl foodtruck bagdad baileys hopworks laurelwood fullsail
		      widmer bike coop rain northface nike organic )
		end

		def initialize(options = {})
			@booklist_page = navigate(options)
		end

		def parse
			courses = []
			active_course = nil
			collect_elements.each do |e|
				if e.name == "span"
					#course
					active_course = build_course(e)
					courses << active_course
				elsif e.name == "tr"
					#book
					active_course[:books_attributes] << build_book(e)
				end
			end
			courses
		end

		private

			def navigate(options = {}) #{:username => 'foo', :password => 'blah'}
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

				schedule_page = mecha.post('https://banweb.pdx.edu/pls/oprd/bwskfshd.P_CrseSchdDetl', 'term_in' => '201301')

				booklist_link = schedule_page.link_with(:text => 'Booklist and course materials')
				booklist_submit_page = booklist_link.click

				booklist_page = booklist_submit_page.forms[0].submit
			end

			def collect_elements
				@booklist_page.search("//table[starts-with(@id,'section')]/tbody/tr[contains(concat(' ',@class,' '),'book course')] | //span[@id='course-bookdisplay-coursename']")
			end

			# Course helper methods
			def build_course(node)
				course_info = node.content
	      { :department => parse_course_department(course_info), 
					:number => parse_course_number(course_info), 
			  	:section => parse_course_section(course_info), 
					:instructor => parse_course_instructor(course_info),
					:books_attributes => [] }
			end

			def parse_course_department(course_info)
				parse_result(course_info,/(\S+) -/)
			end

			def parse_course_number(course_info)
				parse_result(course_info,/ - (\d+)/)
			end

			def parse_course_section(course_info)
				parse_result(course_info,/section (\d+)/)
			end

			def parse_course_instructor(course_info)
				parse_result(course_info,/\((.+)\)/)
			end

			# Book helper methods
			def build_book(node)
				{:title => parse_book_title(node),
				 :author => parse_book_author(node),
				 :ean => parse_book_ean(node),
				 :edition => parse_book_edition(node),
				 :requirement => parse_book_requirement(node),
				 :bookstore_new_price => parse_book_new_price(node),
				 :bookstore_new_rental_price => parse_book_new_rental_price(node),
				 :bookstore_used_price => parse_book_used_price(node),
				 :bookstore_used_rental_price => parse_book_used_rental_price(node)}
			end

			def parse_book_title(book_node)
				parse_node(book_node,"*[@class='book-title']")
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

			# Parse helpers
			def parse_node(node,xpath)
				result = node.search(xpath).first
				result.content if result
			end

			def parse_result(string,regex)
				match = string.match(regex) if string
				match[1] if match
			end

			def numberize_price(string)
				if string =~ /\$/
					number = string.gsub("$","")
					BigDecimal.new(number)
				else
					nil
				end
			end

			# Error handling
			def login_failed?(page)
				page.search("//*[text()[contains(.,'Invalid User ID or Password')]]").present?
			end
	end
end