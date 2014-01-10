require "spec_helper"

describe DioramasController do
  describe "routing" do

    it "routes to #index" do
      get("/dioramas").should route_to("dioramas#index")
    end

    it "routes to #new" do
      get("/dioramas/new").should route_to("dioramas#new")
    end

    it "routes to #show" do
      get("/dioramas/1").should route_to("dioramas#show", :id => "1")
    end

    it "routes to #edit" do
      get("/dioramas/1/edit").should route_to("dioramas#edit", :id => "1")
    end

    it "routes to #create" do
      post("/dioramas").should route_to("dioramas#create")
    end

    it "routes to #update" do
      put("/dioramas/1").should route_to("dioramas#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/dioramas/1").should route_to("dioramas#destroy", :id => "1")
    end

  end
end
