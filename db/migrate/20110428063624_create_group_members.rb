class CreateGroupMembers < ActiveRecord::Migration
  def self.up
    create_table :group_members do |t|
      t.references :user
      t.references :group

      t.timestamps
    end
  end

  def self.down
    drop_table :group_members
  end
end
