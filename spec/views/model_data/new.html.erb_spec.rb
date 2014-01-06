require 'spec_helper'

describe "model_data/new" do
  before(:each) do
    assign(:model_datum, stub_model(ModelDatum).as_new_record)
  end

  it "renders new model_datum form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", model_data_path, "post" do
    end
  end
end
