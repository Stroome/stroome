class CreateProjectInvitations < ActiveRecord::Migration
  def self.up
    create_table :project_invitations do |t|
      t.references :project
      t.references :sender
      t.string :status
      t.string :token
      t.references :receiver
      t.string :receiver_email
      t.string :receiver_name
      t.text :message

      t.timestamps
    end
  end

  def self.down
    drop_table :project_invitations
  end
end
