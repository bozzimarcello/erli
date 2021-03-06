class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_filter :authorize, :check_building, :set_building
  
  protect_from_forgery with: :exception
  
  def authorize
    if !session[:user_id]
      redirect_to new_session_path
    end
  end
  
  def check_admin
    user = User.find(session[:user_id])
    if !user.admin?
      redirect_to new_session_path
    end
  rescue
    redirect_to new_session_path
  end
  
  def check_building
    if cookies[:building].present? && !Building.where(:id => cookies[:building]).first
      cookies[:building] = nil
    end
  end
  
  def check_building_cookie
    if cookies[:building].blank?
      redirect_to root_path
    end
  end
  
  def clear_building
    cookies[:building] = nil
  end
  
  def set_building
    if cookies[:building].present?
      @main_building = Building.find(cookies[:building])
    end
  end
  
end
