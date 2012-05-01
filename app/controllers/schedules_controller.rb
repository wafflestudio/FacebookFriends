class SchedulesController < ApplicationController
  before_filter :get_key
  before_filter :get_graph, :only => [:index, :create]

  def index
    @schedules = @current_user.schedules
    @schedule = Schedule.new
    @user_json = User.all.map {|u| {"id" => u.id.to_s, "name" => u.name}}.to_json
  end

  def create
    @schedule = Schedule.new(params[:schedule].reject {|key,value| key['participants']})
    @schedule.participants = params[:schedule][:participants].split(",").map {|id| User.find(id)}
    @schedule.participants << @current_user 
    @schedule.admin = @current_user

    if !@schedule.participants.empty?  && !@schedule.admin.nil? && @schedule.save
      redirect_to schedule_path(@schedule)
    else
      @schedules = @current_user.schedules
      @user_json = User.all.map {|u| {"id" => u.id.to_s, "name" => u.name}}.to_json
      render "index"
    end
  end

  def show
    @schedule = Schedule.find(params[:id])
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
      @current_user = User.where(:fb_id => @me['id']).first
    else
      redirect_to root_path
    end
  end
end
