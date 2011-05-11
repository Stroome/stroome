class ReplacePictureUrlWithPictureOnUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :picture_url
    add_column :users, :picture, :string
  end

  def self.down
    remove_column :users, :picture
    add_column :users, :picture_url, :string
  end
end
