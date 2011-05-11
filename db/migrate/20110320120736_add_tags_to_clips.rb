class AddTagsToClips < ActiveRecord::Migration
  def self.up
    add_column :clips, :tags, :string
  end

  def self.down
    remove_column :clips, :tags
  end
end
