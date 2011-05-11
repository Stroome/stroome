class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :title
      t.text :description
      t.integer :duration
      t.string :tags
      t.string :location
      t.string :editor_type
      t.string :visibility
      t.string :status
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
