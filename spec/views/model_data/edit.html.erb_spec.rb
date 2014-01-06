require 'spec_helper'

describe "model_data/edit" do
  before(:each) do
    @model_datum = assign(:model_datum, stub_model(ModelDatum))
  end

  it "renders the edit model_datum form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", model_datum_path(@model_datum), "post" do
    end
  end
end
