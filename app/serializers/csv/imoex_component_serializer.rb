module Csv
  class ImoexComponentSerializer < BaseSerializer
    HEADERS = %w[
      ticker
      weight
    ].freeze
  end
end
