# == Schema Information
#
# Table name: payment_detail_coupon_codes
#
#  id                :integer          not null, primary key
#  payment_detail_id :integer
#  coupon_code_id    :integer
#  created_at        :datetime
#  updated_at        :datetime
#
# Indexes
#
#  index_payment_detail_coupon_codes_on_coupon_code_id     (coupon_code_id)
#  index_payment_detail_coupon_codes_on_payment_detail_id  (payment_detail_id) UNIQUE
#

require 'spec_helper'

describe PaymentDetailCouponCode do
  let(:coupon_code) { FactoryBot.create(:coupon_code, inform_emails: "interest@dunlopweb.com,other@dunlopweb.com") }
  let(:pdcc) { FactoryBot.create(:payment_detail_coupon_code) }

  describe "when the coupon has no inform_emails" do
    let(:coupon_code) { FactoryBot.create(:coupon_code, inform_emails: "") }

    it "does not inform" do
      expect(pdcc).not_to be_inform
    end
  end
end
