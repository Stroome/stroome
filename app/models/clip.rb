class Clip < ActiveRecord::Base
  after_initialize :default_values

  after_create :update_stats_clip_created
  after_create :update_activity_stream
  after_destroy :update_stats_clip_destroyed

  belongs_to :user
  has_and_belongs_to_many :topics
  has_many :comments

  ajaxful_rateable :stars => 5, :cache_column => 'rating'

  is_impressionable

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
      joins(:topics).
      where('topics.id in (?)', topic_ids).
      group('clips.id')
    end
  }

  def picture_url
    thumbnail_url
  end

  ####
  # TODO temp fix
  def total_views
    migrated_total = read_attribute(:total_views)
    migrated_total ||= 0
    new_total = (self.unique_impression_count_session ? self.unique_impression_count_session : 0)
    migrated_total + new_total
  end

  def increment_total_used()
    self.total_used ||= 0
    self.total_used += 1
  end

  def decrement_total_used()
    self.total_used ||= 0
    self.total_used -= 1
    self.total_used = 0 if self.total_used < 0
  end

  #####
  searchable do
    # free-text search
    text :title, :boost => 10.0, :more_like_this => true
    text :description, :boost => 5.0, :more_like_this => true
    text :tags, :boost => 3.0, :more_like_this => true
    text :topic_labels, :more_like_this => true do
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
  end

  def more_clips_from_owner(page=1, per_page=PaginationHelper::DEFAULT_BROWSE_PER_PAGE)
    owner = self.user_id
    this_clip = self

    @search = Clip.search do
      without(this_clip)
      with(:user_id, owner)
      order_by(:updated_at, :desc)
      paginate(:page => page, :per_page => per_page)
    end
  end

  def more_clips_like_this(page=1, per_page=PaginationHelper::DEFAULT_BROWSE_PER_PAGE)
    self.more_like_this do
      paginate(:page => page, :per_page => per_page)
    end
  end

  # TODO remove duplication
  def duration_in_mins
    total_minutes = duration / 1.minutes
    seconds_in_last_minute = duration - total_minutes.minutes.seconds
    "#{total_minutes}:#{seconds_in_last_minute.to_s.rjust(2, '0')} mins"
  end

  private
  def default_values
    if new_record?
      self.total_used ||= 0
      self.total_shared ||= 0
      self.total_likes ||= 0
      self.total_rating_votes ||= 0
      self.rating ||= 0

      self.duration ||= 0
    end
  end

  ###
  def update_stats_clip_created
    logger.info "[clip_created] user_id #{ self.user.id }"
    self.user.total_clips ||= 0
    self.user.total_clips += 1

    self.user.save
  end

  def update_stats_clip_destroyed
    logger.info "[clip_destroyed] user_id #{ self.user.id }"
    self.user.total_clips ||= 0
    self.user.total_clips -= 1
    self.user.total_clips = 0 if self.user.total_clips < 0

    self.user.save
  end

  def update_activity_stream
    Activity.uploaded(user, self)
  end
end
