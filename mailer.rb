require 'rubygems'
require 'actionmailer'

ActionMailer::Base.logger = Logger.new(STDOUT)
ActionMailer::Base.logger.level = Logger::DEBUG
ActionMailer::Base.template_root = '.'
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => 'smtp.gmail.com',
  :port => 587, # or 465
  :tls => true,
  :user_name => 'burkefarm@gmail.com',
  :password => '(sekrit)',
  :authentication => :plain,
  :enable_starttls_auto => true
}

class FarmMailer < ActionMailer::Base
  def newsletter(text, subject_prefix = '')
    subject subject_prefix.to_s + 'News from the farm - ' + Date.today.to_s
    from 'The Farming Engineers <burkefarm@gmail.com>'
    body :text => text
  end
end

ARGV.each do |file|
  mail = FarmMailer.create_newsletter File.read(file), '[test] '
  [['spraints@gmail.com', 'maburke@sep.com'], 'mrs.burke@gmail.com'].each do |destinations|
    mail.to = destinations
    FarmMailer.deliver mail
  end
end
