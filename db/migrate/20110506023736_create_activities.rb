class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.references :subject, :polymorphic => true
      t.string :event
      t.references :object, :polymorphic => true
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
