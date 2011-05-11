class UpdateTotalMembersInProjects < ActiveRecord::Migration
  def self.up
    Project.update_all("total_members = 1", "total_members = 0")
  end

  def self.down
    # ignored
  end
end
