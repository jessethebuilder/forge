describe AccountOrderNotificationJob, type: :job do
  before do
    @minutes = Random.rand(0..100)
    @phone = Faker::PhoneNumber.cell_phone
    @account = create(:account, contact_after: @minutes, contact_sms: @phone  )
    @order = create(:order, account: @account)
    @job = AccountOrderNotificationJob.new
    @sms_body = "body goes here"

    allow(SmsNotificationJob).to receive(:perform_async)
  end

  it 'should send SMS notification to Acocunt after the number of minutes specified on Account' do
    @job.perform(@order.id, @sms_body)
    expect(SmsNotificationJob)
          .to have_received(:perform_async)
          .with(@phone, @sms_body)
  end
end
