FacebookFriend::Application.routes.draw do
  root :to => "main#home"

  match "/test" => "main#test"

  match "/oauth" => "main#oauth"
  match "/signout" => "main#signout"

  scope "admin" do
    match "/users" => "admin#users"
    match "/script" => "admin#script"
    match "/history" => "admin#history"
  end

  resources :schedules
  match "/friends" => "friends#index"
end
