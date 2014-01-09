require 'spec_helper'

describe "stages/edit" do
  before(:each) do
    @stage = assign(:stage, stub_model(Stage))
  end

  it "renders the edit stage form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", stage_path(@stage), "post" do
    end
  end
end
