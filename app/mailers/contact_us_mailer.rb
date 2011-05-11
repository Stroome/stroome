class ContactUsMailer < ActionMailer::Base

  def submit_question(msg)
    @msg = msg
    mail(
        :from => msg.email,
        :to => Setting.get(Setting::CONTACT_EMAIL, "admin@stroome.com"),
        :subject => "Question from #{ msg.first_name } via Contact Us",
        :reply_to => msg.email )
  end
end
