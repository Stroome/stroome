class CreateProjectGroups < ActiveRecord::Migration
  def self.up
    create_table :project_groups do |t|
      t.references :project
      t.references :group

      t.timestamps
    end
  end

  def self.down
    drop_table :project_groups
  end
end
