class ApplicationController < ActionController::Base
#  protect_from_forgery
  before_filter :get_key
  before_filter :get_graph

  private
  def get_key
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
