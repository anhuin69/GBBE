require 'test_helper'

class StoragesControllerTest < ActionController::TestCase

  def init_token_header(user)
    @user = users(user)
    @request.headers['HTTP_AUTHORIZATION'] = "Token #{@user.authentication_token},#{@user.email}"
  end

  test 'Should get the link to add a gdrive storage' do
    init_token_header(:fabrice)
    post :create, storage: {provider: 'google_drive'}
    result = JSON.parse(@response.body)
    assert_response :ok
    assert_not_empty result['url']
  end

  test 'Should get the link to add a dropbox storage' do
    init_token_header(:fabrice)
    post :create, storage: {provider: 'dropbox'}
    result = JSON.parse(@response.body)
    assert_response :ok
    assert_not_empty result['url']
  end

  test 'Should get a missing parameters error' do
    init_token_header(:fabrice)
    post :create
    result = JSON.parse(@response.body)
    assert_response :unprocessable_entity
    assert_not_empty result['errors']['storage']
  end

  test 'Should get an error while trying to add a bad storage' do
    init_token_header(:fabrice)
    post :create, storage: {provider: 'bad_storage_name'}
    result = JSON.parse(@response.body)
    assert_response :unprocessable_entity
  end

  test 'Should return a list of user storages' do
    init_token_header(:fabrice)
    get :index
    result = JSON.parse(@response.body)
    assert_response :ok
    assert_operator result.size, :>, 0
  end

  test 'Should return storage informations' do
    init_token_header(:fabrice)
    get :show, :id => 1
    result = JSON.parse(@response.body)
    assert_response :ok
    assert_equal result['storage']['id'], 1
    assert_not_empty result['storage']['provider']
  end

  test 'Should return error storage not found' do
    init_token_header(:fabrice)
    get :show, :id => -1
    result = JSON.parse(@response.body)
    assert_response :unprocessable_entity
    assert_equal result['error'], 'storage not found'
  end

  test 'Should return error storage not found (bad user)' do
    init_token_header(:fabrice)
    get :show, :id => 2
    result = JSON.parse(@response.body)
    assert_response :unprocessable_entity
    assert_equal result['error'], 'storage not found'
  end

  test 'Should return updated storage informations of all user storages' do
    init_token_header(:fabrice)
    get :index
    assert_response :ok
    result = JSON.parse(@response.body)
    result.each do |s|
      get :show, :id => s['id']
      s_result = JSON.parse(@response.body)
      assert_response :ok
      assert_equal s['id'], s_result['storage']['id']
    end
  end

  test 'Should return error revoked storage access' do
    init_token_header(:aymeric)
    get :changes, :id => 2
    result = JSON.parse(@response.body)
    assert_response :not_acceptable
    assert_not_empty result['error']
  end

  test 'Should return error revoked storage access' do
    init_token_header(:aymeric)
    get :changes, :id => 3
    result = JSON.parse(@response.body)
    assert_response :unprocessable_entity
    assert_not_empty result['error']
  end

  test 'Should delete one storage' do
    init_token_header(:fabrice)
    get :index
    result = JSON.parse(@response.body)
    assert_response :ok
    before_delete_count = result.size

    delete :destroy, :id => 3
    assert_response :ok

    get :index
    result = JSON.parse(@response.body)
    assert_equal (before_delete_count - 1), result.size
  end

  test 'Should fail deleting other user storage' do
    init_token_header(:fabrice)
    get :index
    result = JSON.parse(@response.body)
    assert_response :ok
    before_delete_count = result.size

    delete :destroy, :id => 2
    assert_response :unprocessable_entity

    get :index
    result = JSON.parse(@response.body)
    assert_equal (before_delete_count - 1), result.size
  end
end
