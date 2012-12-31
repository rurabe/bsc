module Mecha
  class Usc
    def navigate(options={})
      username = options.fetch(:username)
      password = options.fetch(:password)

      if username.blank? || password.blank?
        raise Mecha::AuthenticationError
      end

      mecha = Mechanize.new
      mecha.follow_meta_refresh = true

      login_page = mecha.get('https://my.usc.edu/portal/Login')

      login_form = login_page.form
        login_form.j_username = username
        login_form.j_password = password
      sso_page = login_form.submit

      main_page = sso_page.form.submit


      continue_page = mecha.get("http://www.usc.edu/my2/go/?oasis")

      # continue_page.form.fields.inject({}) {|a,f| a.merge!({f.name => f.value}); a }



    end
  end
end