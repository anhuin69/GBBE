require 'test_helper'

class ItemsControllerTest < ActionController::TestCase

  def init_token_header(user)
    @user = users(user)
    @request.headers['HTTP_AUTHORIZATION'] = "Token #{@user.authentication_token},#{@user.email}"
  end

  def init_storage(storage)
    @storage = storages(storage)
    @controller = StoragesController.new
    get :changes, :id => storages(storage).id
    assert_response :ok
    @controller = ItemsController.new
  end

  test 'Should get storage root file and children' do
    init_token_header(:fabrice)
    init_storage(:google_drive_fabrice)

    get :index, :storage_id => @storage.id
    assert_response :ok
    result = JSON.parse(@response.body)
    assert_not_nil result['file']
    assert_not_nil result['children']
  end

end
