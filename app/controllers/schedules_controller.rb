class SchedulesController < ApplicationController
  def index
    @current_user = User.where(:fb_id => @me['id']).first

    @schedules = @current_user.schedules
    @schedule = Schedule.new
    @user_json = User.all.map {|u| {"id" => u.id.to_s, "name" => u.name}}.to_json
  end

  def create
    @current_user = User.where(:fb_id => @me['id']).first

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
end
