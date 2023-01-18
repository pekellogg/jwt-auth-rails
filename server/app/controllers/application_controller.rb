class ApplicationController < ActionController::API
  # call the authorized method before anything else happens in our app. 
  before_action :authorized

  def encode_token(payload)
    # don't forget to hide your secret in an environment variable
    # payload => { beef: 'steak' }
    JWT.encode(payload, 'my_s3cr3t')
    # jwt string: "eyJhbGciOiJIUzI1NiJ9.eyJiZWVmIjoic3RlYWsifQ._IBTHTLGX35ZJWTCcY30tLmwU9arwdpNVxtVU0NpAuI"
  end

  def auth_header
    # { 'Authorization': 'Bearer <token>' }
    request.headers['Authorization']
  end

  # sample corresponding fetch request
  # fetch("http://localhost:3000/api/v1/profile", {
  #   method: "GET",
  #   headers: {
  #     Authorization: `Bearer <token>`,
  #   },
  # });

  def decoded_token
    # token => "eyJhbGciOiJIUzI1NiJ9.eyJiZWVmIjoic3RlYWsifQ._IBTHTLGX35ZJWTCcY30tLmwU9arwdpNVxtVU0NpAuI"
    if auth_header
      token = auth_header.split(' ')[1]
      # header: { 'Authorization': 'Bearer <token>' }
      begin
        # JWT.decode => [{ "beef"=>"steak" }, { "alg"=>"HS256" }]
        # JWT.decode(token, 'my_s3cr3t')[0]
        # [0] gives us the payload { "beef"=>"steak" }
        JWT.decode(token, 'my_s3cr3t', true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def current_user
    if decoded_token
      # decoded_token=> [{"user_id"=>2}, {"alg"=>"HS256"}]
      # or nil if we can't decode the token
      user_id = decoded_token[0]['user_id']
      @user = User.find_by(id: user_id)
    end
  end

  def logged_in?
    !!current_user
  end

  def authorized
    render json: { message: 'Please log in' }, status: :unauthorized unless logged_in?
  end
end
