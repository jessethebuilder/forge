describe NewOrderNotificationJob, type: :job do
  before do
    @order = create(:order)
    @account = @order.account
    @job = NewOrderNotificationJob.new
  end

  describe 'Account Socket Notification' do
    before do
      allow(ActionCable.server).to receive(:broadcast)
    end

    it 'should Broadcast on creation' do
      @job.perform(@order.id)

      expect(ActionCable.server).to have_received(:broadcast).with(
        "orders_for_account_#{@order.account.id}",
        {
          action: 'new_order',
          data: {
            order_id: @order.id
          }
        }
      )
    end
  end # Account Socket Notification

  describe 'SMS Notification' do
    before do
      @phone = Faker::PhoneNumber.cell_phone
      @account.update(contact_sms: @phone)
      allow(SmsNotificationJob).to receive(:perform_async)
      allow(SmsNotificationJob).to receive(:perform_in)
    end

    it 'should send SMS notification to Acocunt after the number of minutes specified on Account' do
      minutes = Random.rand(0..100)
      @account.update(contact_after: minutes)

      @job.perform(@order.id)
      expect(SmsNotificationJob)
            .to have_received(:perform_in)
            .with(minutes.minutes, @phone, @job.send(:sms_body))
    end

    it 'should not SMS notification if contact_after is nil' do
      @account.update(contact_after: nil)
      @job.perform(@order.id)
      expect(SmsNotificationJob).not_to have_received(:perform_in)
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
