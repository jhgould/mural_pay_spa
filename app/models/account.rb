class Account < ApplicationRecord 
  has_many :payout_requests, dependent: :destroy 

  

end 