class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :code
      t.string :label
    end
  end

  def self.down
    drop_table :topics
  end
end
