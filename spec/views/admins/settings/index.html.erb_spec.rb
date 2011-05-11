require 'spec_helper'

describe "admins_settings/index.html.erb" do
  before(:each) do
    assign(:admins_settings, [
      stub_model(Admins::Setting,
        :name => "Name",
        :value => "Value"
      ),
      stub_model(Admins::Setting,
        :name => "Name",
        :value => "Value"
      )
    ])
  end

  it "renders a list of admins_settings" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Value".to_s, :count => 2
  end
end
