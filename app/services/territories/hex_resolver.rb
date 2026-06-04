module Territories
  class HexResolver
    def call(lat:, lng:, resolution: Geo::H3Client::DEFAULT_RESOLUTION)
      Geo::H3Client.geo_to_h3(lat: lat, lng: lng, resolution: resolution)
    end
  end
end
