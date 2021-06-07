require 'rails_helper'

RSpec.describe OrderNotification, type: :model do
  before do
    stub_stripe_client
    allow(OrderNotificationJob).to receive(:perform_async)

    @order_notification = build(:order_notification)
  end

  describe 'Validations' do
    it{ should validate_inclusion_of(:notification_type)
              .in_array(OrderNotification::ORDER_NOTIFICATION_TYPES) }
  end

  describe 'Associations' do
    it{ should belong_to(:order).required }
  end

  describe 'Behaviors' do
    it 'should start OrderNotificationJob after save' do
      @order_notification.save!
      expect(OrderNotificationJob)
            .to have_received(:perform_async)
            .with(OrderNotification.last.id)
    end
  end
end
