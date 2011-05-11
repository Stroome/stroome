class CreateGroupsTopicsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :groups_topics, :id => false do |t|
      t.references :group
      t.references :topic
    end
  end

  def self.down
    drop_table :groups_topics
  end
end
