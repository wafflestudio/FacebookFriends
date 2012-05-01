FacebookFriend::Application.routes.draw do
  root :to => "main#home"

  match "/oauth" => "main#oauth"
  match "/friends" => "main#friends"
  match "/signout" => "main#signout"

  match "/test" => "main#test"

  scope "admin" do
    match "/users" => "admin#users"
    match "/script" => "admin#script"
    match "/history" => "admin#history"
  end

  resources :schedules
end
