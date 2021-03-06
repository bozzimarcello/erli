module ApplicationHelper
  
  def logged_in?
    session[:user_id].present?
  end
  
  def logged_user
    if session[:user_id].present?
      User.find(session[:user_id])
    end
  end
  
  def buildings
    Building.order("name ASC").all
  end
  
  def lease_row_class(status)
    if status == "Occupato"
      "danger"
    elsif status == "Disponibile"
      "success"
    else
      "info"
    end
  end
end
