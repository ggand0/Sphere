require 'spec_helper'

describe "model_data/show" do
  before(:each) do
    @model_datum = assign(:model_datum, stub_model(ModelDatum))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
