class MainController < ApplicationController
  before_filter :get_key
  before_filter :get_graph, :only => [:friends]

  def home
  end

  def oauth
    session[:access_token] = @oauth.get_access_token(params[:code]) if params[:code]
    redirect_to session[:access_token] ? root_path : failure_path
  end

  def friends
    @current_user = User.where(:fb_id => @me['id']).first
    if @current_user.nil?
      @current_user = User.new(:fb_id => @me['id'])
    end
    @current_user.name = @me['name']

    if @current_user.save
      @friends.each do |friend|
        user = User.where(:fb_id => friend['id']).first
        if user.nil?
          user = User.new(:fb_id => friend['id'])
        end
        user.name = friend['name']
        user.friends << @current_user
        @current_user.friends << user if user.save
      end
      @current_user.save
    else
      redirect_to root_path # redirect_to back
    end
  end

  def signout
    session[:access_token] = nil
    redirect_to root_path
  end

  private
  def get_key
    config = YAML.load_file(Rails.root.join("config/facebook.yml"))[Rails.env]
    @app_id = config['app_id']
    @secret = config['secret_key']

    @callback = "http://dev.wafflestudio.net:4000/oauth"
    @oauth = Koala::Facebook::OAuth.new(@app_id, @secret, @callback)

    @permission = session[:access_token].nil? ? false : true
  end

  def get_graph
    if !session[:access_token].nil?
      @graph = Koala::Facebook::API.new(session[:access_token])
      @me = @graph.get_object("me")
      @friends = @graph.get_connections("me", "friends")
    else
      redirect_to root_path
    end
  end
end
