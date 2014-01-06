require 'spec_helper'

describe "model_data/index" do
  before(:each) do
    assign(:model_data, [
      stub_model(ModelDatum),
      stub_model(ModelDatum)
    ])
  end

  it "renders a list of model_data" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
