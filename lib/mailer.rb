require 'mail'

module Mailer
  EMAIL_OPTIONS = { :address              => "smtp.gmail.com",
                    :port                 => 587,
                    :domain               => ENV['EMAIL_DOMAIN'],
                    :user_name            => ENV['EMAIL_USERNAME'],
                    :password             => ENV['EMAIL_PASSWORD'],
                    :authentication       => 'plain',
                    :enable_starttls_auto => true  }

  EMAIL_FROM = ENV['EMAIL_FROM']
  EMAIL_TO = ENV['EMAIL_TO']
  EMAIL_CC = ENV['EMAIL_CC']

  # Send results
  def self.send_results(name, results)
    Mail.defaults do
      delivery_method :smtp, EMAIL_OPTIONS
    end

    mail = Mail.new do
      from     EMAIL_FROM
      to       EMAIL_TO
      cc       EMAIL_CC
      subject  "CMUE results #{name}"

      add_file :filename => "#{Time.now.to_i}.txt", :content => results

      body 'Result is ready.'
    end

    mail.deliver!
  end
end