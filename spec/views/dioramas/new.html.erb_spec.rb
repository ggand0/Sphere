require 'spec_helper'

describe "dioramas/new" do
  before(:each) do
    assign(:diorama, stub_model(Diorama).as_new_record)
    @model_data = ModelDatum.all
    @stages = Stage.all
  end

  it "renders new diorama form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", dioramas_path, "post" do
    end
  end
end
