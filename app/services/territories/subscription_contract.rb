module Territories
  class SubscriptionContract
    def call(lat:, lng:, radius: 1, cable_url:)
      center_hex = Territories::HexResolver.new.call(lat: lat, lng: lng)
      hex_ids = Geo::H3Client.grid_disk(hex_id: center_hex, radius: radius.to_i).sort

      {
        cable_url: cable_url,
        hex_ids: hex_ids,
        channels: {
          territory_updates: {
            channel: "TerritoryUpdatesChannel",
            params: { hex_ids: hex_ids }
          },
          capture_events: {
            channel: "CaptureEventsChannel",
            params: { hex_ids: hex_ids }
          }
        },
        authorization: {
          type: "bearer_or_query_token",
          access_token_param: "token",
          access_token_header: "Authorization: Bearer <access_token>"
        }
      }
    end
  end
end
