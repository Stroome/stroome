class User < ActiveRecord::Base
  after_initialize :default_values

  before_validation :auto_generate_password

  has_and_belongs_to_many :interested_in_topics, :class_name => 'Topic'
  has_many :projects
  has_many :clips
  has_many :notifications
  
  has_many :group_members
  has_many :groups, :through => :group_members

  has_many :user_followings
  has_many :followed_users,
           :through => :user_followings,
           :source => :followed_user,
           :conditions => "user_followings.following_type = 'User'"
  has_many :followed_groups,
           :through => :user_followings,
           :source => :followed_group,
           :conditions => "user_followings.following_type = 'Group'"



  mount_uploader :picture, AvatarUploader

  ajaxful_rater

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable,
         :encryptable, :encryptor => :md5

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :username, :first_name, :last_name, :location, :about_me, :is_public,
                  :email_confirmation, :interested_in_topics, :interested_in_topic_ids,
                  :terms_of_service, :picture, :remote_picture_url

  attr_accessor :email_confirmation, :should_confirm_email
  #attr_accessor   :total_projects, :total_clips, :times_projects_remixed,
  #                :total_likes, :total_views

  validates_presence_of :username
  validates_uniqueness_of :username
  validates_length_of :username, :in => 3..16
  validates_format_of :username, :with => /^[a-zA-Z][a-zA-Z0-9]*\.?[a-zA-Z0-9]*$/, :if => :new_record?
  validates_confirmation_of :email, :if => :should_confirm_email
  validates_acceptance_of :terms_of_service

  is_impressionable # TODO remove profile page view feature



  SORT_OPTIONS = [
    ['Most Recent', 'recent'],
    ['A - Z', 'az'],
    ['Z - A', 'za'],
    ['Most Viewed', 'views']
  ]
  scope :in_order, lambda { |type|
    case type
      when 'recent' then order('created_at DESC')
      when 'az'     then order('LOWER(title) ASC')
      when 'za'     then order('LOWER(title) DESC')
      when 'views'  then order('total_views DESC')
      else order('created_at DESC')
    end
  }

  scope :with_topics, lambda { |topic_ids|
    if not topic_ids.empty?
      joins(:interested_in_topics).
      where('topics.id in (?)', topic_ids).
      group('users.id')
    end
  }

  #####
  searchable do
    # free-text search
    text :title, :boost => 4.0 do
      username
    end
    text :description, :boost => 2.0 do
      about_me
    end
    text :topic_labels, :boost => 1.5 do
      interested_in_topics.map { |topic| topic.label }
    end

    #attributes
    string :title_alphabet do
      username[0].downcase
    end
    string :title do
      username.downcase
    end
    time :created_at
    time :updated_at
    integer :total_views
    integer :rating
    integer :topic_ids, :references => Topic, :multiple => true do
      interested_in_topic_ids
    end
    boolean :is_public

  end

  def title
    username
  end

  def description
    about_me
  end

  def latest_project
    projects = Project.where("user_id = ?", self.id).
        order("updated_at DESC").limit(1)

    projects.size() > 0 ? projects[0] : nil
  end

  def update_total_projects_and_clips
    self.total_projects = self.projects.size()
    self.total_clips = self.clips.size()
    self.save
  end


  ###
  def total_likes
    cache_key = "user_total_likes_#{ id }"
    Rails.cache.fetch(cache_key) do
      calculate_total_likes
    end
  end

  def calculate_total_likes
    self.projects.collect {|p| p.total_likes }.compact.sum +
        self.clips.collect {|c| c.total_likes }.compact.sum
  end

  def total_views
    #self.unique_impression_count_session # deprecated
    cache_key = "user_total_views_#{ id }"
    Rails.cache.fetch(cache_key) do
      calculate_total_views
    end
  end

  def calculate_total_views
    self.projects.collect {|p| p.total_views }.compact.sum +
        self.clips.collect {|c| c.total_views }.compact.sum
  end

  def increment_total_projects
    self.total_projects ||= 0
    self.total_projects += 1
  end

  def increment_times_projects_remixed
    self.times_projects_remixed ||= 0
    self.times_projects_remixed += 1
  end

  def decrement_total_projects
    self.total_projects ||= 0
    self.total_projects -= 1
    self.total_projects = 0 if self.total_projects < 0
  end

  def decrement_times_projects_remixed
    self.times_projects_remixed ||= 0
    self.times_projects_remixed -= 1
    self.times_projects_remixed = 0 if self.times_projects_remixed < 0
  end
  ###

  def fullname
    [first_name, last_name].join(" ")
  end

  def can_show_fullname?
    is_public?
  end

  def to_s
    username
  end

  def update_with_password(params={})
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    update_attributes(params)
  end

  def change_current_password(params={})
    current_password = params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = if valid_password?(current_password)
               update_attributes(params)
             else
               self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
               self.attributes = params
               false
             end

    clean_up_passwords
    result
  end

  # omniauth helper methods

  # Try to find a user with the email address of the fb user if found return the user object if not return nil
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token['extra']['user_hash']
    User.find_by_email(data["email"])
  end

  # If any data from facebook connect is present use it to fill up the new user form
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["user_hash"]
        user.email = data["email"]
        user.email_confirmation = data["email"]
        user.first_name = data["first_name"]
        user.last_name = data["last_name"]
        #user.remote_picture_url = data["image"]
      end
    end
  end

  #######
  private

  # Set default values after initialized new User.
  def default_values
    if new_record?
      self.is_public = true if self.is_public.nil?
      self.interested_in_topics = Topic.all if self.terms_of_service.nil?
      self.total_projects = 0
      self.total_clips = 0
      self.times_projects_remixed = 0
    end
    self.email_confirmation ||= self.email if self.email?
    self.should_confirm_email = true

  # TODO decide whether to remain/remove db columns

  #  self.total_views ||= 0
  #  self.total_likes ||= 0
  end

  def auto_generate_password
    if self.new_record?
      self.password ||= Devise.friendly_token[0,20]
    end
  end

end
