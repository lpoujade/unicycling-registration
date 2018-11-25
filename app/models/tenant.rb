# == Schema Information
#
# Table name: public.tenants
#
#  id                 :integer          not null, primary key
#  subdomain          :string
#  description        :string
#  created_at         :datetime
#  updated_at         :datetime
#  admin_upgrade_code :string
#
# Indexes
#
#  index_tenants_on_subdomain  (subdomain)
#

class Tenant < ApplicationRecord
  validates :subdomain, :description, :admin_upgrade_code, presence: true
  validates :subdomain, uniqueness: true
  validate :subdomain_has_no_spaces
  before_validation :trim_subdomain
  before_validation :lowercase_subdomain

  has_many :tenant_aliases, dependent: :destroy, inverse_of: :tenant
  has_one :convention_series_member, dependent: :destroy, inverse_of: :tenant

  accepts_nested_attributes_for :tenant_aliases, allow_destroy: true

  def self.find_tenant_by_hostname(hostname)
    TenantAlias.find_by(website_alias: hostname).try(:tenant) || by_first_subdomain(hostname)
  end

  def to_s
    description
  end

  def base_url
    raw_url = tenant_aliases.primary.first.try(:to_s) || permanent_url
    "https://#{raw_url}"
  end

  def permanent_url
    "#{subdomain}.#{Rails.application.secrets.domain}"
  end

  def self.by_first_subdomain(hostname)
    find_by(subdomain: hostname.split('.')[0])
  end

  private

  def trim_subdomain
    self.subdomain = subdomain.strip
  end

  def lowercase_subdomain
    self.subdomain = subdomain.downcase
  end

  def subdomain_has_no_spaces
    if subdomain.present? && subdomain.include?(" ")
      errors.add(:subdomain, "Subdomain cannot have spaces")
    end
  end
end
