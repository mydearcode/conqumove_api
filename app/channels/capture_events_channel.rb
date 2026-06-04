class CaptureEventsChannel < ApplicationCable::Channel
  def subscribed
    Array(params[:hex_ids]).each do |hex_id|
      stream_from stream_name(hex_id)
    end
  end

  private

  def stream_name(hex_id)
    "capture_events:#{hex_id}"
  end
end
