class AddKalturaFieldsToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :thumbnail_url, :string
    add_column :projects, :video_id, :string
  end

  def self.down
    remove_column :projects, :video_id
    remove_column :projects, :thumbnail_url
  end
end
