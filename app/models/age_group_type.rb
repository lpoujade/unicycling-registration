class AgeGroupType < ActiveRecord::Base
  attr_accessible :name, :description

  validates :name, :presence => true, :uniqueness => true

  has_many :age_group_entries, :dependent => :destroy

  default_scope order(:name)

  # Return the age group entry that meets the given age requirements
  def age_group_entry_for(age, gender, default_wheel_size_id = nil)
    entries = age_group_entries.where("(start_age <= :age AND :age <= end_age) AND " +
                                      "(gender = 'Mixed' OR gender = :gender) AND " +
                                      "(wheel_size_id IS NULL or wheel_size_id = :wheel_size_id)", 
                                        :age => age, :gender => gender, :wheel_size_id => default_wheel_size_id)
    entries.first
  end

  def age_group_entry_description(age, gender, default_wheel_size_id = nil)
    Rails.cache.fetch("/age_group_type/#{id}-#{updated_at}/age/#{age}/gender/#{gender}/wheel_size/#{default_wheel_size_id}") do
      ag_entry = age_group_entry_for(age, gender, default_wheel_size_id)
      ag_entry.nil? ? nil : ag_entry.to_s
    end
  end

  def as_json(options={})
    options = {
      :except => [:id, :updated_at, :created_at],
      :methods => [:age_group_entries]
    }
    super(options)
  end

  def to_s
    name
  end
end
