require "spec_helper"

describe Admins::SettingsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/admins_settings" }.should route_to(:controller => "admins_settings", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/admins_settings/new" }.should route_to(:controller => "admins_settings", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/admins_settings/1" }.should route_to(:controller => "admins_settings", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/admins_settings/1/edit" }.should route_to(:controller => "admins_settings", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/admins_settings" }.should route_to(:controller => "admins_settings", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/admins_settings/1" }.should route_to(:controller => "admins_settings", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/admins_settings/1" }.should route_to(:controller => "admins_settings", :action => "destroy", :id => "1")
    end

  end
end
