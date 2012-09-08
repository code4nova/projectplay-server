require 'test_helper'

class PlaygroundsControllerTest < ActionController::TestCase
  setup do
    @playground = playgrounds(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:playgrounds)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create playground" do
    assert_difference('Playground.count') do
      post :create, :playground => { :access => @playground.access, :agelevel => @playground.agelevel, :class => @playground.class, :compsum => @playground.compsum, :conditions => @playground.conditions, :drinkingw => @playground.drinkingw, :freeunstruct => @playground.freeunstruct, :generalcomments => @playground.generalcomments, :graspvalue => @playground.graspvalue, :intellect => @playground.intellect, :invitation => @playground.invitation, :mapid => @playground.mapid, :modsum => @playground.modsum, :monitoring => @playground.monitoring, :name => @playground.name, :naturualen => @playground.naturualen, :openaccess => @playground.openaccess, :physicald => @playground.physicald, :programming => @playground.programming, :restrooms => @playground.restrooms, :safelocation => @playground.safelocation, :seating => @playground.seating, :socialdom => @playground.socialdom, :specificcomments => @playground.specificcomments, :subarea => @playground.subarea, :totplay => @playground.totplay, :weather => @playground.weather }
    end

    assert_redirected_to playground_path(assigns(:playground))
  end

  test "should show playground" do
    get :show, :id => @playground
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @playground
    assert_response :success
  end

  test "should update playground" do
    put :update, :id => @playground, :playground => { :access => @playground.access, :agelevel => @playground.agelevel, :class => @playground.class, :compsum => @playground.compsum, :conditions => @playground.conditions, :drinkingw => @playground.drinkingw, :freeunstruct => @playground.freeunstruct, :generalcomments => @playground.generalcomments, :graspvalue => @playground.graspvalue, :intellect => @playground.intellect, :invitation => @playground.invitation, :mapid => @playground.mapid, :modsum => @playground.modsum, :monitoring => @playground.monitoring, :name => @playground.name, :naturualen => @playground.naturualen, :openaccess => @playground.openaccess, :physicald => @playground.physicald, :programming => @playground.programming, :restrooms => @playground.restrooms, :safelocation => @playground.safelocation, :seating => @playground.seating, :socialdom => @playground.socialdom, :specificcomments => @playground.specificcomments, :subarea => @playground.subarea, :totplay => @playground.totplay, :weather => @playground.weather }
    assert_redirected_to playground_path(assigns(:playground))
  end

  test "should destroy playground" do
    assert_difference('Playground.count', -1) do
      delete :destroy, :id => @playground
    end

    assert_redirected_to playgrounds_path
  end
end
