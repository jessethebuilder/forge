class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('EMAIL_OUTGOING_ADDRESS')
  layout 'mailer'
end
