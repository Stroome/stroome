# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

if Topic.count < 1
  [
    {:code => 'activism', :label => 'Activism & Non-Profit'},
    {:code => 'nature', :label => 'Animals & Nature'},
    {:code => 'animation', :label => 'Animation & Motion'},
    {:code => 'arts', :label => 'Arts & Entertainment'},
    {:code => 'news', :label => 'Breaking News'},
    {:code => 'business', :label => 'Business & Economy'},
    {:code => 'events', :label => 'Conferences & Public Events'},
    {:code => 'currevents', :label => 'Current Events'},
    {:code => 'education', :label => 'Education'},
    {:code => 'entertainment', :label => 'Entertainment'},
    {:code => 'food', :label => 'Food & Drink'},
    {:code => 'travel', :label => 'Locations & Travel'},
    {:code => 'objects', :label => 'Objects'},
    {:code => 'science', :label => 'Science & Technology'},
    {:code => 'sports', :label => 'Sports'}
  ].each do |t|
    puts 'Creating "' +t[:label]+ '" record'
    Topic.create( :code => t[:code], :label => t[:label] )
  end
end

Translation.delete_all
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

Page.delete_all
Page::ALL.each do |page|
  content = IO.read( Rails.root.join("db","default", page + ".txt") )

  page = Page.create(:title=> page, :content_type=> "markdown", :content=> content )
  page.save
end

Setting.delete_all
[
  [Setting::CONTACT_EMAIL, "admin@stroome.com"]
].each do |s|
  Setting.create( :name => s[0], :value => s[1] )
end