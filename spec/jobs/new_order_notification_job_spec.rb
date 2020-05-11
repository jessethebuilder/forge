describe NewOrderNotificationJob, type: :job do
  before do
    @order = create(:order)
    @account = @order.account
    @job = NewOrderNotificationJob.new
    allow(SmsNotificationJob).to receive(:perform_in)
    allow(SmsNotificationJob).to receive(:perform_async)
  end

  describe 'SMS Notification' do
    before do
      @phone = Faker::PhoneNumber.cell_phone
      @minutes = Random.rand(1..100)
      @account.update(contact_sms: @phone, contact_after: @minutes)
      allow(AccountOrderNotificationJob).to receive(:perform_in)
    end

    it 'should call AccountOrderNotificationJob' do
      @job.perform(@order.id)
      expect(AccountOrderNotificationJob)
            .to have_received(:perform_in)
            .with(@minutes.minutes, @order.id, @job.send(:sms_body))
    end

    it 'should not SMS notification if contact_after is nil' do
      @account.update(contact_after: nil)
      @job.perform(@order.id)
      expect(AccountOrderNotificationJob).not_to have_received(:perform_in)
    end

    it 'should not SMS notification if :contact_sms is nil' do
      @account.update(contact_sms: nil)
      @job.perform(@order.id)
      expect(AccountOrderNotificationJob).not_to have_received(:perform_in)
    end

    context '@order has a Menu' do
      before do
        @menu_phone = Faker::PhoneNumber.cell_phone
        @menu = create(:menu, orders: [@order], contact_sms: @menu_phone)
      end

      it 'should attempt to immediatly notify Menu :contact_sms' do
        @job.perform(@order.id)
        expect(SmsNotificationJob)
              .to have_received(:perform_async)
              .with(@menu_phone, @job.send(:sms_body))
      end
    end # has Menu
  end # SMS

  describe 'Email Notification' do
    before do
      allow(OrdersMailer).to receive(:new_order).and_call_original
    end

    it 'should call send email to Account, is email address is provided' do
      email = Faker::Internet.email
      @account.update(contact_email: email)
      expect(OrdersMailer).to receive(:new_order).with(email, @order.id)
      @job.perform(@order.id)
    end

    it 'should NOT try to send an email, if @account.contact_email is blank' do
      @account.update(contact_email: '')
      expect(OrdersMailer).not_to receive(:new_order)
      @job.perform(@order.id)
    end

    context 'Order has Menu' do
      before do
        @menu = create(:menu, account: @account, orders: [@order])
      end
      it 'should call send email to Account, is email address is provided' do
        email = Faker::Internet.email
        @menu.update(contact_email: email)
        expect(OrdersMailer).to receive(:new_order).with(email, @order.id)
        @job.perform(@order.id)
      end

      it 'should NOT try to send an email, if @account.contact_email is blank' do
        @menu.update(contact_email: '')
        expect(OrdersMailer).not_to receive(:new_order)
        @job.perform(@order.id)
      end
    end
  end # Email
end
