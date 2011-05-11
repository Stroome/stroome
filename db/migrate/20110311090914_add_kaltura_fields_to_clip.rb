class AddKalturaFieldsToClip < ActiveRecord::Migration
  def self.up
    add_column :clips, :video_id, :string
    add_column :clips, :thumbnail_url, :string
  end

  def self.down
    remove_column :clips, :thumbnail_url
    remove_column :clips, :video_id
  end
end
