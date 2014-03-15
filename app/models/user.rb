class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :confirmable unless (!ENV['MAIL_SKIP_CONFIRMATION'].nil? and ENV['MAIL_SKIP_CONFIRMATION'] == "true")

  default_scope order('email ASC')

  has_paper_trail :meta => {:user_id => :id }

  has_many :registrants, :order => "registrants.id", :include => [:registrant_expense_items, :payment_details]

  has_many :additional_registrant_accesses, :dependent => :destroy
  has_many :invitations, :through => :registrants, :class_name => "AdditionalRegistrantAccess", :source => :additional_registrant_accesses

  has_many :judges

  has_many :payments
  has_many :refunds

  has_many :import_results
  has_many :award_labels

  scope :confirmed, -> { where('confirmed_at IS NOT NULL') }
  scope :all_with_registrants, -> { where('id IN (SELECT DISTINCT(user_id) FROM registrants)') }

  # get all users who have registrants with unpaid fees
  def self.unpaid_reg_fees
    registrants = Registrant.all.select { |reg| !reg.reg_paid? }
    users = registrants.map { |reg| reg.user }.flatten.uniq
  end

  def self.paid_reg_fees
    User.confirmed.all_with_registrants - User.unpaid_reg_fees
  end

  def self.roles
    # these should be sorted in order of least-priviledge -> Most priviledge
    [:judge, :admin, :super_admin, :payment_admin]
  end

  def self.role_description(role)
    case(role)
      #when :track_official
      #when :results_printer
      #when :data_importer
    when :judge
      "[e.g. Judge Volunteers] Able to view the judging menu, and enter scores for any event"
    when :admin
      "[e.g. Scott/Connie]
      Able to create onsite payments,
      adjust many details of the system.
      can create/assign judges
      Can assign Chief Judges
      Can import Results
      Can Create Award Labels
      "
    when :super_admin
      "[e.g. Robin] Able to set roles of other people, able to destroy payment information, able to configure the site settings, event settings"
    when :payment_admin
      "[e.g. Garrett Macey] Able to view the payments that have been received, the total number of items paid."
    else
      "No Description Available"
    end
  end

  def to_s
    email
  end

  def accessible_registrants
    additional_registrant_accesses.permitted.map{ |ada| ada.registrant} + registrants
  end

  def total_owing
    total = 0
    self.registrants.each do |reg|
      total += reg.amount_owing
    end
    total
  end

  def has_minor?
    self.registrants.each do |reg|
      if reg.minor?
        return true
      end
    end
    false
  end
end
