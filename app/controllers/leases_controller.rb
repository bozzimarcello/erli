class LeasesController < ApplicationController
  before_filter :check_admin, :check_building_cookie
  
  def index
    @apartments = Apartment.where(:building_id => cookies[:building]).order("name ASC").all
  end
  
  def new
    @lease = Lease.new(:apartment_id => params[:apartment_id])
    @contracts = Contract.all
    @apartment = Apartment.find(params[:apartment_id])
    render :layout => false
  end
  
  def create
    @lease  = Lease.new(lease_params)
    user = @lease.users.first
    user.passwd, user.passwd_confirmation = user.make_temporary_password
    
    if @lease.save
      flash[:notice] = "Locazione salvata con successo"
      redirect_to leases_path
    else
      respond_to do |format|
        format.json { render :json => {:errors => @lease.errors.full_messages} }
        format.html { render "new" }
      end
    end
  end
  
  def edit
    
  end
  
  def update
    
  end
  
  def destroy
    
  end
  
  private
  def lease_params
    params.require(:lease)
    .permit(:percentage, :contract_id, :apartment_id, :invoice_address, :start_date, :end_date, :amount,
            :payment_frequency, :deposit, :registration_date, :registration_number, :registration_agency,
            :users_attributes => [:first_name, :last_name, :email, :codice])
  end
  
end