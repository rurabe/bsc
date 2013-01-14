class ApplicationController < ActionController::Base
  protect_from_forgery

  # SSL Redirects

  def https_redirect
    if ENV["ENABLE_HTTPS"] == "yes"
      if !request.ssl?
        flash.keep
        redirect_to( {:protocol => "https", :status => :moved_permanently}.merge(params) )
      end
    end
  end

  def http_redirect
    if ENV["ENABLE_HTTPS"] == "yes"
      if request.ssl?
        flash.keep
        redirect_to( {:protocol => "http", :status => :moved_permanently}.merge(params) )
      end
    end
  end

end
