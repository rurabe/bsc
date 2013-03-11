class SnagMailer < ActionMailer::Base
  default from: "snag.report@booksupply.co"

  def snag_notification(snag)
    @snag = snag
    @school = snag.school
    mail( :to => 'bugs@booksupply.co', :subject => 'New snag report' )
  end
end
