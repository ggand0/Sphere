require "spec_helper"

describe ModelDataController do
  describe "routing" do

    it "routes to #index" do
      get("/model_data").should route_to("model_data#index")
    end

    it "routes to #new" do
      get("/model_data/new").should route_to("model_data#new")
    end

    it "routes to #show" do
      get("/model_data/1").should route_to("model_data#show", :id => "1")
    end

    it "routes to #edit" do
      get("/model_data/1/edit").should route_to("model_data#edit", :id => "1")
    end

    it "routes to #create" do
      post("/model_data").should route_to("model_data#create")
    end

    it "routes to #update" do
      put("/model_data/1").should route_to("model_data#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/model_data/1").should route_to("model_data#destroy", :id => "1")
    end

  end
end
