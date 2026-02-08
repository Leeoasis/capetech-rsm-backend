json.user do
  json.partial! 'api/v1/users/user', user: @user
end

json.tokens do
  json.access_token @access_token
  json.refresh_token @refresh_token
  json.token_type "Bearer"
  json.expires_in @expires_in
end
