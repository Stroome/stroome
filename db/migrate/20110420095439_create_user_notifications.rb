class CreateUserNotifications < ActiveRecord::Migration
  def self.up
    create_table :user_notifications do |t|
      t.references :user
      t.string :notify_type
      t.string :status
      t.string :title
      t.string :description
      t.references :actionable, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :user_notifications
  end
end
