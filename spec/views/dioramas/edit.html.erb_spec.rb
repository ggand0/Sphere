require 'spec_helper'

describe "dioramas/edit" do
  before(:each) do
    @diorama = assign(:diorama, stub_model(Diorama))
  end

  it "renders the edit diorama form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", diorama_path(@diorama), "post" do
    end
  end
end
