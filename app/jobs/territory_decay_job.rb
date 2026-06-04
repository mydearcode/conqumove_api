class TerritoryDecayJob < ApplicationJob
  queue_as :default

  def perform
    Territories::DecayEngine.new.call
  end
end
