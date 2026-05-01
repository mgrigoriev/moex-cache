class UpdateMoexbcJob < ApplicationJob
  queue_as :default

  def perform
    UpdateMoexbc.new.call
  end
end
