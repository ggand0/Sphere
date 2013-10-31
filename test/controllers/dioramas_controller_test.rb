require 'test_helper'

class DioramasControllerTest < ActionController::TestCase
  setup do
    @diorama = dioramas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dioramas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create diorama" do
    assert_difference('Diorama.count') do
      post :create, diorama: { title: @diorama.title }
    end

    assert_redirected_to diorama_path(assigns(:diorama))
  end

  test "should show diorama" do
    get :show, id: @diorama
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @diorama
    assert_response :success
  end

  test "should update diorama" do
    patch :update, id: @diorama, diorama: { title: @diorama.title }
    assert_redirected_to diorama_path(assigns(:diorama))
  end

  test "should destroy diorama" do
    assert_difference('Diorama.count', -1) do
      delete :destroy, id: @diorama
    end

    assert_redirected_to dioramas_path
  end
end
