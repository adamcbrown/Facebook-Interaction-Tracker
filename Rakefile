require_relative "./lib/facebook_scraper.rb"
require_relative "./lib/mailgun.rb"
require 'io/console'

task :send_data do
  @facebook_scraper=FacebookScraper.new(ENV["FB_EMAIL"], ENV["FB_PASSWORD"])
  @email_helper=MailgunHelper.new('key-b22a95527034e086108a9e66c0c5a807', 'sandboxdf010bb13e0c496da784c83c9aa6f1f2.mailgun.org')

  if(@facebook_scraper.status=="Login Successful")
    @facebook_scraper.update_names(50)
    @email_helper.send_email("adamcbrown1997@gmail.com", "#{@facebook_scraper.user_name}, your Facebook interaction list has arrived!", @facebook_scraper.email_body)
  else
     @email_helper.send_email("adamcbrown1997@gmail.com",
      "Your Facebook interaction cannot be retrieved",
      "Your facebook login information was entered incorrectly")
  end
end
