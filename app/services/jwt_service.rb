class JwtService
  ACCESS_TOKEN_EXPIRATION = 900 # 15 minutes
  REFRESH_TOKEN_EXPIRATION = 604800 # 7 days

  class << self
    def encode(payload, token_type: :access)
      expiration = token_type == :access ? ACCESS_TOKEN_EXPIRATION : REFRESH_TOKEN_EXPIRATION
      payload[:exp] = Time.now.to_i + expiration
      JWT.encode(payload, secret_key, 'HS256')
    end

    def decode(token)
      decoded = JWT.decode(token, secret_key, true, algorithm: 'HS256')
      decoded[0]['user_id']
    rescue JWT::ExpiredSignature
      nil
    rescue JWT::DecodeError
      nil
    rescue StandardError
      nil
    end

    private

    def secret_key
      ENV['JWT_SECRET_KEY'] || raise('JWT_SECRET_KEY not configured')
    end
  end
end
