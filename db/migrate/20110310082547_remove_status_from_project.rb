class RemoveStatusFromProject < ActiveRecord::Migration
  def self.up
    remove_column :projects, :status
  end

  def self.down
    add_column :projects, :status, :string
  end
end
