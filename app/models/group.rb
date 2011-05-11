class Group < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"

  has_and_belongs_to_many :topics
  has_many :group_members
  has_many :members, :through => :group_members, :source => :user
  has_many :join_requests, :as => :joinable

  has_many :project_groups
  has_many :projects,
             :through => :project_groups,
             :source => :project

  has_many :comments

  mount_uploader :picture, AvatarUploader

  class MEMBERSHIP
    PUBLIC  = "PUBLIC"
    PRIVATE = "PRIVATE"
    
    def self.all
      self.constants.collect {|symbol| symbol.to_s }
    end

    def self.options
      self.all.collect { |value| [value.titlecase, value] }
    end
  end

  validates_presence_of :title, :description, :membership
  validates_uniqueness_of :title
  validates_inclusion_of :membership, :in => MEMBERSHIP.all

  attr_accessible :title, :description, :membership,
                  :location, :topics, :topic_ids, :picture

  after_initialize :populate_default_values

  searchable do
    # free-text search
    text :title, :boost => 10.0, :more_like_this => true
    text :description, :boost => 5.0, :more_like_this => true
    text :topic_labels,  :more_like_this => true do
      topics.map { |topic| topic.label }
    end
    text :owner_username do
      owner.username
    end

    #attributes
    integer :id
    string :title_alphabet do
      title[0].downcase
    end
    string :title do
      title.downcase
    end
    time :created_at
    time :updated_at
    integer :owner_id
    integer :topic_ids, :references => Topic, :multiple => true
    integer :member_ids, :references => User, :multiple => true
    string :membership
  end

  def limited_access_to_user?(user)
    not full_access_to_user? user
  end

  def full_access_to_user?(user)
    not user.nil? and (
        public_membership? or
        (private_membership? and owner? user) or
        (private_membership? and has_member? user)
    )
  end

  def owner?(user)
    user and owner and owner.id == user.id
  end

  def public_membership?
    self.membership == MEMBERSHIP::PUBLIC
  end

  def private_membership?
    self.membership == MEMBERSHIP::PRIVATE
  end

  def populate_default_values
    if new_record?
      self.membership ||= MEMBERSHIP::PUBLIC
    end
  end

  def has_member?(user)
    self.members.include? user
  end

  def has_pending_request_from?(user)
    JoinRequest.has_pending_group_request?(user.id, self.id)
  end


  ### joinable
  def can_invite?(user)
    not owner?(user) and
        not member?(user) and
        not already_invited?(user)
  end

  def joined?(user)
    owner?(user) or
        member?(user)
  end


  def member?(user)
    user and (self.members.select {|member| member.id == user.id }.size > 0)
  end

  def already_invited?(user)
    results = self.join_requests.select do |request|
      request.pending? and
      request.receiver_id == user.id
    end

    results.size() > 0
  end


  #### stats

  def total_members
    self.members.size
  end

  def total_projects
    self.projects.size
  end

  def total_views
    cache_key = "group_total_likes_#{ id }"
    Rails.cache.fetch(cache_key) do
      calculate_total_views
    end
  end

  def calculate_total_views
    self.projects.collect {|p| p.total_views }.compact.sum
  end

  def total_likes
    cache_key = "group_total_likes_#{ id }"
    Rails.cache.fetch(cache_key) do
      calculate_total_likes
    end
  end

  def calculate_total_likes
    self.projects.collect {|p| p.total_likes }.compact.sum
  end

end
