class InviteOthersMailer < ActionMailer::Base
  default :from => "info@stroome.com"

  def invite_join_project(invitation)
    @sender_name = invitation.sender.fullname.blank? ? invitation.sender.username : invitation.sender.fullname
    @potential_user_name = invitation.receiver.name
    @project_title = invitation.joinable.title
    @sign_up_link = new_user_registration_url(:invite => invitation.external_id)
    
    mail(
        :to => invitation.receiver.email,
        :subject => invitation.title
    )
  end

  def invite_join_group(invitation)
    @sender_name = invitation.sender.fullname.blank? ? invitation.sender.username : invitation.sender.fullname
    @potential_user_name = invitation.receiver.name
    @group_title = invitation.joinable.title
    @sign_up_link = new_user_registration_url(:invite => invitation.external_id)

    mail(
        :to => invitation.receiver.email,
        :subject => invitation.title
    )
  end
end
