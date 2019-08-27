# == Schema Information
#
# Table name: payment_details
#
#  id             :integer          not null, primary key
#  payment_id     :integer
#  registrant_id  :integer
#  created_at     :datetime
#  updated_at     :datetime
#  line_item_id   :integer
#  details        :string
#  free           :boolean          default(FALSE), not null
#  refunded       :boolean          default(FALSE), not null
#  amount_cents   :integer
#  line_item_type :string
#
# Indexes
#
#  index_payment_details_on_line_item_id_and_line_item_type  (line_item_id,line_item_type)
#  index_payment_details_payment_id                          (payment_id)
#  index_payment_details_registrant_id                       (registrant_id)
#

class PaymentDetail < ApplicationRecord
  include CachedSetModel
  include HasDetailsDescription

  validates :payment, :registrant, :line_item, presence: true
  validate :registrant_must_be_valid

  monetize :amount_cents, numericality: { greater_than_or_equal_to: 0 }

  has_paper_trail

  belongs_to :registrant, touch: true
  belongs_to :payment, inverse_of: :payment_details
  belongs_to :line_item, polymorphic: true
  has_one :refund_detail
  has_one :payment_detail_coupon_code

  delegate :has_details?, :details_label, to: :line_item

  scope :completed, -> { joins(:payment).merge(Payment.completed) }
  scope :offline_pending, -> { joins(:payment).merge(Payment.offline_pending) }
  scope :completed_or_offline, -> { joins(:payment).merge(Payment.completed_or_offline) }
  scope :not_refunded, -> { includes(:refund_detail).where(refund_details: { payment_detail_id: nil }) }

  scope :paid, -> { completed.where(free: false) }

  scope :free, -> { completed.where(free: true) }
  scope :refunded, -> { completed.where(refunded: true) }

  scope :with_coupon, -> { includes(:payment_detail_coupon_code).where.not(payment_detail_coupon_codes: { payment_detail_id: nil }) }

  def self.cache_set_field
    :line_item_type_and_id
  end

  def line_item_type_and_id
    [line_item_type, line_item_id].join("/")
  end

  def base_cost
    return 0 if free

    line_item.cost
  end

  def tax
    return 0 if free

    line_item.tax
  end

  def cost
    return 0.to_money if free
    return amount - amount_refunded if refunded?

    amount
  end

  def amount_refunded
    (refund_detail.percentage.to_f / 100) * amount
  end

  # update the amount owing for this payment_detail, based on the coupon code applied
  def recalculate!
    if payment_detail_coupon_code.nil?
      update_attribute(:amount, line_item.total_cost)
    else
      update_attribute(:amount, payment_detail_coupon_code.price)
    end
  end

  def to_s
    res = ""
    res += line_item.to_s
    if refunded?
      res += " (Refunded)"
    end
    if coupon_applied?
      res += " (Discount applied)"
    end
    if payment.offline_pending?
      res += " (Pending)"
    end
    res
  end

  def inform_of_coupon
    if payment_detail_coupon_code.present? && payment_detail_coupon_code.inform?
      PaymentMailer.coupon_used(self).deliver_later
    end
  end

  def coupon_applied?
    payment_detail_coupon_code.present?
  end

  private

  def registrant_must_be_valid
    if registrant && (!registrant.validated? || registrant.invalid?)
      errors.add(:registrant, "Registrant #{registrant} form is incomplete")
      return false
    end
    true
  end
end
