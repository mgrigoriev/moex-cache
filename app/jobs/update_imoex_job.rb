class UpdateImoexJob < ApplicationJob
  queue_as :default

  def perform
    UpdateImoex.new.call
  end
end
