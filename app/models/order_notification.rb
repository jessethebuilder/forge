class OrderNotification < ApplicationRecord
  ORDER_NOTIFICATION_TYPES = %w|new_order notify_customer notify_account notify_menu|

  belongs_to :order, required: true

  validates :notification_type, inclusion: {in: ORDER_NOTIFICATION_TYPES}

  delegate :account, to: :order

  after_create :deliver!

  private

  def deliver!
    OrderNotificationJob.perform_async(self.id)
  end
end
