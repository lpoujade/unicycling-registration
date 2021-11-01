class Api::CompetitionsController < ApplicationController
  before_action :authenticate_api!
  before_action :skip_authorization

  # GET /api/competitions
  # Returns JSON
  # Example usage:
  # curl \
  # -H "Authorization: Token ABC123" \
  # -H "Content-Type: application/json" \
  # --request GET \
  # https://registrationtest.regtest.unicycling-software.com/api/competitions
  def index
    competition_json = Competition.all.map do |competition|
      competitor_list_pdf = if competition.num_competitors > 0
                              announcer_printing_competition_url(competition, format: :pdf)
                            end

      start_list_pdf = if competition.start_list? && competition.start_list_present?
        start_list_printing_competition_url(competition, format: :pdf)
      end

      results_pdfs = if competition.published?
        competition.competition_results.active.map do |result|
          {
            name: result.to_s,
            pdf: public_result_url(result),
            published_at: competition.published_at.iso8601,
          }
        end
      end

      {
        url: api_competition_url(competition),
        name: [competition.award_title_name, competition.award_subtitle_name].compact.join(" - "),
        competitor_list_pdf: competitor_list_pdf,
        start_list_pdf: start_list_pdf,
        results: results_pdfs,
        updated_at: competition.updated_at.iso8601,
      }
    end

    render json: {
      competitions: competition_json
    }
  end

  # GET /api/competitions/:id
  # TBD
  def show
  end

  private

  def authenticate_api!
    authorize_api || render_unauthorized
  end

  # Ensure that the shared-key is being used
  def authorize_api
    authenticate_with_http_token do |token, _options|
      ApiToken.find_by(token: token).any?
    end
  end

  # Based on https://www.pluralsight.com/blog/tutorials/token-based-authentication-rails
  def render_unauthorized
    self.headers["WWW-Authenticate"] = 'Token realm="Application"'
    render json: { message: "Bad Credentials" }, status: :unauthorized
  end
end
