class AddClipStatsToClips < ActiveRecord::Migration
  def self.up
    add_column :clips, :total_used, :integer
    add_column :clips, :total_shared, :integer
    add_column :clips, :total_likes, :integer
    add_column :clips, :total_rating_votes, :integer
    add_column :clips, :rating, :integer
  end

  def self.down
    remove_column :clips, :total_likes
    remove_column :clips, :total_shared
    remove_column :clips, :total_used
    remove_column :clips, :total_rating_votes
    remove_column :clips, :rating
  end
end
