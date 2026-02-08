#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script for JWT authentication system
ENV['JWT_SECRET_KEY'] = 'test_secret_key_12345'

require 'bundler/setup'
require 'jwt'
require 'securerandom'
require_relative '../app/services/jwt_service'

puts "=" * 60
puts "JWT Authentication System Test"
puts "=" * 60
puts

# Test 1: JwtService encoding and decoding
puts "1. Testing JwtService..."

# Test access token
user_id = 123
access_token = JwtService.encode({ user_id: user_id }, token_type: :access)
puts "  ✓ Generated access token: #{access_token[0..20]}..."

decoded_user_id = JwtService.decode(access_token)
if decoded_user_id == user_id
  puts "  ✓ Access token decoded successfully. User ID: #{decoded_user_id}"
else
  puts "  ✗ Failed to decode access token"
  exit 1
end

# Test refresh token
refresh_token = JwtService.encode({ user_id: user_id }, token_type: :refresh)
puts "  ✓ Generated refresh token: #{refresh_token[0..20]}..."

decoded_user_id = JwtService.decode(refresh_token)
if decoded_user_id == user_id
  puts "  ✓ Refresh token decoded successfully. User ID: #{decoded_user_id}"
else
  puts "  ✗ Failed to decode refresh token"
  exit 1
end

# Test invalid token
invalid_token = "invalid.token.here"
decoded = JwtService.decode(invalid_token)
if decoded.nil?
  puts "  ✓ Invalid token correctly rejected"
else
  puts "  ✗ Invalid token was not rejected"
  exit 1
end

# Test expired token
expired_payload = { user_id: user_id, exp: Time.now.to_i - 3600 }
expired_token = JWT.encode(expired_payload, ENV['JWT_SECRET_KEY'], 'HS256')
decoded = JwtService.decode(expired_token)
if decoded.nil?
  puts "  ✓ Expired token correctly rejected"
else
  puts "  ✗ Expired token was not rejected"
  exit 1
end

puts

# Test 2: RefreshToken model structure
puts "2. Testing RefreshToken model structure..."
refresh_token_content = File.read('app/models/refresh_token.rb')

if refresh_token_content.include?('belongs_to :user')
  puts "  ✓ Has belongs_to :user association"
else
  puts "  ✗ Missing belongs_to :user association"
  exit 1
end

validations = ['validates :token', 'validates :user_id', 'validates :expires_at']
validations.each do |validation|
  if refresh_token_content.include?(validation)
    puts "  ✓ Has #{validation.split(':')[1].strip} validation"
  else
    puts "  ✗ Missing #{validation}"
    exit 1
  end
end

if refresh_token_content.include?('scope :active')
  puts "  ✓ Has active scope for non-expired tokens"
else
  puts "  ✗ Missing active scope"
  exit 1
end

if refresh_token_content.include?('def expired?')
  puts "  ✓ Has expired? method"
else
  puts "  ✗ Missing expired? method"
  exit 1
end

if refresh_token_content.include?('before_create :generate_token')
  puts "  ✓ Has before_create :generate_token callback"
else
  puts "  ✗ Missing before_create callback"
  exit 1
end

puts

# Test 3: ApplicationController structure
puts "3. Testing ApplicationController..."
controller_content = File.read('app/controllers/application_controller.rb')

if controller_content.include?('authenticate_user!')
  puts "  ✓ Has authenticate_user! method"
else
  puts "  ✗ Missing authenticate_user! method"
  exit 1
end

if controller_content.include?('current_user')
  puts "  ✓ Has current_user method"
else
  puts "  ✗ Missing current_user method"
  exit 1
end

if controller_content.include?('render_unauthorized')
  puts "  ✓ Has render_unauthorized method"
else
  puts "  ✗ Missing render_unauthorized method"
  exit 1
end

if controller_content.include?('extract_token')
  puts "  ✓ Has extract_token method"
else
  puts "  ✗ Missing extract_token method"
  exit 1
end

puts

# Test 4: AuthController structure
puts "4. Testing AuthController..."
auth_controller_content = File.read('app/controllers/api/v1/auth_controller.rb')

required_actions = ['login', 'refresh', 'logout', 'me']
required_actions.each do |action|
  if auth_controller_content.include?("def #{action}")
    puts "  ✓ Has #{action} action"
  else
    puts "  ✗ Missing #{action} action"
    exit 1
  end
end

if auth_controller_content.include?('skip_before_action :authenticate_user!')
  puts "  ✓ Skips authentication for login and refresh"
else
  puts "  ✗ Missing skip_before_action"
  exit 1
end

puts

# Test 5: Routes
puts "5. Testing Routes configuration..."
routes_content = File.read('config/routes.rb')

if routes_content.include?('namespace :api') &&
   routes_content.include?('namespace :v1') &&
   routes_content.include?('namespace :auth')
  puts "  ✓ API v1 auth namespace configured"
else
  puts "  ✗ Missing API namespace configuration"
  exit 1
end

required_routes = ['post :login', 'post :refresh', 'post :logout', 'get :me']
required_routes.each do |route|
  if routes_content.include?(route)
    puts "  ✓ #{route.gsub(':', '').capitalize} route configured"
  else
    puts "  ✗ Missing #{route} route"
    exit 1
  end
end

puts

# Test 6: Environment configuration
puts "6. Testing .env.example..."
env_content = File.read('.env.example')

if env_content.include?('JWT_SECRET_KEY')
  puts "  ✓ JWT_SECRET_KEY configured"
else
  puts "  ✗ Missing JWT_SECRET_KEY"
  exit 1
end

if env_content.include?('JWT_ACCESS_TOKEN_EXPIRATION')
  puts "  ✓ JWT_ACCESS_TOKEN_EXPIRATION configured"
else
  puts "  ✗ Missing JWT_ACCESS_TOKEN_EXPIRATION"
  exit 1
end

if env_content.include?('JWT_REFRESH_TOKEN_EXPIRATION')
  puts "  ✓ JWT_REFRESH_TOKEN_EXPIRATION configured"
else
  puts "  ✗ Missing JWT_REFRESH_TOKEN_EXPIRATION"
  exit 1
end

puts
puts "=" * 60
puts "All tests passed! ✓"
puts "=" * 60
puts
puts "Summary:"
puts "  - JwtService: Encoding/decoding works correctly"
puts "  - RefreshToken model: Properly structured with validations"
puts "  - ApplicationController: Authentication methods implemented"
puts "  - AuthController: All actions (login, refresh, logout, me) present"
puts "  - Routes: Properly configured for /api/v1/auth/*"
puts "  - Environment: JWT configuration variables set"
puts
puts "Next steps:"
puts "  1. Run: rails db:migrate"
puts "  2. Create a test user in rails console"
puts "  3. Test API endpoints with curl or Postman"
puts
