class AddStatsAttrsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :total_projects, :integer
    add_column :users, :total_clips, :integer
    add_column :users, :times_projects_remixed, :integer
    add_column :users, :total_likes, :integer
  end

  def self.down
    remove_column :users, :total_likes
    remove_column :users, :times_projects_remixed
    remove_column :users, :total_clips
    remove_column :users, :total_projects
  end
end
