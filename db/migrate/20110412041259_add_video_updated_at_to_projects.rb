class AddVideoUpdatedAtToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :video_updated_at, :timestamp
  end

  def self.down
    remove_column :projects, :video_updated_at
  end
end
