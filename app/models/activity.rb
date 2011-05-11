class Activity < ActiveRecord::Base
  belongs_to :subject, :polymorphic => true
  belongs_to :object, :polymorphic => true

  class EVENT
    UPLOADED  = "UPLOADED"
    JOINED    = "JOINED"
    UNJOINED  = "UNJOINED"
    CREATED   = "CREATED"
    UPDATED   = "UPDATED"
    JOINED_BY = "JOINED_BY"

    def self.all
      self.constants.collect {|symbol| symbol.to_s }
    end
  end

  MESSAGES = {
      EVENT::UPLOADED => "%{subject_name} uploaded a %{object_type}.",
      EVENT::JOINED   => "%{subject_name} has joined a %{object_type}.",
      EVENT::UNJOINED => "%{subject_name} has unjoined a %{object_type}.",
      EVENT::CREATED  => "%{subject_name} created a %{object_type}.",
      EVENT::UPDATED  => "%{subject_name} updated a %{object_type}.",
      EVENT::JOINED_BY => "%{object_name} has joined %{subject_type} '%{subject_name}'  ."
  }


  FILTERS = {
    "ALL" => "all",
    "MEMBERS" => "user",
    "PROJECTS" => "project",
    "CLIPS" => "clip",
    "GROUPS" => "group"
  }

  GROUP_STREAM_FILTER_OPTIONS = FILTERS.collect do |k, v|
    [k, v] if k != "GROUPS"
  end.compact

  USER_STREAM_FILTER_OPTIONS = FILTERS.collect do |k, v|
    [k, v] if k != "MEMBERS"
  end.compact

  FOLLOW_STREAM_FILTER_OPTIONS = FILTERS.collect do |k, v|
    [k, v]
  end.compact



  validates_presence_of :subject_id, :subject_type,
                        :object_id, :object_type,
                        :event

  validates_inclusion_of :event, :in => EVENT.all


  ## Display purpose

  def title
    object.title
  end

  def picture_url
    object.picture_url
  end

  def message
    MESSAGES[ event ] % {
        :subject_name => subject.title,
        :subject_type => subject_type.downcase,
        :object_name  => object.title,
        :object_type  => object_type.downcase
    }
  end


  ## Create activities

  def self.uploaded(user, clip)
    store user, EVENT::UPLOADED, clip
  end

  def self.joined(user, group)
    store user, EVENT::JOINED, group
    store group, EVENT::JOINED_BY, user
  end

  def self.joined_by_project(group, project)
    store group, EVENT::JOINED_BY, project
  end

  def self.unjoined(user, group)
    store user, EVENT::UNJOINED, group
  end

  def self.created(user, project)
    store user, EVENT::CREATED, project
  end

  def self.updated(user, project)
    store user, EVENT::UPDATED, project
  end


  def self.store(subject, event, object)
    Activity.create(
        :subject => subject,
        :event   => event,
        :object  => object
    )
  end

  scope :recent_user_stream,   lambda {|user, filter|  user_stream(user).filter(filter).recent   }
  scope :recent_group_stream,  lambda {|group, filter| group_stream(group).filter(filter).recent }
  scope :recent_follow_stream, lambda {|user, filter|  follow_stream(user).filter(filter).recent }
  
  scope :follow_stream, lambda {|user|
    users = user.followed_users
    groups = user.followed_groups
    project_ids = []
    member_ids  = []

    groups.each {|g| project_ids |= g.project_ids }
    groups.each {|g| member_ids |= g.member_ids }

    where("
         (subject_type = 'User'    and subject_id in (?))
      or (subject_type = 'Group'   and subject_id in (?))
      or (object_type  = 'Project' and event = ? and object_id  in (?))
      or (subject_type = 'User'    and event = ? and subject_id in (?))
    ", users.collect {|u| u.id },
       groups.collect {|g| g.id},
       EVENT::UPDATED, project_ids,
       EVENT::UPLOADED, member_ids

    )
  }
  scope :user_stream, lambda {|user| where("subject_type = 'User' and subject_id = ?", user.id) }
  scope :group_stream, lambda { |group|
    where("
         (subject_type = 'Group'  and subject_id = ?)
      or (object_type = 'Project' and event = ? and object_id in (?))
      or (subject_type = 'User'   and event = ? and subject_id in (?))
    ", group.id,
       EVENT::UPDATED , group.project_ids,
       EVENT::UPLOADED, group.member_ids
    )
  }

  scope :filter, lambda {|filter| filter.downcase == "all" ? scoped : where("object_type = ?", filter.titlecase) }
  scope :recent, where("created_at >= ?", 2.weeks.ago).order("created_at DESC")


end
