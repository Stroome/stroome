class CreateJoinRequests < ActiveRecord::Migration
  def self.up
    create_table :join_requests do |t|
      t.references :sender
      t.string :join_type
      t.references :receiver, :polymorphic => true
      t.references :joinable, :polymorphic => true
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :join_requests
  end
end
