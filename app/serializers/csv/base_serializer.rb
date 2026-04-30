require "csv"

module Csv
  class BaseSerializer
    def self.call(records)
      ::CSV.generate do |csv|
        csv << self::HEADERS
        records.each { |r| csv << self::HEADERS.map { |f| r.public_send(f) } }
      end
    end
  end
end
