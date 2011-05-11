class CreateClipsProjectsJoinTable < ActiveRecord::Migration
  def self.up
    create_table  :clips_projects, :id => false do |t|
      t.references :clip
      t.references :project
    end
  end

  def self.down
    drop_table :clips_projects
  end
end
