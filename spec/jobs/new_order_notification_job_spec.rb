describe NewOrderNotificationJob, type: :job do
  before do
    @order = create(:order)
    @account = @order.account
    @job = NewOrderNotificationJob.new
    @seconds = Random.rand(1..100)

    allow(SmsNotificationJob).to receive(:perform_in)
    allow(SmsNotificationJob).to receive(:perform_async)
  end


  describe 'AccountOrderNotificationJob' do
    before do
      @account.update(
        sms: '123-456-7890',
        email: 'jeff@test.com',
        email_after_unseen: 10,
        sms_after_unseen: 22
      )
    end

    it 'should call AccountOrderNotificationJob for each action' do
      expect(AccountOrderNotificationJob).to receive(:perform_in)
            .with(22.seconds, :sms, @order.id)

      expect(AccountOrderNotificationJob).to receive(:perform_in)
            .with(10.seconds, :email, @order.id)

      @job.perform(@order.id)
    end
  end

  describe 'SMS Notification' do
    before do
      @phone = Faker::PhoneNumber.cell_phone
      @account.update(sms: @phone, email_after_unseen: @seconds)
      allow(AccountOrderNotificationJob).to receive(:perform_in)
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
              .with(@menu_phone, @order.send(:new_order_sms_body))
      end
    end # has Menu
  end # SMS

  describe 'Email Notification' do
    before do
      @email = Faker::Internet.email
      @account.update(email_after_unseen: @seconds, email: @mail)
      allow(OrdersMailer).to receive(:new_order).and_call_original
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

      it 'should NOT try to send an email, if @account.email is blank' do
        @menu.update(email: '')
        expect(OrdersMailer).not_to receive(:new_order)
        @job.perform(@order.id)
      end
    end
  end # Email
end
