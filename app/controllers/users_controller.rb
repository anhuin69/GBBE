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
      render json: {errors: @user.errors}, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /account/update
  def update
    if @user.update(user_params)
      show
    else
      render json: {errors: @user.errors}, status: :unprocessable_entity
    end
  end

  # POST /account/token
  def token
    @user = User.authenticate_with_credentials(user_params)

    if (@user)
      render json: {token: @user.authentication_token}
    else
      render json: {error: 'bad credentials'}, status: :not_acceptable
    end
  end

  private
  def user_params
    params.require(:user).permit(:username, :email, :password)
  end

end
