class UnpaidAlarmsController < ApplicationController
  before_filter :check_building_cookie
  before_filter :check_admin
  
  def index
    @alarms = UnpaidAlarm.where("building_id = ?", cookies[:building]).all
  end
  
  def new
    @alarm = UnpaidAlarm.new
  end
  
  def create
    @alarm = UnpaidAlarm.new(unpaid_alarm_params)
    
    if @alarm.save
      flash[:notice] = "Allarme non pagato salvato con successo"
      redirect_to unpaid_alarms_path
    else
      render "new"
    end
  end
  
  def edit
    @alarm = UnpaidAlarm.find(params[:id])
  end
  
  def update
    @alarm = UnpaidAlarm.find(params[:id])
    
    if @alarm.update(unpaid_alarm_params)
      flash[:notice] = "Allarme non pagato aggiornato con successo"
      redirect_to unpaid_alarms_path
    else
      render "edit"
    end
  end
  
  def destroy
    @alarm = UnpaidAlarm.find(params[:id])
    @alarm.destroy
    
    flash[:notice] = "Allarme non pagato cancellato con successo"
    redirect_to unpaid_alarms_path
  end
  
  def set_unpaid_alarms
    building = Building.find(cookies[:building])
    unpaid_mavs = Mav.where("building_id = ? AND status = 'Da Pagare' " + 
                             "AND expiration < ? AND document IS NOT NULL", 
                             building.id, Date.today).all
    UnpaidAlarm.set_unpaid_alarms(building, unpaid_mavs)
    flash[:notice] = "Allarme non pagato impostati"
    redirect_to unpaid_alarms_path
  end
  
  private
  
  def unpaid_alarm_params
    params.require(:unpaid_alarm).permit(:body, :days, :building_id)
  end
end