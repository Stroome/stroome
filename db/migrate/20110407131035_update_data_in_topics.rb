class UpdateDataInTopics < ActiveRecord::Migration
  def self.up
    topic = Topic.find_by_code("transport")
    unless topic.blank?
      topic.code = "sports"
      topic.label = "Sports"
      topic.save
    end
  end

  def self.down
  end
end
