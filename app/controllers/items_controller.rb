require 'api/api_controller'
require 'api/google_drive_controller'
require 'api/dropbox_controller'

class ItemsController < ApplicationController
  before_action :authenticate
  before_action :set_storage
  before_action :set_item, only: [:show, :update, :destroy, :copy, :changes]

  # POST /storages/:storage_id/files
  # Create folder
  def create
    item = item_params
    controller = ApiController.get_controller(@storage)
    status_code, result = controller.create_folder(item[:title], item[:description], item[:parent_remote_id])
    if (status_code == 200)
      @item = @storage.items.new(result)
      if (@item.save)
        show
      else
        render json: {error: 'unknown error'}, status: :internal_server_error
      end
    else
      render json: {error: result}, status: status_code
    end
  end

  # POST /storages/:storage_id/upload
  # Upload new file
  # params {:title => mandatory, :description => optional, :parent_remote_id => optional (default = root)}
  def upload
    message = ''
    status_code = :unprocessable_entity
    if (params.key?(:file) && params[:file].respond_to?(:path))
      file_title = (params.key?(:title) && !params[:title].empty?) ? params[:title] : params[:file].original_filename
      parent = (params.key?(:parent_remote_id) && !params[:parent_remote_id].empty?) ? @storage.items.find_by_remote_id(params[:parent_remote_id]) : @storage.root
      if (parent.nil? || !parent.is_folder)
        message = parent.nil? ? 'bad parent folder remote id' : 'parent remote id is not a folder'
      else
        controller = ApiController.get_controller(@storage)
        mime_type = MIME::Types.type_for(params[:file].original_filename).first
        mime_type = mime_type.nil? ? 'text/plain' : mime_type.content_type

        status_code, result = controller.upload_file(parent.remote_id, file_title, mime_type, params[:file].path)
        if (status_code == 200)
          @item = @storage.items.new(result)
          if (@item.save)
            show
          else
            render json: {error: 'unknown error'}, status: :internal_server_error
          end
          return
        else
          message = result
        end
      end
    else
      message = 'missing parameters'
    end
    render json: {error: message}, status: status_code
  end

  # GET /storages/:storage_id/files
  # retrieve items of the root folder
  def index
    @items = @storage.root.nil? ? [] : @storage.root.children
    render json: @items
  end

  # GET /storages/:storage_id/files/1
  def show
    render json: {file: @item, children: @item.children}
  end

  # PATCH/PUT /storages/:storage_id/files/1
  def update
    new_params = item_params
    controller = ApiController.get_controller(@storage)

    if (new_params.key?(:parent_remote_id))
      status_code, message = controller.move(@item.remote_id, @item.parent_remote_id, new_params[:parent_remote_id])
      new_infos = {:parent_remote_id => new_params[:parent_remote_id]}
    else
      status_code, new_infos = controller.patch(@item.remote_id, new_params)
    end
    if (status_code == 200 && @item.update(new_infos))
      show
    else
      message = 'impossible to update file informations' if message.nil?
      render json: {error: message}, status: status_code
    end
  end

  # DELETE /storages/:storage_id/files/1
  def destroy
    controller = ApiController.get_controller(@storage)
    status_code, message = controller.delete(@item.remote_id)
    if (status_code == 200)
      @item.destroy
      render json: {message: 'file moved to trash'}
    else
      render json: {error: message}, status: status_code
    end
  end

  # POST /storages/:storage_id/files/:id/copy
  # if the post parameter copy_title is not specified the
  # copied item title is used
  # duplicate the file
  # TODO: maybe accept another parent_remote_id
  def copy
    controller = ApiController.get_controller(@storage)
    status_code, result = controller.copy(@item.remote_id, @item.parent_remote_id, (params.key?(:copy_title) ? params[:copy_title] : @item.title + ' - copy'))
    if (status_code == 200)
      item_copy = @storage.items.new(result)
      if item_copy.save
        @item = item_copy
        show
      else
        render json: {error: 'unknown error'}, status: :unprocessable_entity
      end
    else
      render json: {error: result}, status: status_code
    end
  end

  # GET /storages/:storage_id/files/1/changes
  # retrieve remote changes
  def changes
    controller = ApiController.get_controller(@storage)
    status_code, remote_file_changes = controller.changes(@item)

    if (status_code == 200)
      remote_file_changes.each do |remote_id, remote_item|
        local_item = @storage.items.where(:remote_id => remote_id).first
        if (local_item.nil? && !remote_item.nil?)
          local_item = @storage.items.new(remote_item)
          local_item.save
        elsif (!local_item.nil? && remote_item.nil?)
          local_item.destroy
        elsif (!local_item.nil? && !remote_item.nil?)
          local_item.update(remote_item)
        end
      end
      show
    else
      render json: {error: remote_file_changes}, status: status_code
    end
  end

  private
  def set_storage
    @storage = Storage.where(:id => params[:storage_id], :user_id => @user.id).first
    if (@storage.nil?)
      render json: {error: 'storage not found'}, status: :unprocessable_entity
    end
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_item
    @item = Item.where(:storage_id => @storage.id, :id => params[:id]).first
    if (@item.nil?)
      render json: {error: 'file not found'}, status: :unprocessable_entity
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def item_params
    params.require(:item).permit(:title, :description, :parent_remote_id)
  end
end
