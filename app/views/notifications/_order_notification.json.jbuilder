json.extract! order_notification, :id, :message, :account_id, :message_type, :order_id, :created_at, :updated_at
json.url order_notification_url(order_notification, format: :json)
