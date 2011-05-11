class AddUiConfIdsToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :uiconf_kcw_id, :integer
    add_column :projects, :uiconf_kse_id, :integer
    add_column :projects, :uiconf_kae_id, :integer
  end

  def self.down
    remove_column :projects, :uiconf_kae_id
    remove_column :projects, :uiconf_kse_id
    remove_column :projects, :uiconf_kcw_id
  end
end
