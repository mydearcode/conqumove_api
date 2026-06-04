module Territories
  class NearbyQuery
    def call(lat:, lng:, radius: 1, resolution: Geo::H3Client::DEFAULT_RESOLUTION)
      center_hex = Territories::HexResolver.new.call(lat: lat, lng: lng, resolution: resolution)
      hexes = Geo::H3Client.grid_disk(hex_id: center_hex, radius: radius.to_i)

      Territory.where(hex_id: hexes, resolution: resolution)
    end
  end
end
