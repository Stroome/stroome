class AddTotalViewsToClips < ActiveRecord::Migration
  def self.up
    add_column :clips, :total_views, :integer
  end

  def self.down
    remove_column :clips, :total_views
  end
end
