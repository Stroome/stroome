class ReplacePromptActionPathInNotifications < ActiveRecord::Migration
  def self.up
    change_table :notifications do |t|
      t.rename :prompt_action_path, :token
    end
  end

  def self.down
    change_table :notifications do |t|
      t.rename :token, :prompt_action_path
    end
  end
end
