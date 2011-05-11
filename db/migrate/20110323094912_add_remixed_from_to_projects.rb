class AddRemixedFromToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :remixed_from_id, :integer
  end

  def self.down
    remove_column :projects, :remixed_from_id
  end
end
