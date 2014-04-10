require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test 'Should create user and return it\'s email and username' do
    new_user_params = { email: 'user11@gatherbox.com', username: 'User 11', password: 'qwerty'}
    post :create, user: new_user_params
    result = JSON.parse(@response.body)
    assert_response :created
    assert_equal new_user_params[:email], result['email']
    assert_equal new_user_params[:username], result['username']
  end

  test 'Should not create user without password' do
    user_params = { email: 'user2@gatherbox.com', username: 'User 2'}
    post :create, user: user_params
    result = JSON.parse(@response.body)
    assert_response :unprocessable_entity
    assert_not_nil result['errors']['password']
  end

  test 'Should not create user without email' do
    user_params = { password: 'qwerty', username: 'User 2'}
    post :create, user: user_params
    result = JSON.parse(@response.body)
    assert_response :unprocessable_entity
    assert_not_nil result['errors']['email']
  end

  test 'Should not create user with an already used email' do
    user_params = { email: 'fabrice@gatherbox.com', username: 'User 2'}
    post :create, user: user_params
    result = JSON.parse(@response.body)
    assert_response :unprocessable_entity
    assert_not_nil result['errors']['email']
  end

  test 'Should not accept request without user params' do
    post :create
    result = JSON.parse(@response.body)
    assert_response :unprocessable_entity
    assert_not_nil result['errors']
    assert_not_nil result['errors']['user']
  end

  test 'Should return a token' do
    @user = users(:fabrice)
    post :token, user: { email: @user.email, password: 'qwerty'}
    result = JSON.parse(@response.body)
    assert_response :ok
    assert_not_empty result['token']
  end

  test 'Should return a bad credentials error' do
    @user = users(:fabrice)
    post :token, user: { email: @user.email, password: 'qwertyuiop'}
    result = JSON.parse(@response.body)
    assert_response :not_acceptable
    assert_not_empty result['error']
    assert_equal 'bad credentials', result['error']
  end

  test 'Should show user informations' do
    @user = users(:fabrice)
    post :token, user: { email: @user.email, password: 'qwerty'}
    token = JSON.parse(@response.body)['token']
    @request.headers['HTTP_AUTHORIZATION'] = "Token #{token},#{@user.email}"

    get :show
    result = JSON.parse(@response.body)
    assert_response :ok
    assert_equal @user.email, result['email']
    assert_equal @user.username, result['username']
  end

  test 'Should return an HTTP Token error' do
    @user = users(:fabrice)
    post :token, user: { email: @user.email, password: 'qwerty'}
    token = JSON.parse(@response.body)['token']
    @request.headers['HTTP_AUTHORIZATION'] = "Token #{token},bad_email@gatherbox.com"

    get :show
    assert_response :unauthorized
    assert_match /HTTP Token: Access denied\.*/, @response.body
  end

  test 'Should update user username' do
    @user = users(:fabrice)
    post :token, user: { email: @user.email, password: 'qwerty'}
    token = JSON.parse(@response.body)['token']
    @request.headers['HTTP_AUTHORIZATION'] = "Token #{token},#{@user.email}"

    put :update, user: {username: 'new username'}
    result = JSON.parse(@response.body)
    assert_response :ok
    assert_equal @user.email, result['email']
    assert_equal 'new username', result['username']
  end

  test 'Should update user email' do
    @user = users(:fabrice)
    post :token, user: { email: @user.email, password: 'qwerty'}
    token = JSON.parse(@response.body)['token']
    @request.headers['HTTP_AUTHORIZATION'] = "Token #{token},#{@user.email}"

    put :update, user: {email: 'new_email@gatherbox.com'}
    result = JSON.parse(@response.body)
    assert_response :ok
    assert_equal 'new_email@gatherbox.com', result['email']
    assert_equal @user.username, result['username']
  end

  test 'Should fail update user email - already used' do
    @user = users(:fabrice)
    @user_2 = users(:aymeric)
    post :token, user: { email: @user.email, password: 'qwerty'}
    token = JSON.parse(@response.body)['token']
    @request.headers['HTTP_AUTHORIZATION'] = "Token #{token},#{@user.email}"

    put :update, user: {email: @user_2.email}
    result = JSON.parse(@response.body)
    assert_response :unprocessable_entity
    assert_not_nil result['errors']
  end

  test 'Should update user password' do
    @user = users(:fabrice)
    post :token, user: { email: @user.email, password: 'qwerty'}
    token = JSON.parse(@response.body)['token']
    @request.headers['HTTP_AUTHORIZATION'] = "Token #{token},#{@user.email}"

    put :update, user: {password: 'new password'}
    result = JSON.parse(@response.body)
    assert_response :ok
    assert_equal @user.email, result['email']

    post :token, user: { email: @user.email, password: 'new password'}
    token = JSON.parse(@response.body)['token']
    @request.headers['HTTP_AUTHORIZATION'] = "Token #{token},#{@user.email}"
    get :show
    assert_response :ok
  end

  test 'Should fail tpo update user password' do
    @user = users(:fabrice)
    post :token, user: { email: @user.email, password: 'qwerty'}
    token = JSON.parse(@response.body)['token']
    @request.headers['HTTP_AUTHORIZATION'] = "Token #{token},#{@user.email}"

    put :update, user: {password: 'pwd'}
    result = JSON.parse(@response.body)
    assert_response :unprocessable_entity
    assert_not_nil result['errors']
  end
end
