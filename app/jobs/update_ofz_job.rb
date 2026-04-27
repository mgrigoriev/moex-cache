class UpdateOfzJob < ApplicationJob
  queue_as :default

  def perform
    UpdateOfz.new.call
  end
end
