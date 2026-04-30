class ApplicationController < ActionController::API
  before_action :authenticate!

  private

  def authenticate!
    return if ActiveSupport::SecurityUtils.secure_compare(params[:api_key].to_s, ENV.fetch("API_KEY"))

    head :unauthorized
  end
end
