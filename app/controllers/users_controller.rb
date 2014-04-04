class UsersController < ApplicationController
  before_action :authenticate, :except => [:create, :token]

  # GET /account/info
  def show
    render json: @user
  end

  # POST /account/create
  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /account/update
  def update
    if @user.update(params[:user])
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # POST /account/token
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
