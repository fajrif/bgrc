class ApplicationMailer < ActionMailer::Base
	default from: configatron.admin_email
  layout "mailer"
end
