require 'spec_helper'

describe "stages/show" do
  before(:each) do
    @stage = assign(:stage, stub_model(Stage))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
