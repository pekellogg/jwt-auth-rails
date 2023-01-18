class Api::V1::UsersController < ApplicationController
  # skip the before_action :authorized coming from ApplicationController
  # don't ask users to login before they create an account
  skip_before_action :authorized, only: [:create]

  def profile
    render json: { 
              user: UserSerializer.new(current_user)
            }, 
            status: :accepted
  end

  # corresponding client-side fetch for successful create
  # fetch("http://localhost:3000/api/v1/users", {
  #   method: "POST",
  #   headers: {
  #     "Content-Type": "application/json",
  #     Accept: "application/json",
  #   },
  #   body: JSON.stringify(newUserData),
  # })
  # .then((r) => r.json())
  # .then((data) => {
  #   # save the token to localStorage for future access
  #   localStorage.setItem("jwt", data.jwt);
  #   # save the user somewhere (in state!) to log the user in
  #   setUser(data.user);
  # });

  def create
    @user = User.create(user_params)
    if @user.valid?
      @token = encode_token({ user_id: @user.id })
      render json: { 
              user: UserSerializer.new(@user),
              jwt: @token
            }, 
            status: :created
    else
      render json: { 
              error: 'failed to create user'
            }, 
            status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :bio, :avatar)
  end
end
