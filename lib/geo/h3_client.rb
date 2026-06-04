require "h3"

module Geo
  class H3Client
    DEFAULT_RESOLUTION = 9

    class << self
      def geo_to_h3(lat:, lng:, resolution: DEFAULT_RESOLUTION)
        H3.from_geo_coordinates([lat.to_f, lng.to_f], resolution.to_i)
      end

      def grid_disk(hex_id:, radius: 1)
        if H3.respond_to?(:grid_disk)
          H3.grid_disk(hex_id, radius)
        elsif H3.respond_to?(:k_ring)
          H3.k_ring(hex_id, radius)
        else
          H3.hex_range(hex_id, radius)
        end
      end
    end
  end
end
