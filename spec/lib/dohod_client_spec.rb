require "rails_helper"

RSpec.describe DohodClient do
  subject(:client) { described_class.new }

  let(:url) { "#{DohodClient::BASE_URL}/sber" }

  def page_with_forecast(value)
    <<~HTML
      <html><body><table>
        <tr class="forecast">
          <td class="black">след 12m. (прогноз)</td>
          <td class="black11">#{value}</td>
          <td class="black11"> - </td>
        </tr>
      </table></body></html>
    HTML
  end

  describe "#fetch_forecast" do
    context "when forecast value is a number" do
      before { stub_request(:get, url).to_return(body: page_with_forecast("35")) }

      it "returns a BigDecimal" do
        expect(client.fetch_forecast("SBER")).to eq(BigDecimal("35"))
      end
    end

    context "when forecast value is 0" do
      before { stub_request(:get, url).to_return(body: page_with_forecast("0")) }

      it "returns BigDecimal(0)" do
        expect(client.fetch_forecast("SBER")).to eq(BigDecimal("0"))
      end
    end

    context "when forecast value is a dash" do
      before { stub_request(:get, url).to_return(body: page_with_forecast(" - ")) }

      it "returns nil" do
        expect(client.fetch_forecast("SBER")).to be_nil
      end
    end

    context "when forecast cell is empty" do
      before { stub_request(:get, url).to_return(body: page_with_forecast("")) }

      it "returns nil" do
        expect(client.fetch_forecast("SBER")).to be_nil
      end
    end

    context "when forecast row is missing" do
      before { stub_request(:get, url).to_return(body: "<html><body><p>nothing</p></body></html>") }

      it "returns nil" do
        expect(client.fetch_forecast("SBER")).to be_nil
      end
    end

    context "when ticker is given in any case" do
      before { stub_request(:get, url).to_return(body: page_with_forecast("12.5")) }

      it "downcases the ticker in the URL" do
        expect(client.fetch_forecast("Sber")).to eq(BigDecimal("12.5"))
      end
    end

    context "when response is 404" do
      before { stub_request(:get, url).to_return(status: 404) }

      it "raises an error" do
        expect { client.fetch_forecast("SBER") }.to raise_error(RuntimeError, /404/)
      end
    end

    context "when response is 503" do
      before { stub_request(:get, url).to_return(status: 503) }

      it "raises an error" do
        expect { client.fetch_forecast("SBER") }.to raise_error(RuntimeError, /503/)
      end
    end
  end
end
