describe NotificationJob, type: :job do
  include SmsHelper

  before do
    @order = create(:order)
    @notification = build(:notification, order: @order)
    # Saving an Notification calls this Job, so stub that to test just the Job's functionality.
    allow(@notification).to receive(:deliver!)
    @notification.save!

    @account = @order.account
    @job = NotificationJob.new

    allow(SmsNotificationJob).to receive(:perform_async)
    allow(OrdersMailer).to receive(:new_order_for_account).and_call_original
    allow(OrdersMailer).to receive(:new_order_for_customer).and_call_original
  end

  describe 'New Order Notification' do
    before do
      @notification.update(notification_type: 'new_order')
    end

    describe 'Account Notification' do
      it 'should call SmsNotificationJob for each action' do
        expect(OrdersMailer).to receive(:new_order_for_account).with(@account.email, @order.id)
        @job.perform(@notification.id)
      end

      it 'should call SmsNotificationJob if @account provides an :sms' do
        @account.update(sms: '321-123-1234')
        expect(SmsNotificationJob).to receive(:perform_async)
              .with(@account.sms, new_order_sms_body(@order))

        @job.perform(@notification.id)
      end

      it 'should NOT call SmsNotificationJob if no :sms is provided' do
        expect(SmsNotificationJob).not_to receive(:perform_async)
              .with(@account.sms, new_order_sms_body(@order))

        @job.perform(@notification.id)
      end
    end

    describe 'SMS Notification' do
      before do
        @phone = Faker::PhoneNumber.cell_phone
        @account.update(sms: @phone)
      end

      context '@order has a Menu' do
        before do
          @menu_phone = Faker::PhoneNumber.cell_phone
          @menu = create(:menu, orders: [@order], sms: @menu_phone)
        end

        it 'should attempt to immediatly notify Menu :sms' do
          @job.perform(@notification.id)
          expect(SmsNotificationJob)
                .to have_received(:perform_async)
                .with(@menu_phone, new_order_sms_body(@order))
        end
      end # has Menu
    end # SMS

    describe 'Email Notification' do
      before do
        @email = Faker::Internet.email
        @account.update(email: @mail)
      end

      context 'Order has Menu' do
        before do
          @menu = create(:menu, account: @account, orders: [@order])
        end

        it 'should call send email to Account, is email address is provided' do
          email = Faker::Internet.email
          @menu.update(email: email)
          expect(OrdersMailer).to receive(:new_order_for_account).with(email, @order.id)
          @job.perform(@notification.id)
        end
      end
    end # Email
  end # New Order Notification

  # describe 'Customer Notification' do
  #   before do
  #     @email = Faker::Internet.email
  #     @phone = Faker::PhoneNumber.phone_number
  #
  #     @customer = create(:customer, email: @email, phone: @phone)
  #     @order.update(customer: @customer)
  #
  #     @message = Faker::Lorem.paragraph
  #     @notification.update(notification_type: 'customer', message: @message)
  #   end
  #
  #   it 'should send an email' do
  #     expect(OrdersMailer).to receive(:customer).with(@email, @message)
  #     @job.perform(@notification.id)
  #   end
  # end # Customer Notification
end
