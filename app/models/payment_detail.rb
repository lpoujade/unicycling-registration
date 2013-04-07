class PaymentDetail < ActiveRecord::Base
  attr_accessible :amount, :payment_id, :registrant_id, :expense_item_id, :details

  validates :payment, :registrant_id, :amount, :expense_item, :presence => true

  has_paper_trail

  belongs_to :registrant #XXX has_one?
  belongs_to :payment, :inverse_of => :payment_details
  belongs_to :expense_item
end
