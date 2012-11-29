require 'test_helper'

class TrackersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get changes_and_errors" do
    get :changes_and_errors
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get find_xpath" do
    get :find_xpath
    assert_response :success
  end

  test "should get test_xpath" do
    get :test_xpath
    assert_response :success
  end

  test "should get stats" do
    get :stats
    assert_response :success
  end

  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get destroy" do
    get :destroy
    assert_response :success
  end

  test "should get delete" do
    get :delete
    assert_response :success
  end

end
