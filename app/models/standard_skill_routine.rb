class StandardSkillRoutine < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  validates :registrant_id, { :presence => true, :uniqueness => true }

  belongs_to :registrant

  has_many :standard_skill_routine_entries, :dependent => :destroy, :order => "position"

  def total_skill_points
    total = 0
    self.standard_skill_routine_entries.each do |entry|
      total += entry.standard_skill_entry.points unless entry.standard_skill_entry.nil?
    end
    total
  end

  def add_standard_skill_routine_entry(params)
    # keep the position values between 1 and 18
    if self.standard_skill_routine_entries.size >= 1
      max_skill_number = self.standard_skill_routine_entries.last.position + 1
    else
      max_skill_number = 1
    end

    # if the user doesn't specify a position, default to 'end of list'
    if params[:position].nil? or params[:position].empty? or params[:position].to_i > max_skill_number
      params[:position] = max_skill_number
    elsif params[:position].to_i < 1
      params[:position] = 1
    end
    self.standard_skill_routine_entries.build(params)
  end
end
