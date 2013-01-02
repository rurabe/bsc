module Mecha
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