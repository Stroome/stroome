require "spec_helper"

describe Admins::PagesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/admins_pages" }.should route_to(:controller => "admins_pages", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/admins_pages/new" }.should route_to(:controller => "admins_pages", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/admins_pages/1" }.should route_to(:controller => "admins_pages", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/admins_pages/1/edit" }.should route_to(:controller => "admins_pages", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/admins_pages" }.should route_to(:controller => "admins_pages", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/admins_pages/1" }.should route_to(:controller => "admins_pages", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/admins_pages/1" }.should route_to(:controller => "admins_pages", :action => "destroy", :id => "1")
    end

  end
end
