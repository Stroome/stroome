require "spec_helper"

describe ClipsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/clips" }.should route_to(:controller => "clips", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/clips/new" }.should route_to(:controller => "clips", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/clips/1" }.should route_to(:controller => "clips", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/clips/1/edit" }.should route_to(:controller => "clips", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/clips" }.should route_to(:controller => "clips", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/clips/1" }.should route_to(:controller => "clips", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/clips/1" }.should route_to(:controller => "clips", :action => "destroy", :id => "1")
    end

  end
end
