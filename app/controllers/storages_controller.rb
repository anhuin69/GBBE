require 'api/api_controller'
require 'api/google_drive_controller'

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
    if @storage.update(storage_params)
      head :no_content
    else
      render json: @storage.errors, status: :unprocessable_entity
    end
  end

  # DELETE /storages/1
  def destroy
    @storage.destroy
    head :no_content
  end

  # Get remote changes
  def changes
    ctrl = ApiController.get_controller(@storage)
    new_infos = ctrl.get_account_infos
    if (new_infos[:code] == 200)
      @storage.login = new_infos[:login]
      @storage.picture_url = new_infos[:picture_url]
      @storage.quota_bytes_total = new_infos[:quota_bytes_total]
      @storage.quota_bytes_used = new_infos[:quota_bytes_used]
      @storage.uid = new_infos[:root_folder_id]
      show if @storage.save
      return
    end
    render json: {error: "impossible to update storage informations"}, status: :internal_server_error
  end

  # POST /storages
  # POST /storages.json
  def create
    @storage = @user.storages.new(storage_params)
    controller = ApiController.get_controller(@storage)
    unless controller.nil? || (url = controller.get_authorization_url).nil?
      render json: {url: url}
    else
      render json: {error: "unknown provider"}, status: :internal_server_error
    end
  end

  # Callback from provider
  def link_account
    if (params.key?(:code))
      @storage = @user.storages.new(:provider => "google_drive") #TODO: change that to manage all drive in uniformly
      controller = ApiController.get_controller(@storage)
      if !controller.nil? && controller.authorize(params[:code]) && @storage.save
        show
      else
        render json: {error: "invalid authorization code"}, status: :unprocessable_entity
      end
    else
      render json: {error: "missing authorization code"}, status: :unprocessable_entity
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_storage
    @storage = Storage.where(:id => params[:id], :user_id => @user.id).first
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def storage_params
    params.require(:storage).permit(:provider, :token, :login, :password, :url, :port, :quota_bytes_total, :quota_bytes_used, :User)
  end
end
