class JoinRequest < ActiveRecord::Base
  belongs_to :sender, :class_name => "User"
  belongs_to :receiver, :polymorphic => true
  belongs_to :joinable, :polymorphic => true

  after_create :create_user_notification

  class STATUS
    PENDING  = "PENDING"
    ACCEPTED = "ACCEPTED"
    REJECTED = "REJECTED"

    def self.all
      self.constants.collect {|symbol| symbol.to_s }
    end
  end

  class JOIN_TYPE
    INVITE  = "INVITE"
    REQUEST = "REQUEST"

    def self.all
      self.constants.collect {|symbol| symbol.to_s }
    end
  end

  validates_presence_of :sender_id, :join_type, :status,
                        :receiver_id, :receiver_type, :joinable_id, :joinable_type
  validates_inclusion_of :status, :in => STATUS.all
  validates_inclusion_of :join_type, :in => JOIN_TYPE.all

  after_initialize :default_values


  def self.invite(*params)
    obj = self.new(*params)
    obj.join_type = JOIN_TYPE::INVITE
    obj
  end

  def self.invite_external(*params)
    obj = self.invite(*params)
    obj.external_id = Devise.friendly_token[0,20]
    obj
  end

  def self.request(*params)
    obj = self.new(*params)
    obj.join_type = JOIN_TYPE::REQUEST
    obj
  end

  def self.has_pending_group_request?(user_id, group_id)
    pending_request = self.where(
        "sender_id = ? and
         joinable_type = 'Group' and joinable_id = ? and
         join_type = ? and
         status = ? ",

        user_id,
        group_id,
        JOIN_TYPE::REQUEST,
        STATUS::PENDING
    )

    pending_request.size > 0 ? true : false
  end

  def self.pending_projects_for_group_approval(group_id)
    self.
      where(:receiver_id => group_id).
      where(:receiver_type => "Group").
      where(:status => JoinRequest::STATUS::PENDING)
  end

  def pending?
    self.status == STATUS::PENDING
  end

  def rejected?
    self.status == STATUS::REJECTED
  end

  def request?
    self.join_type == JOIN_TYPE::REQUEST
  end

  def invite?
    self.join_type == JOIN_TYPE::INVITE
  end

  def create_project_member(user=nil)
    ProjectMember.create(
        :project => self.joinable,
        :user    => (user || self.receiver)
    )
  end

  def create_group_member_by_request
    GroupMember.create(
        :group => self.joinable,
        :user  => self.sender
    )
  end

  def create_group_member_by_invite(user=nil)
    GroupMember.create(
        :group => self.joinable,
        :user  => (user || self.receiver)
    )
  end

  def create_project_group
    ProjectGroup.create(
        :project => self.joinable,
        :group   => self.receiver
    )
  end
  
  ### interface for Request, called by UserNotificationController
  def accepted_by_user(user)
    self.status = STATUS::ACCEPTED
    self.save
    create_project_member(user) if self.joinable.instance_of? Project
    create_group_member_by_invite(user) if self.joinable.instance_of? Group and self.invite?

  end

  def yes
    self.status = STATUS::ACCEPTED
    self.save

    create_project_member if self.joinable.instance_of?(Project) and self.receiver.instance_of?(User)
    create_project_group  if self.joinable.instance_of?(Project) and self.receiver.instance_of?(Group)
    create_group_member_by_invite  if self.joinable.instance_of? Group and self.invite?
    create_group_member_by_request if self.joinable.instance_of? Group and self.request?
  end

  def no
    self.status = STATUS::REJECTED
    self.save
  end

  def title
    case self.join_type
      when JOIN_TYPE::INVITE   then "#{ self.joinable_type } Invitation"
      when JOIN_TYPE::REQUEST  then "#{ self.joinable_type} Membership Request"
      else ""
    end
  end

  def description(view)
    case self.join_type
      when JOIN_TYPE::INVITE
        then "<strong>%{sender_profile}</strong> has invited you to join %{joinable_type} <strong>'%{joinable_name}'</strong>." %
        {
            :sender_profile => view.link_to(self.sender.username, view.profile_path(self.sender)),
            :joinable_type  => self.joinable_type,
            :joinable_name  => self.joinable.title
        }

      when JOIN_TYPE::REQUEST
        then "<strong>%{sender_profile}</strong> has requested to join %{joinable_type} <strong>'%{joinable_name}'</strong>." %
        {
            :sender_profile => view.link_to(self.sender.username, view.profile_path(self.sender)),
            :joinable_type  => self.joinable_type,
            :joinable_name  => self.joinable.title
        }

      else ""
    end
  end
  
    
  ###
  protected

  def default_values
    self.status ||= STATUS::PENDING
  end

  def create_user_notification
    if self.receiver.instance_of? User
      UserNotification.actionable(
        :user => self.receiver,
        :actionable => self
      ).save
    end
  end
end
