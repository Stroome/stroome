require 'spec_helper'

describe "comments/edit.html.erb" do
  before(:each) do
    @comment = assign(:comment, stub_model(Comment,
      :user_id => 1,
      :body => "MyString",
      :parent_id => 1,
      :project_id => 1,
      :clip_id => 1
    ))
  end

  it "renders the edit comment form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => comments_path(@comment), :method => "post" do
      assert_select "input#comment_user_id", :name => "comment[user_id]"
      assert_select "input#comment_body", :name => "comment[body]"
      assert_select "input#comment_parent_id", :name => "comment[parent_id]"
      assert_select "input#comment_project_id", :name => "comment[project_id]"
      assert_select "input#comment_clip_id", :name => "comment[clip_id]"
    end
  end
end
