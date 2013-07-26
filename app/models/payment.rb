class Payment < ActiveRecord::Base
  belongs_to :user

  def self.calculate_activity(user)
    date = DateTime.now.beginning_of_day
    user.activities.where(:created_at => date - 7.days..date).count
  end  

  def self.calculate_amount(user_activity, amount=50)
    user_activity * amount
  end  

  def self.create_bill_amount(user_id, amount)
    Payment.create(:user_id => user_id, :bill_amount => amount)
  end  

  def self.make_payment(amount, user)
    Stripe::Charge.create(:amount => amount, 
                          :currency => "GBP", 
                          :description => "Weekly payment", 
                          :customer => user.stripe_customer_id)
    self.create_bill_amount(user.id, amount)  
  end

  def self.charge_all_users
    users = User.where.not(stripe_customer_id: 'nil')
    users.each do |user|
      unless user.activities.count == 0
        activity = self.calculate_activity(user)
        self.make_payment(self.calculate_amount(activity), user)
      end  
    end 
  end   
end