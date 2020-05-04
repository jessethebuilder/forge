describe SmsNotificationJob, type: :job do
  before do
    @cassette = 'jobs/sms_notification_job/send_sms'
    @phone = '223-456-7800'
    @body = "Test, Yo"
    @job = SmsNotificationJob.new
    VCR.insert_cassette(@cassette)
  end

  after do
    VCR.eject_cassette(@cassette)
  end

  it 'return a Twilio Message' do
    @job.perform(@phone, @body).class.should == Twilio::REST::Api::V2010::AccountContext::MessageInstance
  end

  it 'should send TO provided param, prefixed by +1, and missing -' do
    @job.perform(@phone, @body).to.should == '+1' + @phone.gsub('-', '')
  end

  it 'should send FROM ENV var' do
    @job.perform(@phone, @body).from.should == ENV.fetch('TWILIO_OUTGOING_NUMBER')
  end

  it 'should return body' do
    @job.perform(@phone, @body).body.should == @body
  end
end
