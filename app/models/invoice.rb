class Invoice < ActiveRecord::Base
  has_many :invoice_charges, :dependent => :destroy
  
  
  def self.generate(building_id, invoice_date=Date.today)
    Lease.where(:active => true).all.each do |lease|
    if lease.registration_date.present? && (lease.start_date..lease.end_date).include?(invoice_date)
      invoice = self.new
      if charge_rent?(lease, invoice_date)
        rent = invoice.invoice_charges.build(:kind => "rent", :lease_id => lease.id)
        period = charge_period(lease, invoice_date)
        rent.start_date, rent.end_date = period.first, period.last
        rent.amount = charge_amount_with_istat(lease, invoice_date)
      end
      
    end
  end
  
  def self.apartment_expenses(apartment, lease)
    apartment.asset_expenses.where("invoice_id IS NULL AND lease_id = ? AND paid_on IS NULL", lease.id).all
  end
  
  def self.registered_leases(building_id)
    Lease.where("active = ? AND building_id = ? AND registration_date IS NOT NULL AND registration_date <> ''",
                true, building_id).all
  end
  
  private
  # This lease is for less than lease frequency - charge full price
  # This lease started last month and it hasn't been charged last month
  # This lease ends this period
  # Regular price
  def self.charge_amount(lease, charge_date)
    charges = lease.invoice_charges.where(:kind => "rent").all
    
    if lease.lease_months <= lease.payment_frequency
      a = charges.size == 0 ? lease.amount : 0 
    elsif lease.partial_start_date? && same_month?(charge_date.prev_month, lease.start_date) && charges.size < 1
      a = (lease.monthly_charge * lease.payment_frequency) + partial_charge(lease)
    elsif same_period?(charge_date, lease.end_date, lease.payment_frequency)
      total_charges_so_far = charges.map(&:amount).sum
      a = lease.amount - total_charges_so_far
    else
      a = lease.monthly_charge * lease.payment_frequency
    end
    (a * 100).round / 100.0
  end
  
  def self.charge_amount_with_istat(lease, charge_date)
    amount = charge_amount(lease, charge_date)
    period = charge_period(lease, charge_date)
    istat_date = lease.start_date + 12.months
    
    if lease.lease_months > 12 && lease.contract.istat > 0
      setup_istat = Setup.first.try(:istat) || 0
      contract_ratio = lease.contract.istat/100.0
      setup_ratio = setup_istat > 0 ? setup_istat/100.0 : 1
      
      if period.first >= istat_date 
        a = amount + (amount * contract_ratio * setup_ratio)
        (a * 100).round / 100.0
      elsif period.include?(istat_date)
        num_days = (istat_date..period.last).count
        a = amount + (num_days * lease.daily_charge * contract_ratio * setup_ratio)
        (a * 100).round / 100.0
      else
        amount
      end
    else
      amount
    end
  end
  
  def self.partial_charge(lease)
    num_days = (lease.start_date..lease.start_date.end_of_month).count
    month_percent = num_days/lease.start_date.end_of_month.mday.to_f
    (month_percent * lease.monthly_charge * 100).round / 100.0
  end
  
  def self.same_month?(date1, date2)
     date1.at_beginning_of_month == date2.at_beginning_of_month
  end
  
  def self.same_period?(from_date, include_date, months)
    (from_date..(from_date + months.months)).include?(include_date)
  end
  
  def self.charge_period(lease, charge_date)
    from = charge_date.at_beginning_of_month
    to = from + (lease.payment_frequency).months
    to = lease.end_date if to > lease.end_date
    if same_month?(charge_date.prev_month, lease.start_date) || same_month?(charge_date, lease.start_date)
      from = lease.start_date
    end
    (from..to)
  end
  
  def self.month_description(period)
    start, to = period.first, period.last
    from, names = start, []
    while from < to
      names << [I18n.t("date.month_names")[from.month], from.year]
      from = from.end_of_month + 1.day
    end
    str = names.size > 1 ? "Mesi di " : "Mese di "
    h = names.group_by {|n| n[1] }
    h.each do |year, val|
      str += val.map{|m| m[0].capitalize }.join(" ") + " #{year} "
    end
    str.chop
  end
  
  def self.charge_rent?(lease,charge_date)
    return true if lease.start_date > charge_date - 1.month && lease.end_date <= charge_date
    tables = date_tables(charge_date, lease.start_date, lease.end_date, lease.payment_frequency)
    tables.last.first == charge_date.at_beginning_of_month
  end
  
  def self.date_tables(stop_date, start_date, end_date, step)
    ranges = []
    months = step == 1 ? 0 : step
    from = start_date
    while from < end_date && from <= stop_date
      in_end_date = same_period?(from.end_of_month, end_date.end_of_month, step)
      to = in_end_date ? end_date : (from.end_of_month + months.months)
      ranges << (from..to)
      from = from.next_month.at_beginning_of_month + months.months
    end
    ranges
  end
  
end