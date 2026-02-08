class ApplicationController < ActionController::API
  before_action :authenticate_user!, unless: :skip_authentication?

  attr_reader :current_user

  private

  def authenticate_user!
    token = extract_token
    user_id = JwtService.decode(token)

    if user_id
      @current_user = User.find_by(id: user_id)
      render_unauthorized('Invalid token') unless @current_user
    else
      render_unauthorized('Missing or invalid token')
    end
  end

  def extract_token
    header = request.headers['Authorization']
    header&.split(' ')&.last
  end

  def render_unauthorized(message = 'Unauthorized')
    render json: {
      error: {
        message: message,
        details: {}
      }
    }, status: :unauthorized
  end

  def skip_authentication?
    false
  end
end
