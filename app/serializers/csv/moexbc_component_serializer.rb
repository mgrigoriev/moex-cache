module Csv
  class MoexbcComponentSerializer < BaseSerializer
    HEADERS = %w[
      ticker
      weight
    ].freeze
  end
end
