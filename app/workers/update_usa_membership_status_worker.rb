require "net/http"
require "uri"

class UpdateUsaMembershipStatusWorker
  include Sidekiq::Worker

  # Query the USA membership API, and update the registrant record with the result
  def perform(registrant_id)
    return if server.blank?
    return unless event_is_usa?

    Rails.logger.debug "USA membership check for #{registrant_id}"
    registrant = Registrant.find(registrant_id)
    last_name = registrant.last_name
    usa_number = registrant.contact_detail.try(:organization_member_number)

    return if usa_number.blank?

    contact_detail = registrant.contact_detail

    uri = build_url(usa_number, last_name)
    Rails.logger.debug "USA query #{uri}"
    request = Net::HTTP.get(uri)

    Rails.logger.debug "USA response: #{request}"

    process_response(contact_detail, JSON.parse(request))
  rescue JSON::ParserError => ex
    raise "Error (#{ex}) parsing response from USA database for #{request}"
  end

  # Build the API call URL
  def build_url(usa_number, last_name)
    query = {
      apikey: apikey,
      membernum: usa_number,
      lastname: last_name,
      strdatetocheck: event_end_date.strftime("%Y-%m-%d")
    }
    URI::HTTPS.build(host: server, path: endpoint, query: query.to_query)
  end

  # Take the response hash, and update the registrant record
  def process_response(contact_detail, hash)
    contact_detail.update_attributes(
      organization_membership_system_confirmed: hash["success"],
      organization_membership_system_status: hash["message"]
    )
  end

  def server
    Rails.application.secrets.usa_membership_check_server
  end

  def endpoint
    Rails.application.secrets.usa_membership_check_endpoint
  end

  def apikey
    Rails.application.secrets.usa_membership_api_key
  end

  def event_end_date
    EventConfiguration.singleton.start_date + 10.days
  end

  def event_is_usa?
    EventConfiguration.singleton.organization_membership_usa?
  end
end
