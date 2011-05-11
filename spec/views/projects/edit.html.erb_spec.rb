require 'spec_helper'

describe "projects/edit.html.erb" do
  before(:each) do
    @project = assign(:project, stub_model(Project,
      :title => "MyString",
      :description => "MyText",
      :duration => 1,
      :tags => "MyString",
      :location => "MyString",
      :editor_type => "MyString",
      :visibility => "MyString",
      :status => "MyString",
      :user => nil
    ))
  end

  it "renders the edit project form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => projects_path(@project), :method => "post" do
      assert_select "input#project_title", :name => "project[title]"
      assert_select "textarea#project_description", :name => "project[description]"
      assert_select "input#project_duration", :name => "project[duration]"
      assert_select "input#project_tags", :name => "project[tags]"
      assert_select "input#project_location", :name => "project[location]"
      assert_select "input#project_editor_type", :name => "project[editor_type]"
      assert_select "input#project_visibility", :name => "project[visibility]"
      assert_select "input#project_status", :name => "project[status]"
      assert_select "input#project_user", :name => "project[user]"
    end
  end
end
