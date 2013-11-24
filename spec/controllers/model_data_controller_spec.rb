require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe ModelDataController do

  # This should return the minimal set of attributes required to create a valid
  # ModelDatum. As you add validations to ModelDatum, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {  } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ModelDataController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ModelDatum" do
        expect {
          post :create, {:model_datum => valid_attributes}, valid_session
        }.to change(ModelDatum, :count).by(1)
      end

      it "assigns a newly created model_datum as @model_datum" do
        post :create, {:model_datum => valid_attributes}, valid_session
        assigns(:model_datum).should be_a(ModelDatum)
        assigns(:model_datum).should be_persisted
      end

      it "redirects to the created model_datum" do
        post :create, {:model_datum => valid_attributes}, valid_session
        response.should redirect_to(ModelDatum.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved model_datum as @model_datum" do
        # Trigger the behavior that occurs when invalid params are submitted
        ModelDatum.any_instance.stub(:save).and_return(false)
        post :create, {:model_datum => {  }}, valid_session
        assigns(:model_datum).should be_a_new(ModelDatum)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        ModelDatum.any_instance.stub(:save).and_return(false)
        post :create, {:model_datum => {  }}, valid_session
        response.should render_template("new")
      end
    end
  end

end
