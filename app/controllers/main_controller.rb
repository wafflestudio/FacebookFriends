#encoding: utf-8
class MainController < ApplicationController
  before_filter :get_key
  before_filter :get_graph, :only => [:friends, :test]

  def test
    @query = @graph.fql_query("select description, description_tags, type from stream where source_id = me() limit 500")
  end

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

    if @current_user.updated_at.nil?
      updated_at = Time.now
    else
      updated_at = @current_user.updated_at
    end

    img_src = @graph.get_picture(@me['id'])

    @current_user.name = @me['name']
    @current_user.username = @me['username']
    @current_user.link = @me['link']
    @current_user.gender = @me['gender']
    @current_user.updated_time = @me['updated_time']
    @current_user.thumbnail = img_src

    if @current_user.save
      friends = @current_user.friends
      @not_friends = @current_user.friends
      @new_friends = []
      @deactivated = []

      @friends.each do |friend|
        user = User.where(:fb_id => friend['id']).first

        if user.nil?
          user = User.new(:fb_id => friend['id'])
          user.name = friend['name']
          user.thumbnail = "http://graph.facebook.com/#{friend['id']}/picture"
          user.save
        end

        @new_friends << user if !friends.include?(user)
        @not_friends -= [user]
      end

      @not_friends.each do |not_friend|
        @deactivated << not_friend if @graph.get_object(not_friend.fb_id) == false
      end

      @current_user.friends -= @not_friends
      @current_user.friends += @new_friends
      @current_user.save

#      @graph.put_wall_post("#{updated_at.to_s[0..9]} 이후 #{@me['name']}님이 새로운 #{@new_friends.count}명과 친구를 맺고 #{@not_friends.count}명의 친구가 떠나서 총 #{@current_user.friends.count - 1}명의 친구가 있습니다. Facebook Friends에서 확인하세요!! http://goo.gl/w5ynd")
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
