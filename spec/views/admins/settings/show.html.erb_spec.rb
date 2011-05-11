require 'spec_helper'

describe "admins_settings/show.html.erb" do
  before(:each) do
    @setting = assign(:setting, stub_model(Admins::Setting,
      :name => "Name",
      :value => "Value"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Value/)
  end
end
