# == Schema Information
#
# Table name: feedbacks
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  entered_email  :string
#  message        :text
#  status         :string           default("new"), not null
#  resolved_at    :datetime
#  resolved_by_id :integer
#  resolution     :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class FeedbacksController < ApplicationController
  before_action :skip_authorization

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)

    if signed_in?
      @feedback.user = current_user
    end

    if captcha_valid? && @feedback.save
      Notifications.send_feedback(@feedback.id).deliver_later
      redirect_to new_feedback_path, notice: 'Feedback sent successfully.'
    else
      render :new
    end
  end

  private

  def captcha_valid?
    return true unless recaptcha_required?

    verify_recaptcha
  end

  def recaptcha_required?
    Rails.application.secrets.recaptcha_private_key.present? && !signed_in?
  end
  helper_method :recaptcha_required?

  def feedback_params
    params.require(:feedback).permit(:entered_email, :message)
  end
end
