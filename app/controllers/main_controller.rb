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
    dir = Rails.root + "public/profile_pictures/"

    @current_user = User.where(:fb_id => @me['id']).first
    if @current_user.nil?
      @current_user = User.new(:fb_id => @me['id'])
    end
    img_src = @graph.get_picture(@me['id'])
    img_to = "#{dir}/#{@me['id']}.jpg"

    img_read = open(img_src).read

    file_download = open(img_to, "wb")
    file_download.write(img_read)
    file_download.close    

    @current_user.profile_picture = File.open(img_to)
    @current_user.name = @me['name']
    @current_user.username = @me['username']
    @current_user.link = @me['link']
    @current_user.gender = @me['gender']
    @current_user.updated_time = @me['updated_time']

    if @current_user.save
      friends = @current_user.friends
      @not_friends = @current_user.friends
      @new_friends = []

      @friends.each do |friend|
        user = User.where(:fb_id => friend['id']).first

        if user.nil?
          user = User.new(:fb_id => friend['id'])
          user.name = friend['name']

          img_src = @graph.get_picture(friend['id'])
          img_to = "#{dir}/#{friend['id']}.jpg"

          img_read = open(img_src).read

          file_download = open(img_to, "wb")
          file_download.write(img_read)
          file_download.close    

          user.profile_picture = File.open(img_to)

          user.save
        end

        if !user.nil? && !user.profile_picture?
          img_src = @graph.get_picture(friend['id'])
          img_to = "#{dir}/#{friend['id']}.jpg"

          img_read = open(img_src).read

          file_download = open(img_to, "wb")
          file_download.write(img_read)
          file_download.close    

          user.profile_picture = File.open(img_to)
          user.save
        end

        @new_friends << user if !friends.include?(user)
        @not_friends -= [user]
      end

      @current_user.friends -= @not_friends
      @current_user.friends += @new_friends
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
    #    config = YAML.load_file(Rails.root.join("config/facebook.yml"))[Rails.env]
    #    @app_id = config['app_id']
    #    @secret = config['secret_key']
    @app_id = "386157988091848"
    @secret = "1ec0d8b30944fb02ed6f1f37f2920c23"

    @callback = "http://dev.wafflestudio.net:4000/oauth"
    @oauth = Koala::Facebook::OAuth.new(@app_id, @secret, @callback)

    @permission = session[:access_token].nil? ? false : true
  end

  def get_graph
    if @permission
      @graph = Koala::Facebook::API.new(session[:access_token])
      @me = @graph.get_object("me")
      @friends = @graph.get_connections("me", "friends")
    else
      redirect_to root_path
    end
  end
end
