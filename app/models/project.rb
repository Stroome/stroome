require 'projects_helper'

class Project < ActiveRecord::Base
  include ActionController::UrlWriter
  default_url_options[:host] = Rails.configuration.action_mailer.default_url_options[:host]

  
  after_initialize :default_values
  before_create SyncWithVideoService.new(KalturaVideoService.new(C.kaltura))
  before_update :update_video_mix
  before_destroy :destroy_video_mix

  after_create :update_stats_project_created
  after_destroy :update_stats_project_destroyed

  after_create :update_activity_stream_on_created
  after_update :update_activity_stream_on_updated

  belongs_to :user
  has_and_belongs_to_many :topics
  has_and_belongs_to_many :clips, :after_add => :project_clip_added, :after_remove => :project_clip_removed


  belongs_to :remixed_from, :class_name => "Project"
  has_many :remixes, :class_name => "Project",
           :foreign_key => 'remixed_from_id'

  has_many :comments

  has_many :project_members
  has_many :members, :through => :project_members, :source => :user

  has_many :project_groups
  has_many :groups, :through => :project_groups, :source => :group

  has_many :project_invitations

  has_many :join_requests, :as => :joinable

  is_impressionable

  ajaxful_rateable :stars => 5, :cache_column => 'rating'

  attr_accessor :with_clip_video_id


  VISIBILITY_PUBLIC = 'public'
  VISIBILITY_PRIVATE = 'private'
  VISIBILITY_OPTIONS = [
    ['Public', VISIBILITY_PUBLIC],
    ['Private', VISIBILITY_PRIVATE]
  ]

  EDITOR_TYPE_BASIC = "basic"
  EDITOR_TYPE_ADVANCED = "advanced"


  validates_presence_of :title, :description, :user_id
  # TODO validates editor_type

  def can_accessed_by_user?(user)
    if user.nil?
      return is_public?
    end

    is_public? or
        ( is_private? and project_member?(user) ) or
        ( is_private? and project_owner?(user) ) or
        ( is_private? and not (groups & user.groups).empty? )
  end

  def video_updated_recently?
    not self.video_updated_at.nil? and
    self.video_updated_at > 1.minute.ago
  end

  def picture_url
    thumbnail_url
  end
  
  def is_public?
    self.visibility == VISIBILITY_PUBLIC
  end

  def is_private?
    self.visibility == VISIBILITY_PRIVATE
  end

  def can_invite?(user_or_group)
    not ( joined?(user_or_group) or already_invited?(user_or_group) )
  end

  def joined?(user_or_group)
    if user_or_group.instance_of? User
      user = user_or_group
      project_owner?(user) or
          project_member?(user)

    elsif user_or_group.instance_of? Group
      group = user_or_group
      self.groups.include? group

    else
      false
      
    end
  end

  def project_owner?(user)
    (not user.blank? and user.id == self.user_id)
  end

  def project_member?(user)
    self.members.select {|member| member.id == user.id }.size() > 0
  end

  def already_invited?(receiver)
    results = self.join_requests.select do |request|
      request.pending? and
      request.receiver_id == receiver.id and
      request.receiver_type == receiver.class.name
    end

    results.size() > 0
  end

  def duration_in_mins
    total_minutes = duration / 1.minutes
    seconds_in_last_minute = duration - total_minutes.minutes.seconds
    "#{total_minutes}:#{seconds_in_last_minute.to_s.rjust(2, '0')} mins"
  end

  # TODO temp fix
  def total_views
    migrated_total = read_attribute(:total_views)
    migrated_total ||= 0

    new_total = self.unique_impression_count_session
    new_total ||= 0

    migrated_total + new_total
  end
  
  def total_members
    1 + self.members.size() # owner + members
  end

  def total_groups
    self.groups.size()
  end

  ####
  def increment_total_remixed
    self.total_remixed ||= 0
    self.total_remixed += 1
  end

  def decrement_total_remixed
    self.total_remixed ||= 0
    self.total_remixed -= 0
    self.total_remixed = 0 if self.total_remixed  <0
  end

  #####
  def clone_for_remix
    project = self.clone

    project.remixed_from = self
    project.topics = self.topics
    project.reset_stats
    project.reset_video_info

    project
  end

  def reset_stats
    self.total_members = 1
    self.total_remixed = 0
    self.total_shared = 0
    self.total_likes = 0
    self.total_views = 0
    self.total_rating_votes = 0
    self.rating = 0
  end

  def reset_video_info
    self.duration = 0
    self.video_id = nil
    self.thumbnail_url = nil
  end


  #####
  searchable do
    # free-text search
    text :title, :boost => 10.0, :more_like_this => true
    text :description, :boost => 5.0, :more_like_this => true
    text :tags, :boost => 3.0, :more_like_this => true
    text :topic_labels,  :more_like_this => true do
      topics.map { |topic| topic.label }
    end
    text :owner_username do
      user.username
    end

    #attributes
    string :title do
      title.downcase
    end
    time :created_at
    time :updated_at
    integer :user_id
    integer :total_views
    integer :rating do
      rate_average(true)
    end
    integer :topic_ids, :references => Topic, :multiple => true
    integer :member_ids, :references => User, :multiple => true
    integer :group_ids, :references => Group, :multiple => true

    string :visibility
  end

  #######
  private

  def default_values
    if new_record?
      self.total_members ||= 1
      self.total_remixed ||= 0
      self.total_shared ||= 0
      self.total_likes ||= 0
      self.total_views ||= 0
      self.total_rating_votes ||= 0
      self.rating ||= 0

      self.editor_type ||= Project::EDITOR_TYPE_BASIC
      self.visibility ||= Project::VISIBILITY_PUBLIC
      self.duration ||= 0
    end
  end

  def textual_info_changed?
    self.title_changed? or
    self.description_changed? or
    self.editor_type_changed?
  end

  def update_video_mix
    if textual_info_changed?
      logger.info "[update_video_mix] textual info changed."
      
      #TODO move back to controller
      require 'kaltura'
      require 'ap'
      begin
        puts "begin update video mix"
        user_id = self.user.username
        config = Kaltura::Configuration.new(C.kaltura.partner_id)
        client = Kaltura::Client.new(config)
        ks = client.session_service.start(C.kaltura.user_secret, user_id, Kaltura::Constants::SessionType::USER)
        client.ks = ks

        entry = Kaltura::MixEntry.new
        ap entry

        entry.name = self.title
        entry.description = self.description
        entry.editor_type = self.editor_type == 'basic' ? Kaltura::Constants::EditorType::SIMPLE : Kaltura::Constants::EditorType::ADVANCED
        #entry.categories = self.topics.empty? ? nil : self.topics.join(',')

        entry = client.mixing_service.update(self.video_id, entry)
        ap entry

        self.thumbnail_url = entry.thumbnail_url

        true
      rescue Exception => ex
        ap ex.message

        false
      end
    else
      true
    end
  end

  def destroy_video_mix
    #TODO move back to controller
    require 'kaltura'
    begin
      user_id = self.user.username
      config = Kaltura::Configuration.new(C.kaltura.partner_id)
      client = Kaltura::Client.new(config)
      ks = client.session_service.start(C.kaltura.user_secret, user_id, Kaltura::Constants::SessionType::USER)
      client.ks = ks

      client.mixing_service.delete(self.video_id)

      true
    rescue Exception => ex
      puts ex.message

      true # doesn't matter, continue to destroy project anyway
    end
  end


  #### Stats
  # TODO extract class
  def project_clip_added(clip)
    logger.info "[project_clip_added] project_id: #{ self.id }, clip_id: #{ clip.id }"
    clip.increment_total_used()
    clip.save
  end
  def project_clip_removed(clip)
    logger.info "[project_clip_removed] project_id #{ self.id }, cli_id #{ clip.id }"
    clip.decrement_total_used()
    clip.save
  end

  def update_stats_project_created()
    logger.info "[project_created] user_id #{ self.user.id }, project_id #{ self.id } "
    self.user.increment_total_projects()
    self.user.save

    unless self.remixed_from_id.blank?
      logger.info "[project_created] remixed_from_id #{ self.remixed_from.id }"
      p = self.remixed_from
      p.increment_total_remixed()
      p.user.increment_times_projects_remixed()

      p.user.save
      p.save
    end
  end

  def update_stats_project_destroyed()
    logger.info "[project_destroyed] user_id #{ self.user.id }, project_id #{ self.id }"
    self.user.decrement_total_projects()
    self.user.save

    unless self.remixed_from_id.blank?
      logger.info "[project_destroyed] remixed_from_id #{ self.remixed_from.id }"
      p = self.remixed_from
      p.decrement_total_remixed()
      p.user.decrement_times_projects_remixed()

      p.user.save
      p.save
    end
  end

  def update_activity_stream_on_created
    Activity.created(user, self) if is_public?
  end

  def update_activity_stream_on_updated
    Activity.updated(user, self) if is_public?
  end
end
