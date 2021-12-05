require 'rails_helper'

RSpec.describe Notification, type: :model do
  before do
    stub_stripe_client
    allow(NotificationJob).to receive(:perform_async)

    @notification = build(:notification)
  end

  describe 'Validations' do
    it{ should validate_inclusion_of(:notification_type)
              .in_array(Notification::NOTIFICATION_TYPES) }
  end

  describe 'Associations' do
    it{ should belong_to(:order).required }
  end

  describe 'Behaviors' do
    it 'should start NotificationJob after save' do
      @notification.save!
      expect(NotificationJob)
            .to have_received(:perform_async)
            .with(Notification.last.id)
    end
  end
end
