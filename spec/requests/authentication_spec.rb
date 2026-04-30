require "rails_helper"

RSpec.describe "API authentication", type: :request do
  before { ENV["API_KEY"] = "test-key" }

  it "returns 200 with a valid api_key" do
    get "/stocks.csv", params: { api_key: "test-key" }
    expect(response).to have_http_status(:ok)
  end

  it "returns 401 with an invalid api_key" do
    get "/stocks.csv", params: { api_key: "wrong" }
    expect(response).to have_http_status(:unauthorized)
  end

  it "returns 401 without api_key" do
    get "/stocks.csv"
    expect(response).to have_http_status(:unauthorized)
  end
end
