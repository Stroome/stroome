class AddTotalViewsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :total_views, :integer
    add_column :users, :rating, :integer
  end

  def self.down
    remove_column :users, :total_views
    remove_column :users, :rating
  end
end
