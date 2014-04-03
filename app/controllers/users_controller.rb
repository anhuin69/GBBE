class UsersController < ApplicationController
  before_action :authenticate, :except => [:create, :token]

  # GET /users/1
  # GET /users/1.json
  def show
    render json: @user
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user = User.find(params[:id])

    if @user.update(params[:user])
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def token
    @user = User.authenticate_with_credentials(user_params)

    if (@user)
      render json: @user.authentication_token
    else
      render json: 'bad credentials', status: :not_acceptable
    end
  end

  private
  def user_params
    params.require(:user).permit(:username, :email, :password)
  end

end
