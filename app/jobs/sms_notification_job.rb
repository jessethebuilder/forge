class SmsNotificationJob
  include Sidekiq::Worker

  def perform(to, body)
    twilio_client.messages.create(
      from: ENV.fetch('TWILIO_OUTGOING_NUMBER'),
      to: to,
      body: body
    )
  end

  def twilio_client
    @twilio_client ||= Twilio::REST::Client.new(
      ENV.fetch('TWILIO_ID'),
      ENV.fetch('TWILIO_SECRET')
    )
  end
end
