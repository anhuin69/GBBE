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
    #ctrl = ApiController.get_controller(@storage, session)
    #ctrl.authenticate
    #ctrl.load_account_infos
    show
  end

  # POST /storages
  # POST /storages.json
  def create
    @storage = @user.storages.new(storage_params)
    ctrl = ApiController.get_controller(@storage, session)
    unless ctrl.nil?
      link = ctrl.link_account
      redirect_to link.to_s
      return
    end
  end

  # Callback called by google API when a user links a Google Drive
  def callback_link_account_google_oauth2
    if (params['code'].nil?)
      error = params['error']
      redirect_to authenticated_root_path, :alert => "Google Drive: #{error}"
    else
      code = params[:code]
      @storage = @user.storages.new
      @storage.provider = Gatherbox::Application.config.GoogleDrive[:PROVIDER]
      @storage.token = code
      ctrl = GoogleDriveController.new(@storage)
      ctrl.authenticate
      ctrl.load_account_infos

      unless (@user.storages.where(:uid => @storage.uid).length == 1)
        @storage.destroy
        redirect_to authenticated_root_path, :alert => "Google Drive: This drive has already been added"
        return
      end

      #create uninitialized root folder
      root_item = @storage.items.new(:remote_id => "root", :parent_remote_id => nil, :mimeType => "folder")
      root_item.save
      redirect_to authenticated_root_path
    end
  end

  # Callback called by dropbox API when a user links a Dropbox account
  def callback_link_account_dropbox_oauth2
    if (params['code'].nil?)
      error = params['error']
      error_description = params['error_description']
      redirect_to authenticated_root_path, :alert => "Dropbox: #{error} -> #{error_description}"
    else
      @storage = @user.storages.new
      @storage.provider = Gatherbox::Application.config.Dropbox[:PROVIDER]
      @storage.token = params['code']
      @storage.password = params['state']
      ctrl = DropboxController.new(@storage, session)
      ctrl.authenticate
      ctrl.load_account_infos

      unless (@user.storages.where(:uid => @storage.uid).length == 1)
        @storage.destroy
        redirect_to authenticated_root_path, :alert => "Dropbox: This drive has already been added"
        return
      end

      #create uninitialized root folder
      root_item = @storage.items.new(:remote_id => "/", :parent_remote_id => nil, :mimeType => "folder")
      root_item.save
      redirect_to authenticated_root_path
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
