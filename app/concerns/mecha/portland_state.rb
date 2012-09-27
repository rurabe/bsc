
module Mecha
	class PortlandState
		def self.navigate(options = {}) #{:user => 'foo', :password => 'blah'}
			user = options.fetch(:user)
			password = options.fetch(:password)

			mecha = Mechanize.new
			mecha.follow_meta_refresh = true

			login_page = mecha.get('https://banweb.pdx.edu/pls/oprd/twbkwbis.P_WWWLogin')

			login_form = login_page.form('loginform')
				login_form.sid = user
				login_form.PIN = password

			main_page = login_form.submit

			student_services_link = main_page.link_with(:text => 'Student Services & Financial Aid')
			student_services_page = student_services_link.click

			registration_link = student_services_page.link_with(:text => 'Registration')
			registration_page = registration_link.click

			term_select_link = registration_page.link_with(:text => 'Student Detail Schedule')
			term_select_page = term_select_link.click

			term_form = term_select_page.forms[0]
			term_form.field_with(:name => 'term_in').options[0].select
			schedule_page = term_form.submit

			booklist_link = schedule_page.link_with(:text => 'Booklist and course materials')
			booklist_submit_page = booklist_link.click

			booklist_page = booklist_submit_page.forms[0].submit
		end

		def self.create_classes_and_books(booklist_page)
			book_list = booklist_page.search("//table[starts-with(@id,'section')]/tbody/tr[contains(concat(' ',@class,' '),'book course')] | //span[@id='course-bookdisplay-coursename']")

			book_list.each do |node|
				if node.name == "span"
					#then its a course!
					course_info = node.content

          department = course_info.match(/(\S+) -/)[1]
          number = course_info.match(/ - (\d+)/)[1]
          section = course_info.match(/section (\d+)/)[1]
          if instructor_string = course_info.match(/\((.+)\)/)
          	instructor = instructor_string[1]
          end

          p "#{department}, #{number}, #{section}, #{instructor}"

				elsif node.name == "tr"
					#then its a book!
					title = node.search("*[@class='book-title']").first.content
					author = node.search("*[@class='book-meta book-author']").first.content
					isbn_13 = node.search("*[@class='isbn']").first.content
					if !node.search("*[@class='book-meta book-edition']").empty?
            edition = node.search("*[@class='book-meta book-edition']").first.content.match(/Edition.(\d+)/)[1]
          end
          requirement = node.search("./td[@class='book-desc']/p[starts-with(@class,'book-')]").first.content
					
					p "#{title}, #{author}, #{isbn_13}, #{edition}, #{requirement}"
				end
			end

		end

	end
end