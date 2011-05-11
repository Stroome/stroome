require 'spec_helper'

describe "comments/index.html.erb" do
  before(:each) do
    assign(:comments, [
      stub_model(Comment,
        :user_id => 1,
        :body => "Body",
        :parent_id => 1,
        :project_id => 1,
        :clip_id => 1
      ),
      stub_model(Comment,
        :user_id => 1,
        :body => "Body",
        :parent_id => 1,
        :project_id => 1,
        :clip_id => 1
      )
    ])
  end

  it "renders a list of comments" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Body".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
