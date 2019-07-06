class NotificationsPreview < ActionMailer::Preview
  def send_feedback
    Notifications.send_feedback(feedback)
  end

  def request_registrant_access
    Notifications.request_registrant_access(registrant, user)
  end

  def registrant_access_accepted
    Notifications.registrant_access_accepted(registrant, user)
  end

  def send_mass_email
    Notifications.send_mass_email(email.subject, email.body, addresses)
  end

  ######### ADMIN
  def updated_current_reg_period
    Notifications.updated_current_reg_period("Early Registration", "Late Registration")
  end

  def missing_old_reg_items
    bib_numbers = [1, 2, 3]
    Notifications.missing_old_reg_items(bib_numbers)
  end

  def new_convention_created
    Notifications.new_convention_created("Next year's Convention", "nextyear3000")
  end

  def old_password_used
    Notifications.old_password_used(user, "oldsubdomain-2000")
  end

  private

  def feedback
    Feedback.all.sample
  end

  def registrant
    Registrant.all.sample
  end

  def user
    User.all.sample
  end

  def email
    Email.new(body: "<p>This is a mass <b>\"e-mail\"</b> body</p>", subject: "I want to inform all of you")
  end

  def addresses
    ["robin+test@dunlopeb.com", "robin+test2@dunlopweb.com"]
  end
end
