require "rails_helper"

RSpec.describe Ofz, type: :model do
  subject { Ofz.new(secid: "SU26207RMFS9") }

  it { is_expected.to validate_presence_of(:secid) }
  it { is_expected.to validate_uniqueness_of(:secid) }
end
