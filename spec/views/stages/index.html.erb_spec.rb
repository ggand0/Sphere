require 'spec_helper'

describe "stages/index" do
  before(:each) do
    assign(:stages, [
      stub_model(Stage),
      stub_model(Stage)
    ])
  end

  it "renders a list of stages" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
