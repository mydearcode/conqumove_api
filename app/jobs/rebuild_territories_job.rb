class RebuildTerritoriesJob < ApplicationJob
  queue_as :default

  def perform(territory_id = nil)
    territory = territory_id ? Territory.find(territory_id) : nil
    Territories::Rebuilder.new.call(territory: territory)
  end
end
