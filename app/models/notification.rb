class Notification < ApplicationRecord
  NOTIFICATION_TYPES = %w|new_order customer|

  belongs_to :order, required: true

  validates :notification_type, inclusion: {in: NOTIFICATION_TYPES}

  after_create :deliver!

  private

  def deliver!
    NotificationJob.perform_async(self.id)
  end
end
