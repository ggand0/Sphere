require 'spec_helper'

describe "dioramas/index" do
  before(:each) do
    assign(:dioramas, [
      stub_model(Diorama),
      stub_model(Diorama)
    ])
  end

  it "renders a list of dioramas" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
