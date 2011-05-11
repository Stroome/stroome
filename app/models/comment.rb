class Comment < ActiveRecord::Base
  default_scope :order => 'created_at DESC'

  cattr_reader :per_page
  @@per_page = PaginationHelper::DEFAULT_BROWSE_PER_PAGE

  belongs_to :clip
  belongs_to :project
  belongs_to :user

  has_many :children, :class_name => "Comment",
    :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Comment"

  validates_length_of :body, :maximum=>300

  def belongs_to_project?
    not self.project_id.nil?
  end

end
