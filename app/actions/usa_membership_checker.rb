# checks the Unicycling Society Of America (USA)
# WildApricot membership database
class UsaMembershipChecker
  attr_reader :first_name, :last_name, :birthdate
  attr_reader :legacy_usa_member_number, :wildapricot_member_number

  def initialize(first_name:, last_name:, birthdate:, usa_member_number:, wildapricot_member_number:)
    @first_name = first_name
    @last_name = last_name
    @birthdate = birthdate
    @legacy_usa_member_number = usa_member_number
    @wildapricot_member_number = wildapricot_member_number
  end

  def current_member?
    return false if contacts.count.zero?

    active_matched_contact.present?
  end

  # When a match is found, store the WildApricot ID found as the "system_member_number"
  def current_wildapricot_id
    matched_contact = active_matched_contact

    return nil unless matched_contact

    matched_contact["Id"]
  end

  private

  def contacts
    return [] if Rails.env.test?

    # If a system_member_number is specified, search ONLY by that
    if wildapricot_member_number.present?
      search_contacts(filter_by_wildapricot_id)
    else
      # If system_member_number not is specified, Search by fname/lname/bday
      result = search_contacts(filter_by_name_bday)
      if result.none?
        # Then search for usa via manual_member_number (if specified)
        result = search_contacts(filter_by_old_usa_membership_id)
      end

      result
    end
  end

  def active_matched_contact
    @active_matched_contact ||= contacts.detect do |contact|
      contact_is_member?(contact)
    end
  end

  def api_connection
    Faraday.new(url: "https://api.wildapricot.org") do |faraday|
      faraday.request :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
  end

  def search_contacts(filter_string)
    response = api_connection.get do |req|
      req.headers["authorization"] = "Bearer #{token}"
      req.url("/v2.1/accounts/#{account_id}/contacts")
      req.params["$async"] = "false"
      req.params["$top"] = "10"
      req.params["$filter"] = filter_string
    end

    if response.success?
      JSON.parse(response.body)["Contacts"]
    else
      # Unable to fetch from wildapricot
      []
    end
  end

  def filter_by_name_bday
    "'FirstName' eq '#{first_name}' " \
    " and 'LastName' eq '#{last_name}' " \
    " and 'Birth Date' eq '#{birthdate.strftime('%Y-%m-%d')}'"
  end

  def filter_by_old_usa_membership_id
    "'Old Member ID' eq '#{legacy_usa_member_number}'"
  end

  def filter_by_wildapricot_id
    "'ID' eq '#{wildapricot_member_number}'"
  end

  def contact_is_member?(contact_hash)
    contact_hash["MembershipEnabled"] &&
      contact_hash["Status"] == "Active" &&
      !suspended?(contact_hash)
  end

  def suspended?(contact_hash)
    suspended_element = contact_hash["FieldValues"].detect do |field|
      field["FieldName"] == "Suspended member"
    end

    suspended_element["Value"]
  end

  # Unused method
  def renewing?(contact_hash)
    renewal_field = contact_hash["FieldValues"].detect { |field| field["FieldName"] == "Renewal due" }
    return false unless renewal_field

    Date.parse(renewal_field["Value"]) < Date.current + 5.months
  end

  def token
    return @token if @token

    oauth_connection = Faraday.new(url: "https://oauth.wildapricot.org") do |faraday|
      faraday.request :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
    response = oauth_connection.post do |req|
      req.url("/auth/token")
      req.headers["Content-type"] = "Application/x-www-form-urlencoded"
      req.headers["Authorization"] = basic_auth
      req.body = "grant_type=client_credentials&scope=auto"
    end

    if response.success?
      @token = JSON.parse(response.body)["access_token"]
    else
      raise "Unable to authorize with WildApricot"
    end
  end

  def basic_auth
    "Basic #{Base64.encode64("APIKEY:#{api_key}")}"
  end

  def account_id
    Rails.application.secrets.usa_wildapricot_account_id
  end

  def api_key
    Rails.application.secrets.usa_wildapricot_apikey
  end
end
