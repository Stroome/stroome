class CreateProjectMembers < ActiveRecord::Migration
  def self.up
    create_table :project_members do |t|
      t.references :project
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :project_members
  end
end
