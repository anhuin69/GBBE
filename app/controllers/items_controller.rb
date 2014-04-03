class ItemsController < ApplicationController
  # GET /items
  # GET /items.json
  def index
    @items = Item.all

    render json: @items
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @item = Item.find(params[:id])

    render json: @item
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(params[:item])

    if @item.save
      render json: @item, status: :created, location: @item
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    @item = Item.find(params[:id])

    if @item.update(params[:item])
      head :no_content
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    head :no_content
  end
end
