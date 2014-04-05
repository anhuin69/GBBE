require 'api/api_controller'
require 'api/google_drive_controller'

class ItemsController < ApplicationController
  before_action :authenticate
  before_action :set_storage
  before_action :set_item, only: [:show, :update, :destroy, :changes]

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
    new_params.delete(:provider) # just in case TODO: this is ugly -> to improve
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
      render json: {error: message}, status: :unprocessable_entity
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
      render json: {error: message}, status: :unprocessable_entity
    end
  end

  # GET /storages/:storage_id/files/1/changes
  # retrieve remote changes
  def changes
    controller = ApiController.get_controller(@storage)
    status_code, remote_file_changes = controller.changes

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
      render json: {error: "impossible to load changes"}, status: :unprocessable_entity
    end
    return

    remote_file_changes.each do |remote_id, remote_file|
      local_item = Item.where(:storage_id => @storage.id, :remote_id => remote_id).first
      if (remote_file.nil? && local_item != nil)
        local_item.destroy
      elsif (remote_file != nil && local_item != nil)
        local_item.update(remote_file)
      else
        local_item = Item.new(remote_file)
        local_item.save
      end
    end
    show
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
