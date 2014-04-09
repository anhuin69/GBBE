require 'api/api_controller'
require 'api/google_drive_controller'
require 'api/dropbox_controller'

class StoragesController < ApplicationController
  before_action :authenticate
  before_action :set_storage, only: [:show, :update, :destroy, :changes]

  # GET /storages
  # return all user storages as JSON
  def index
    render json: @user.storages
  end

  # GET /storages/1
  # return storage informations as JSON
  def show
    render json: {storage: @storage, root: @storage.root}
  end

  # PATCH/PUT /storages/1
  # return ok or the errors
  def update
    new_params = storage_params
    new_params.delete(:provider) # just in case TODO: this is ugly -> to change
    if @storage.update(new_params)
      render json: {message: 'storage updated'}
    else
      render json: @storage.errors, status: :unprocessable_entity
    end
  end

  # DELETE /storages/1
  # Remove storage
  def destroy
    @storage.destroy
    render json: {message: 'storage removed'}
  end

  # Get remote changes
  # Also update root folder
  def changes(controller = nil)
    controller = ApiController.get_controller(@storage) if controller.nil?
    status_code, new_infos = controller.get_account_infos
    if (status_code == 200)
      @storage.login = new_infos[:login]
      @storage.picture_url = new_infos[:picture_url]
      @storage.quota_bytes_total = new_infos[:quota_bytes_total]
      @storage.quota_bytes_used = new_infos[:quota_bytes_used]
      @storage.uid = new_infos[:root_folder_id]
      status_code, new_file_infos = controller.file_get(@storage.uid)
      if @storage.save && status_code == 200
        if (@storage.root.nil?)
          @item = @storage.items.new(new_file_infos)
          @storage.root = @item
          saved = @item.save
        else
          @item = @storage.root
          saved = @item.update(new_file_infos)
        end
        if (saved)
          show
          return
        end
      end
    end
    render json: {error: new_infos}, status: status_code
  end

  # POST /storages
  # POST /storages.json
  def create
    @storage = @user.storages.new(storage_params)
    controller = ApiController.get_controller(@storage)
    unless controller.nil? || (url = controller.get_authorization_url).nil?
      render json: {url: url}
    else
      render json: {error: "unknown provider"}, status: :unprocessable_entity
    end
  end

  # Callback from oauth2 providers
  def link_account
    if (params.key?(:code) && params.key?(:format) && Gatherbox::Application.config.api.key?(params[:format]))
      @storage = @user.storages.new(:provider => params[:format])
      controller = ApiController.get_controller(@storage, params[:state])
      if !controller.nil? && controller.authorize(params[:code], params[:state]) && @storage.save
        changes(controller)
      else
        render json: {error: "invalid or revoked authorization code"}, status: :unprocessable_entity
      end
    else
      render json: {error: "missing authorization code"}, status: :unprocessable_entity
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_storage
    @storage = Storage.where(:id => params[:id], :user_id => @user.id).first
    if (@storage.nil?)
      render json: {error: "storage not found"}, status: :unprocessable_entity
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def storage_params
    params.require(:storage).permit(:login, :provider)
  end
end
