describe NewOrderNotificationJob, type: :job do
  include SmsHelper

  before do
    @order = create(:order)
    @account = @order.account
    @job = NewOrderNotificationJob.new

    allow(SmsNotificationJob).to receive(:perform_async)
    allow(OrdersMailer).to receive(:new_order).and_call_original
  end


  describe 'Account Notification' do
    it 'should call SmsNotificationJob for each action' do
      expect(OrdersMailer).to receive(:new_order).with(@account.email, @order.id)
      @job.perform(@order.id)
    end

    it 'should call SmsNotificationJob if @account provides an :sms' do
      @account.update(sms: '321-123-1234')
      expect(SmsNotificationJob).to receive(:perform_async)
            .with(@account.sms, new_order_sms_body(@order))

      @job.perform(@order.id)
    end

    it 'should NOT call SmsNotificationJob if no :sms is provided' do
      expect(SmsNotificationJob).not_to receive(:perform_async)
            .with(@account.sms, new_order_sms_body(@order))

      @job.perform(@order.id)
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
        @job.perform(@order.id)
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
        expect(OrdersMailer).to receive(:new_order).with(email, @order.id)
        @job.perform(@order.id)
      end
    end
  end # Email
end
