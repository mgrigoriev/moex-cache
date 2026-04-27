require "rails_helper"

RSpec.describe CorporateBond, type: :model do
  subject { CorporateBond.new(secid: "RU000A0JX0J2") }

  it { is_expected.to validate_presence_of(:secid) }
  it { is_expected.to validate_uniqueness_of(:secid) }
end
