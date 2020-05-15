describe AccountOrderNotificationJob, type: :job do
  before do
    @account = create(:account)
    @order = create(:order, account: @account)
    @job = AccountOrderNotificationJob.new
    @minutes = Random.rand(0..100)
  end

  describe 'SMS' do
    before do
      @phone = Faker::PhoneNumber.cell_phone
      @account.update(contact_sms_after_unseen: @minutes, contact_sms: @phone)
      allow(SmsNotificationJob).to receive(:perform_async)
    end

    it 'should send SMS notification to Acocunt after the number of minutes specified on Account' do
      @job.perform(:sms, @order.id)
      expect(SmsNotificationJob)
            .to have_received(:perform_async)
            .with(@phone, @order.send(:new_order_sms_body))
    end

    it 'should not send SMS notification if Acocunt has no :contact_sms_after_unseen' do
      @account.update(contact_sms_after_unseen: nil)
      @job.perform(:sms, @order.id)
      expect(SmsNotificationJob).to_not have_received(:perform_async)
    end

    it 'should not send SMS notification if Acocunt has no :contact_sms' do
      @account.update(contact_sms: nil)
      @job.perform(:sms, @order.id)
      expect(SmsNotificationJob).to_not have_received(:perform_async)
    end

    it 'should not send SMS notification @order.seen?' do
      @order.update(seen: true )
      @job.perform(:sms, @order.id)
      expect(SmsNotificationJob).to_not have_received(:perform_async)
    end
  end # SMS

  describe 'Email' do
    before do
      allow(OrdersMailer).to receive(:new_order).and_return(double(deliver_now: nil))
      @email = Faker::Internet.email
      @account.update(contact_email_after_unseen: @minutes, contact_email: @email)
    end

    it 'should send Email notification to account after specified minutes' do
      @job.perform(:email, @order.id, @sms_body)
      expect(OrdersMailer).to have_received(:new_order)
            .with(@email, @order.id)
    end

    it 'should not send Email notification if contact_email is not on @account' do
      @account.update(contact_email: nil)
      @job.perform(:email, @order.id, @sms_body)
      expect(OrdersMailer).to_not have_received(:new_order)
    end

    it 'should not send Email notification if contact_email is not on @account' do
      @account.update(contact_email_after_unseen: nil)
      @job.perform(:email, @order.id, @sms_body)
      expect(OrdersMailer).to_not have_received(:new_order)
    end

    it 'should not send SMS notification @order.seen?' do
      @order.update(seen: true)
      @job.perform(:email, @order.id)
      expect(OrdersMailer).to_not have_received(:new_order)
    end
  end # Email
end
