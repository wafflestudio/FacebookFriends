# encoding: utf-8
class MainController < ApplicationController
  skip_before_filter :get_graph, :only => [:oauth, :home]

  def test
    @query = @graph.fql_query("select description, description_tags, type from stream where source_id = me() limit 500")
  end

  def home
  end

  def oauth
    session[:access_token] = @oauth.get_access_token(params[:code]) if params[:code]
    redirect_to session[:access_token] ? root_path : failure_path
  end

  def signout
    session[:access_token] = nil
    redirect_to root_path
  end
end
