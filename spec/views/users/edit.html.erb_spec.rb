require 'spec_helper'

describe "users/edit.html.erb" do
  before(:each) do
    @user = assign(:user, stub_model(User,
      :username => "MyString",
      :email => "MyString",
      :password => "MyString",
      :first_name => "MyString",
      :last_name => "MyString",
      :location => "MyString",
      :picture_url => "MyString",
      :about_me => "MyText",
      :is_public => false
    ))
  end

  it "renders the edit user form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => users_path(@user), :method => "post" do
      assert_select "input#user_username", :name => "user[username]"
      assert_select "input#user_email", :name => "user[email]"
      assert_select "input#user_password", :name => "user[password]"
      assert_select "input#user_first_name", :name => "user[first_name]"
      assert_select "input#user_last_name", :name => "user[last_name]"
      assert_select "input#user_location", :name => "user[location]"
      assert_select "input#user_picture_url", :name => "user[picture_url]"
      assert_select "textarea#user_about_me", :name => "user[about_me]"
      assert_select "input#user_is_public", :name => "user[is_public]"
    end
  end
end
