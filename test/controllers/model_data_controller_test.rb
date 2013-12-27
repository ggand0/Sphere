require 'test_helper'

class ModelDataControllerTest < ActionController::TestCase
  setup do
    @model_datum = model_data(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:model_data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create model_datum" do
    assert_difference('ModelDatum.count') do
      upload = ActionDispatch::Http::UploadedFile.new({
        original_filename: 'fixtures/notexture.fbx',
        content_type: 'application/octet-stream',
        tempfile: File.new("#{Rails.root}/test/fixtures/notexture.fbx")
      })
      post :create, model_datum: { title: "test", file: upload }
    end

    assert_redirected_to model_datum_path(assigns(:model_datum))
  end

  test "should show model_datum" do
    get :show, id: @model_datum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @model_datum
    assert_response :success
  end

  test "should update model_datum" do
    patch :update, id: @model_datum, model_datum: { modeldata: @model_datum.modeldata }
    assert_redirected_to model_datum_path(assigns(:model_datum))
  end

  test "should destroy model_datum" do
    assert_difference('ModelDatum.count', -1) do
      delete :destroy, id: @model_datum
    end

    assert_redirected_to model_data_path
  end
end
