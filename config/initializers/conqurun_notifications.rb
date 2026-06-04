ActiveSupport::Notifications.subscribe("admin_action.conqurun") do |_name, _start, _finish, _id, payload|
  Rails.logger.info(
    "[conqurun.admin] action=#{payload[:action_name]} user_id=#{payload[:user_id]} " \
    "status=#{payload[:status]} metadata=#{payload[:metadata].to_json}"
  )
end
