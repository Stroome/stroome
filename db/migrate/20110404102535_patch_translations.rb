class PatchTranslations < ActiveRecord::Migration
  def self.up
    Translation.destroy_all

    [
      ["new_project", "START NEW PROJECT"],
      ["remix_project", "REMIX THIS PROJECT"],
      ["manage_project", "MANAGE PROJECT"],
      ["launch_editor", "LAUNCH EDITOR"],
      ["edit_project", "EDIT PROJECT INFO"],
      ["delete_project", "DELETE PROJECT"],
      ["resume_editor", "RESUME EDITING"],
      ["new_project_with_clip", "USE CLIP FOR NEW PROJECT"],
      ["add_to_clip_bin", "ADD TO CLIP BIN"],
      ["update_profile", "UPDATE PROFILE"],
      ["new_profile", "CREATE ACCOUNT"],
      ["promote_sign_up", "TRY NOW! IT'S FREE"],
      ["promote_sign_up_with_remix", "SIGN UP TO GET STARTED"],
      ["promote_sign_up_with_clip", "SIGN UP TO GET STARTED"],
      ["new_comment", "SUBMIT"]
    ].each do |l|
      Translation.create( :locale => "en", :key => l[0], :value => l[1] )
    end
  end

  def self.down
  end
end
