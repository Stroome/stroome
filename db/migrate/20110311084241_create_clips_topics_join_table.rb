class CreateClipsTopicsJoinTable < ActiveRecord::Migration
  def self.up
    create_table  :clips_topics, :id => false do |t|
      t.references :topic
      t.references :clip
    end
  end

  def self.down
    drop_table :clips_topics
  end
end
