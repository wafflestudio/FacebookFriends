class AdminController < ApplicationController
  before_filter :get_key, :only => [:users]
  before_filter :get_graph, :only => []

  def users
    @users = User.all
  end

  def history
    @users = User.all(conditions: {gender: /male$/}, sort: [[:updated_at, :desc]])[0..100].reject {|u| u.updated_at.nil?}
  end

  def script
    User.all.each do |user|
      user.update_attributes(:thumbnail => "http://graph.facebook.com/#{user.fb_id}/picture")
    end
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
    if !sessions[:access_toekn].nil?
      @graph = Koala::Facebook::API.new(session[:access_token])
      @me = @graph.get_object("me")
      redirect_to root_path if @me["id"] != "100001644341965"
    else
      redirect_to root_path
    end
  end
end
