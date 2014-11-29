# == Schema Information
#
# Table name: events
#
#  id                    :integer          not null, primary key
#  category_id           :integer
#  export_name           :string(255)
#  position              :integer
#  created_at            :datetime
#  updated_at            :datetime
#  name                  :string(255)
#  visible               :boolean
#  accepts_music_uploads :boolean          default(FALSE)
#  artistic              :boolean          default(FALSE)
#
# Indexes
#
#  index_events_category_id  (category_id)
#

class Event < ActiveRecord::Base
  resourcify

  has_many :event_choices, -> {order "event_choices.position"}, :dependent => :destroy, :inverse_of => :event
  accepts_nested_attributes_for :event_choices

  has_many :event_categories, -> { order "event_categories.position"}, :dependent => :destroy, :inverse_of => :event
  accepts_nested_attributes_for :event_categories

  has_many :registrant_event_sign_ups, :dependent => :destroy, :inverse_of => :event

  has_many :competitions, -> {order "competitions.name"}, :dependent => :destroy, :inverse_of => :event
  has_many :competitors, :through => :competitions
  has_many :time_results, :through => :competitors

  belongs_to :category, :inverse_of => :events, :touch => true

  after_initialize :init

  def init
    self.visible = true if self.visible.nil?
  end

  def self.music_uploadable
    visible.where(:accepts_music_uploads => true)
  end

  def self.visible
    where(:visible => true)
  end

  def self.artistic
    where(artistic: true)
  end

  validates :name, :presence => true
  validates :category_id, :presence => true

  before_validation :build_event_category


  def build_event_category
    if self.event_categories.empty?
      self.event_categories.build({:name => "All", :position => 1})
    end
  end

  validate :has_event_category

  def has_event_category
    if self.event_categories.empty?
      errors[:base] << "Must define an event category"
    end
  end

  # does this entry represent the Standard Skill event?
  def standard_skill?
    name == "Standard Skill"
  end

  def to_s
    name
  end

  def directors
    User.with_role(:director, self)
  end

  # determine the number of people who have signed up for this event
  def num_signed_up_registrants
    registrant_event_sign_ups.signed_up.count
  end

  def signed_up_registrants
    registrant_event_sign_ups.signed_up.map{|resu| resu.registrant}.select{|reg| !reg.deleted}
  end

  def competitor_registrants
    competitors.map {|comp| comp.members.map{|mem| mem.registrant}}
  end

  def num_choices
    total = 1
    if event_categories.count > 1
      total += 1
    end
    total += event_choices.count
  end

end
