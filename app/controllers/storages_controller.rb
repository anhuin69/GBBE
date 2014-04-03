class StoragesController < ApplicationController
  # GET /storages
  # GET /storages.json
  def index
    @storages = Storage.all

    render json: @storages
  end

  # GET /storages/1
  # GET /storages/1.json
  def show
    @storage = Storage.find(params[:id])

    render json: @storage
  end

  # POST /storages
  # POST /storages.json
  def create
    @storage = Storage.new(params[:storage])

    if @storage.save
      render json: @storage, status: :created, location: @storage
    else
      render json: @storage.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /storages/1
  # PATCH/PUT /storages/1.json
  def update
    @storage = Storage.find(params[:id])

    if @storage.update(params[:storage])
      head :no_content
    else
      render json: @storage.errors, status: :unprocessable_entity
    end
  end

  # DELETE /storages/1
  # DELETE /storages/1.json
  def destroy
    @storage = Storage.find(params[:id])
    @storage.destroy

    head :no_content
  end
end
