class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.references :user
      t.string :title
      t.string :description
      t.string :status
      t.string :prompt_action_path
      t.string :prompt_actions

      t.timestamps
    end
  end

  def self.down
    drop_table :notifications
  end
end
