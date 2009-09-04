require 'csv'
require 'optparse'
require 'rubygems'
require 'actionmailer'
require 'csv'
require 'pp'

RootDir = Pathname.new(__FILE__).expand_path.dirname.to_s
DefaultMailingList = '/Users/lisa/Documents/farm email list.txt'

options = {
  :mailing_list => DefaultMailingList,
  :password => 'todo'
}
opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options] newsletter.txt"

  opts.on("-t", "--test", "-n", "--dry-run", "Do a dry run (don't actually send)") do
    options[:is_test] = true
  end

  opts.on("-l", "--list FILE", "A file full of email addresses to use.", "default is #{DefaultMailingList}") do |v|
    options[:mailing_list] = v
  end

  opts.on("-p", "--password PASSWORD", "The burkefarm@gmail.com password.") do |v|
    options[:password] = v
  end

  opts.on('-h', '--help', 'Show this message') do
    puts opts
    exit
  end
end
opt_parser.parse!


ActionMailer::Base.logger = Logger.new(STDOUT)
ActionMailer::Base.logger.level = Logger::DEBUG
ActionMailer::Base.template_root = RootDir
ActionMailer::Base.raise_delivery_errors = true

# replace Password with a prompt.
#   http://www.google.com/search?q=ruby+read+password+from+stdin
if options[:is_test]
  ActionMailer::Base.delivery_method = :test
elsif defined? JRUBY_VERSION
  $: << RootDir
  require 'mail.jar'
  require 'activation.jar'
  require 'java_mail' # loads the actionmailer-javamail gem
  ActionMailer::Base.delivery_method = :javamail
  ActionMailer::Base.javamail_settings = {
    :protocol => :smtps,
    :address => 'smtp.gmail.com',
    :port => 465, # or 587
    :user_name => 'burkefarm@gmail.com',
    :password => options[:password]
  }
else
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :address => 'smtp.gmail.com',
    :port => 587, # or 465
    :tls => true,
    :user_name => 'burkefarm@gmail.com',
    :password => options[:password],
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end

class FarmMailer < ActionMailer::Base
  def newsletter(text, subject_prefix = '')
    subject subject_prefix.to_s + 'News from the farm - ' + Date.today.to_s
    from 'The Farming Engineers <burkefarm@gmail.com>'
    body :text => text
  end
end

if ARGV.empty?
  puts opt_parser
else
  addresses = File.readlines(options[:mailing_list]).collect { |a| a.strip }
  ARGV.each do |file|
    mail = FarmMailer.create_newsletter File.read(file)
    addresses.each do |destinations|
      mail.to = destinations
      FarmMailer.deliver mail
      puts "*** Successfully sent #{file} to #{destinations.inspect}", ''
    end
  end
end
