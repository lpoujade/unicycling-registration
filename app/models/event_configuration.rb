# == Schema Information
#
# Table name: event_configurations
#
#  id                                    :integer          not null, primary key
#  short_name                            :string(255)
#  long_name                             :string(255)
#  location                              :string(255)
#  dates_description                     :string(255)
#  event_url                             :string(255)
#  start_date                            :date
#  contact_email                         :string(255)
#  artistic_closed_date                  :date
#  standard_skill_closed_date            :date
#  event_sign_up_closed_date             :date
#  created_at                            :datetime
#  updated_at                            :datetime
#  test_mode                             :boolean
#  waiver_url                            :string(255)
#  comp_noncomp_url                      :string(255)
#  has_print_waiver                      :boolean
#  standard_skill                        :boolean          default(FALSE)
#  usa                                   :boolean          default(FALSE)
#  iuf                                   :boolean          default(FALSE)
#  currency_code                         :string(255)
#  currency                              :text
#  rulebook_url                          :string(255)
#  style_name                            :string(255)
#  has_online_waiver                     :boolean
#  online_waiver_text                    :text
#  music_submission_end_date             :date
#  artistic_score_elimination_mode_naucc :boolean          default(TRUE)
#  usa_individual_expense_item_id        :integer
#  usa_family_expense_item_id            :integer
#  logo_file                             :string(255)
#  max_award_place                       :integer          default(5)
#  display_confirmed_events              :boolean          default(FALSE)
#  spectators                            :boolean          default(FALSE)
#

class EventConfiguration < ActiveRecord::Base
  translates :short_name, :long_name, :location, :dates_description
  accepts_nested_attributes_for :translations

  mount_uploader :logo_file, LogoUploader

  validates :short_name, :long_name, :presence => true
  validates :event_url, :format => URI::regexp(%w(http https)), :unless => "event_url.nil?"
  validates :comp_noncomp_url, :format => URI::regexp(%w(http https)), :unless => "comp_noncomp_url.nil? or comp_noncomp_url.empty?"

  def self.style_names
    ["unicon_17", "naucc_2013", "naucc_2014"]
  end

  validates :style_name, :inclusion => {:in => self.style_names }
  validates :test_mode, :has_print_waiver, :has_online_waiver, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :artistic_score_elimination_mode_naucc, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :usa, :iuf, :standard_skill, :inclusion => { :in => [true, false] } # because it's a boolean

  belongs_to :usa_individual_expense_item, :class_name => "ExpenseItem"
  belongs_to :usa_family_expense_item, :class_name => "ExpenseItem"

  validates :usa_individual_expense_item, :usa_family_expense_item, presence: { message: "Must be specified when enabling 'usa' mode"}, if: "self.usa"

  validates :standard_skill_closed_date, :presence => true, :unless => "standard_skill.nil? or standard_skill == false"
  validates :max_award_place, presence: true

  before_validation :clear_of_blank_strings

  after_initialize :init

  def init
    self.test_mode = true if self.test_mode.nil?
    self.has_print_waiver = false if self.has_print_waiver.nil?
    self.has_online_waiver = false if self.has_online_waiver.nil?
    self.usa = true if self.usa.nil?
    self.iuf = false if self.iuf.nil?
    self.standard_skill = true if self.standard_skill.nil?
    self.artistic_score_elimination_mode_naucc = true if self.artistic_score_elimination_mode_naucc.nil?
    self.style_name ||= "naucc_2013"
    self.long_name ||= ""
    self.short_name ||= ""
    self.currency ||= "%u%n USD"
    self.currency_code ||= "USD"
    self.contact_email ||= ""
    self.max_award_place ||= 5
    self.display_confirmed_events = false if self.display_confirmed_events.nil?
  end

  # allows creating competitors during lane assignment
  # (only at NAUCC)
  def can_create_competitors_at_lane_assignment
    usa
  end

  def clear_of_blank_strings
    self.rulebook_url = nil if rulebook_url == ""
  end

  def self.singleton
    EventConfiguration.includes(:translations).first || EventConfiguration.new
  end

  def self.paypal_base_url
    paypal_test_url = "https://www.sandbox.paypal.com"
    paypal_live_url = "https://www.paypal.com"

    if Rails.application.secrets.paypal_test
      paypal_test_url
    else
      paypal_live_url
    end
  end

  def self.closed?(today = Date.today)
    last_online_rp = RegistrationPeriod.last_online_period

    if last_online_rp.nil?
      false
    else
      last_online_rp.last_day < today
    end
  end

  def standard_skill_closed?(today = Date.today)
    return false if standard_skill_closed_date.nil?
    standard_skill_closed_date <= today
  end

  def artistic_closed?(today = Date.today)
    return false if artistic_closed_date.nil?
    artistic_closed_date < today
  end

  def event_sign_up_closed?(today = Date.today)
    return false if event_sign_up_closed_date.nil?
    event_sign_up_closed_date < today
  end

  def music_submission_ended?(today = Date.today)
    return true if music_submission_end_date.nil?
    music_submission_end_date <= today
  end

  def self.configuration_exists?
    !EventConfiguration.first.nil?
  end
end
