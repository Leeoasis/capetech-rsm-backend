class ApplicationController < ActionController::API
  include Pundit::Authorization

  before_action :authenticate_user!, unless: :skip_authentication?
  after_action :verify_authorized, unless: :skip_authorization?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

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

  def skip_authorization?
    skip_authentication?
  end

  def user_not_authorized
    render json: {
      error: {
        message: 'You are not authorized to perform this action',
        details: {}
      }
    }, status: :forbidden
  end
end
