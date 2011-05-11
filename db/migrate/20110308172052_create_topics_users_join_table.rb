class CreateTopicsUsersJoinTable < ActiveRecord::Migration
  def self.up
    create_table  :topics_users, :id => false do |t|
      t.references :topic
      t.references :user
    end
  end

  def self.down
    drop_table :topics_users
  end
end
