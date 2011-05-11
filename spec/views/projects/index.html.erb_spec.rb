require 'spec_helper'

describe "projects/index.html.erb" do
  before(:each) do
    assign(:projects, [
      stub_model(Project,
        :title => "Title",
        :description => "MyText",
        :duration => 1,
        :tags => "Tags",
        :location => "Location",
        :editor_type => "Editor Type",
        :visibility => "Visibility",
        :status => "Status",
        :user => nil
      ),
      stub_model(Project,
        :title => "Title",
        :description => "MyText",
        :duration => 1,
        :tags => "Tags",
        :location => "Location",
        :editor_type => "Editor Type",
        :visibility => "Visibility",
        :status => "Status",
        :user => nil
      )
    ])
  end

  it "renders a list of projects" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Tags".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Location".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Editor Type".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Visibility".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Status".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
