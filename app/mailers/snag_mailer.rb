class SnagMailer < ActionMailer::Base
  default from: "snag.report@booksupply.co"

  def snag_notification(snag)
    @snag = snag
    mail( :to => 'bugs@booksupply.co', :subject => 'New snag report' )
  end
end
