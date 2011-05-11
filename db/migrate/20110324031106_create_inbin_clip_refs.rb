class CreateInbinClipRefs < ActiveRecord::Migration
  def self.up
    create_table :inbin_clip_refs do |t|
      t.references :inbin_clip_owner, :polymorphic => true
      t.references :clip
    end
  end

  def self.down
    drop_table :inbin_clip_refs
  end
end
