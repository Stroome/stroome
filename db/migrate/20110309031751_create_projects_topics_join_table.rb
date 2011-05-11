class CreateProjectsTopicsJoinTable < ActiveRecord::Migration
  def self.up
    create_table  :projects_topics, :id => false do |t|
      t.references :project
      t.references :topic
    end
  end

  def self.down
    drop_table :projects_topics
  end
end
