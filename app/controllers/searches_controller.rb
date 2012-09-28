class SearchesController < ApplicationController

	def new
		@search = Search.new
	end

	def create
t0 = Time.now
		@search = Search.new(params[:search])
t1 = Time.now
		booklist = Mecha::PortlandState.navigate(:username => @search.username, :password => @search.password)
t2 = Time.now
		Mecha::PortlandState.create_courses_and_books(@search, booklist)
t3 = Time.now
		@search.save
t4 = Time.now
		redirect_to search_path(@search)

p "Search instantiation #{t1-t0}"
p "Navigation #{t2-t1}"
p "Object creation #{t3-t2}"
p "Object saving #{t4-t3}"
p "Total #{t4-t0}"
	end

	def show
		@search = Search.find(params[:id])
	end

	def destroy

	end

end
