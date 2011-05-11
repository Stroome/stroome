class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :user_id
      t.string :body
      t.integer :parent_id
      t.integer :project_id
      t.integer :clip_id

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
