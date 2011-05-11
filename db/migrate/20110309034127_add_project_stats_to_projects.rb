class AddProjectStatsToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :total_members, :integer
    add_column :projects, :total_remixed, :integer
    add_column :projects, :total_shared, :integer
    add_column :projects, :total_likes, :integer
    add_column :projects, :total_views, :integer
    add_column :projects, :total_rating_votes, :integer
    add_column :projects, :rating, :integer
  end

  def self.down
    remove_column :projects, :rating
    remove_column :projects, :total_rating_votes
    remove_column :projects, :total_views
    remove_column :projects, :total_likes
    remove_column :projects, :total_shared
    remove_column :projects, :total_remixed
    remove_column :projects, :total_members
  end
end
