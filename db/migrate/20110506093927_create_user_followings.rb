class CreateUserFollowings < ActiveRecord::Migration
  def self.up
    create_table :user_followings do |t|
      t.references :user
      t.references :following, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :user_followings
  end
end
