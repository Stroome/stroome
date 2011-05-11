class UserNotification < ActiveRecord::Base
  belongs_to :user
  belongs_to :actionable, :polymorphic => true

  class NOTIFY_TYPE
    ACTIONABLE = "ACTIONABLE"
    READONLY   = "READONLY"

    def self.all
      self.constants.collect {|symbol| symbol.to_s }
    end
  end

  class STATUS
    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"

    def self.all
      self.constants.collect {|symbol| symbol.to_s }
    end
  end

  validates_presence_of :user_id, :notify_type, :status
  validates_presence_of :actionable_id, :actionable_type, :if => :actionable?

  validates_inclusion_of :notify_type, :in => NOTIFY_TYPE.all
  validates_inclusion_of :status, :in => STATUS.all

  after_initialize :default_values

  def self.actionable(*params)
    obj = self.new(*params)
    obj.notify_type = NOTIFY_TYPE::ACTIONABLE
    obj
  end

  def self.readonly(*params)
    obj = self.new(*params)
    obj.notify_type = NOTIFY_TYPE::READONLY
    obj
  end

  def inactive!
    self.status = STATUS::INACTIVE
  end

  def readonly?
    self.notify_type == NOTIFY_TYPE::READONLY
  end

  def actionable?
    self.notify_type == NOTIFY_TYPE::ACTIONABLE
  end

  def default_values
    self.status ||= STATUS::ACTIVE
  end

  def title
    self.actionable? ? self.actionable.title : read_attribute(:title)
  end

  def render_description(view)
    self.actionable? ? self.actionable.description(view) : read_attribute(:description)
  end

end
