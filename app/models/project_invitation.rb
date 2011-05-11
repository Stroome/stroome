class ProjectInvitation < ActiveRecord::Base

  belongs_to :project
  belongs_to :sender, :class_name => "User"
  belongs_to :receiver, :class_name => "User"

  after_create :generate_notification

  STATUS_ACTIVE = "active"
  STATUS_ACCEPTED = "accepted"
  STATUS_REJECTED = "rejected"

  def self.invite_existing_user(user_id, project_id, sender_id)
    entry = self.new
    entry.token       = self.generate_token
    entry.receiver_id = user_id
    entry.project_id  = project_id
    entry.sender_id   = sender_id
    entry.status      = STATUS_ACTIVE

    entry
  end

  def self.generate_token
    Digest::SHA1.hexdigest([Time.now, rand].join)
  end



  ####
  def to_notify_token
    "#{ self.class.name }:#{ self.id }"
  end

  def self.valid_notify_token?(token)
    Regexp.new("^#{ self.name }:\\d+$").match(token)
  end

  def self.process_notification(payload)
    invitation = self.find_by_notify_token(payload[:token])
    invitation.process_status(payload[:status])
  end

  def process_status(status)
    self.status = status
    self.save
    
    self.create_project_member if self.status == STATUS_ACCEPTED
  end

  def self.find_by_notify_token(valid_token)
    id = valid_token.split(":").pop
    self.find(id)
  end

  def create_project_member
    ProjectMember.create(
        :project => self.project,
        :user => self.receiver
    )
  end

  
  #######
  private


  def generate_notification

    invitation = self

    Notification.create_prompt(
        invitation.receiver,
        "Project Invitation",
        "#{ invitation.sender.username } has invited you to join Project '#{ invitation.project.title }'.",
        invitation.to_notify_token,
        [
          {:label=>"Accept", :value=> STATUS_ACCEPTED},
          {:label=>"Reject", :value=> STATUS_REJECTED}
        ]
    )

  end

end
