class UpdateSemiPrivateGroupsToPrivate < ActiveRecord::Migration
  def self.up
    Group.update_all("membership = 'PRIVATE'", "membership = 'SEMI_PRIVATE'")
  end

  def self.down
  end
end
