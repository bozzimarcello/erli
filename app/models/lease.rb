class Lease < ActiveRecord::Base
  
  belongs_to :apartment
  belongs_to :contract
  has_many :users, :dependent => :destroy
  has_many :lease_attachments, :dependent => :destroy
  has_many :asset_expenses, as: :asset, :dependent => :destroy
  has_many :cached_tenants, :dependent => :destroy
  has_many :invoices, :dependent => :destroy
  has_many :invoice_charges, :dependent => :destroy
  has_many :events, :dependent => :destroy
  
  accepts_nested_attributes_for :users, reject_if: proc { |attributes| attributes['last_name'].blank? || attributes['email'].blank? }
  accepts_nested_attributes_for :lease_attachments, reject_if: proc { |attributes| attributes['document'].blank? }
  accepts_nested_attributes_for :asset_expenses, reject_if: proc {|attrs| attrs['amount'].blank? }
  
  validates :contract_id, :apartment_id, :invoice_address, :start_date,
            :end_date, :amount, :payment_frequency, :deposit, :presence => true
            
  validates :contract_id, :apartment_id, :payment_frequency, :numericality => {:only_integer => true}
  validates :registration_number, :numericality => {:only_integer => true}, :allow_blank => true
  validates :deposit, :amount, :numericality => true
  validate :percentage_maximum
  
  after_save do |l|
    tenant = l.users.order("created_at DESC").select {|u| !u.secondary }.first
    l.users.all.each {|u| u.update_column(:tenant_id, tenant.id) if u.secondary && !u.tenant_id }
  end
  
  alias :original_users_attributes= :users_attributes=
  def users_attributes=(attrs)
    attrs.each do |k, v|
      p = User.new.make_temporary_password
      v.merge!("passwd" => p, "passwd_confirmation" => p)
    end
    puts attrs
    self.original_users_attributes = attrs
  end
  
  def frequency_description
    if payment_frequency == 1
      "Mensile"
    elsif payment_frequency == 3
      "Trimestrale"
    else
      ""
    end
  end 
  
  def address
    [invoice_address, home_number, cap, localita, provincia].join(" ")
  end
  
  def searchable_attributes
    ([contract.name, address, cap, localita, provincia, start_date.strftime("%d-%m-%Y"),
     end_date.strftime("%d-%m-%Y"), registration_date.strftime("%d-%m-%Y"), amount.to_s,
     payment_frequency.to_s + " Mesi", deposit.to_s, registration_number.to_s, registration_agency,
     payment_frequency.to_s + " Mese"] + cached_tenants.map(&:summary) ).join(" ")
  end
  
  def build_expenses(building_id)
    expenses = Expense.where("building_id = ? and balance_date_id IS NOT NULL and add_to_invoice = ?",
                             building_id, true).all
    if new_record?
      expenses.each {|e| asset_expenses.build(:expense_id => e.id, :amount => 0) }
    else
      expenses.each do |e| 
        unless asset_expenses.where("expense_id = ?", e.id).count > 0
          asset_expenses.build(:expense_id => e.id, :amount => 0)
        end
      end
    end
  end
  
  def percentage
    users.map(&:percentage).sum
  end
  
  def cache_users
    users.where(:secondary => false).each do |u|
      CachedTenant.create(:name => u.name, :codice_fiscale => u.codice_fiscale, :partita_iva => u.partita_iva,
        :percentage => u.percentage, :email => u.email, :lease_id => u.lease_id)
    end
  end
  
  def partial_start_date?
    start_date.mday != 1
  end
  
  def monthly_charge
    (amount/12.0 * 100).round / 100.0
  end
  
  def daily_charge
    (amount/(Date.today.all_year.count) * 100).round / 100.0
  end
  
  def lease_months
    if payment_frequency > 1 || end_date == end_date.end_of_month || 
      !partial_start_date? && end_date.mday > 15 
      from, count = start_date, 0
      while from < end_date
        count += 1
        from = from.next_month
      end
      count
    else
      ((start_date.year * 12 + start_date.month) - (end_date.year * 12 + end_date.month)).abs
    end
  end
  
  def ratio
    if fully_charged?
      1
    else
      percentage / 100.0
    end
  end
  
  private
  
  def percentage_maximum
    if percentage > 100
      errors.add(:base, "La percentuale del contratto di locazione e superiore a 100")
    end
  end
end
