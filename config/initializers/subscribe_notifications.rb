ActiveSupport::Notifications.subscribe Notification::EVENT_UPDATED_STATUS  do |name, start, finish, id, payload|
      Rails.logger.info "UPDATED STATUS: #{ payload.inspect }"
      Rails.logger.info ProjectInvitation.name

      
      ProjectInvitation.process_notification( payload ) if ProjectInvitation.valid_notify_token? payload[:token]
end