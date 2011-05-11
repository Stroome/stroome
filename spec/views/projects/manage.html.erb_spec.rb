require 'spec_helper'

describe "projects/show.html.erb" do
  before(:each) do
    @project = assign(:project, stub_model(Project,
      :title => "Title",
      :description => "MyText",
      :duration => 1,
      :tags => "Tags",
      :location => "Location",
      :editor_type => "Editor Type",
      :visibility => "Visibility",
      :status => "Status",
      :user => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Tags/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Location/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Editor Type/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Visibility/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Status/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
  end
end
