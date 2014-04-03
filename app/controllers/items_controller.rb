class ItemsController < ApplicationController
  before_action :authenticate
  before_action :set_storage
  before_action :set_item, only: [:show, :update, :destroy, :changes]

  # GET /storages/:storage_id/files
  # retrieve items of the root folder
  def index
    puts params
    @items = @storage.root.nil? ? [] : @storage.root.children
    render json: @items
  end

  # GET /storages/:storage_id/files/1
  def show
    render json: {file: @item, children: @item.children}
  end

  # PATCH/PUT /storages/:storage_id/files/1
  def update
    if @item.update(item_params)
      head :no_content
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  # DELETE /storages/:storage_id/files/1
  def destroy
    ctrl = ApiController.get_controller(@storage, session)
    ctrl.authenticate
    if (ctrl.delete(@item))
      @item.destroy
      render json: @item, status: :ok
    else
      render json: @item, status: :unprocessable_entity
    end
  end

  # GET /storages/:storage_id/files/1/changes
  # retrieve remote changes
  def changes
    ctrl = ApiController.get_controller(@storage, session)
    ctrl.authenticate
    remote_file_changes = ctrl.update_files(nil, @item.remote_id)
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
    @storage = Storage.where(:id => params[:storage_id], :user_id => current_user.id).first
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_item
    @item = Item.where(:storage_id => @storage.id, :id => params[:id]).first
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def item_params
    params.require(:item).permit(:title, :description, :parent_remote_id)
  end
end
