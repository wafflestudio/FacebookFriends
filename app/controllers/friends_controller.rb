# encoding: utf-8
class FriendsController < ApplicationController
  def index
    @current_user = User.where(:fb_id => @me['id']).first
    if @current_user.nil?
      @current_user = User.new(:fb_id => @me['id'])
    end

    if @current_user.updated_at.nil?
      updated_at = Time.now
    else
      updated_at = @current_user.updated_at
    end

    @current_user.name = @me['name']
    @current_user.username = @me['username']
    @current_user.link = @me['link']
    @current_user.gender = @me['gender']
    @current_user.thumbnail = "http://graph.facebook.com/#{@me['id']}/picture"
    @current_user.updated_time = @me['updated_time']
    @current_user.last_login = Time.now

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
        begin
          if @graph.get_object(not_friend.fb_id) == false
            @deactivated << not_friend 
          end
        rescue
          @deactivated << not_friend 
        end
      end

      @current_user.friends -= @not_friends
      @current_user.friends += @new_friends
      @current_user.friends -= [@current_user]

      if @current_user.save
        @not_friends.each do |friend|
          begin
            type = @graph.get_object(friend.fb_id) == false ? 1 : 2
            history = History.create(:from_id => @current_user.id, :to_id => friend.id, :type => type)
            history = History.create(:from_id => friend.id, :to_id => @current_user.id, :type => type)
          rescue
            history = History.create(:from_id => @current_user.id, :to_id => friend.id, :type => type)
            history = History.create(:from_id => friend.id, :to_id => @current_user.id, :type => type)
          end
        end
        @new_friends.each do |friend|
          history = History.create(:from_id => @current_user.id, :to_id => friend.id, :type => 0)
          history = History.create(:from_id => friend.id, :to_id => @current_user.id, :type => 0)
        end
      end

      #@graph.put_wall_post("#{updated_at.to_s[0..9]} 이후 #{@me['name']}님이 새로운 #{@new_friends.count}명과 친구를 맺고 #{@not_friends.count}명의 친구가 떠나서 총 #{@current_user.friends.count}명의 친구가 있습니다. Facebook Friends에서 확인하세요!! http://goo.gl/w5ynd")
      logger.info "#{updated_at.to_s[0..9]} 이후 #{@me['name']}님이 새로운 #{@new_friends.count}명과 친구를 맺고 #{@not_friends.count}명의 친구가 떠나서 총 #{@current_user.friends.count}명의 친구가 있습니다. Facebook Friends에서 확인하세요!! http://goo.gl/w5ynd"
      @notice = "새로고침할때마다 페이스북에 포스트가 올라가니 조심조심"
    else
      redirect_to root_path # redirect_to back
    end
  end
end
