class AddExternalIdToJoinRequest < ActiveRecord::Migration
  def self.up
    add_column :join_requests, :external_id, :string
  end

  def self.down
    remove_column :join_requests, :external_id
  end
end
