json.users @users do |user|
  json.partial! 'api/v1/users/user', user: user
end

json.pagination do
  json.current_page @users.current_page
  json.total_pages @users.total_pages
  json.total_count @users.total_count
  json.per_page @users.limit_value
end
