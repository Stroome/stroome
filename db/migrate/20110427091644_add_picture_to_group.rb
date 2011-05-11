class AddPictureToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :picture, :string
  end

  def self.down
    remove_column :groups, :picture
  end
end
