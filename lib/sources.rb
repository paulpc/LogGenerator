require_relative 'sys_log.rb'
require_relative 'apache.rb'
require_relative 'firewall.rb'
require_relative 'bluecoat.rb'
require_relative 'windows.rb'
require_relative 'log.rb'

require 'yaml'
module Sources
include Log
#methods that will be used for all the classes contained within this module

  # this method will generate a random foreign IP to be used by whatever method choses to use it.
def rand_ip()
  begin 
    ip="#{rand(253)+1}.#{rand(253)+1}.#{rand(253)+1}.#{rand(253)+1}"
  end while ip !~ /192\./ and ip !~ /172\./ and ip !~ /10\./
  return ip
end

def rand_domain(type="www")
  foreign_domains=[]
   File.open( './config/mail_domains.yml' ) { |yf| foreign_domains=YAML::load( yf ) }
   
   return "#{type}.#{foreign_domains.sample}"
end

# function to figure out the time from the time difference set up in the main.rb
def get_time()
return Time.now+$time_diff  
end

# create user agent strings based on inputed browser and operating system
def user_agent(browser="random",os="windows7")
    case os
    when "windows7"
      os_part="Windows NT 6.1; WOW64; rv:6.0a2"
    when "windowsXP"
      os_part="Windows NT 5.1; rv:2.0.1"
    when "linux"
      os_part="X11; Linux x86_64"
    when "osx"
      os_part="Macintosh; Intel Mac OS X 10.7; rv:5.0"
    end
    case browser
    when "firefox"
      user_string="Mozilla/5.0 (#{os_part}) Gecko/20110619 Firefox/5.0"
    when "ie"
      user_string="Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Win64; x64; Trident/5.0)"
    when "chrome"
      user_string="Mozilla/5.0 (#{os_part}) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.814.0 Safari/535.1"
    when "safari"
      user_string="Mozilla/5.0 (#{os_part}) AppleWebKit/533.21.1 (KHTML, like Gecko) Version/5.0.5 Safari/533.21.1"
    when "opera"
      user_string="Opera/9.80 (#{os_part}) Presto/2.8.131 Version/11.11"
    when "random"
      user_agent_strings=[]
      File.open( './config/user_agent_strings.yml' ) { |yf| user_agent_strings=YAML::load( yf ) }
      user_string=user_agent_strings[rand(user_agent_strings.length)]
    end
    
    return user_string
  end
    
  class Ftp<Syslog
    def initialize(host,ip)
    @host=host || "ftp_"+rand(999999).to_s.rjust(6,"0")      
    @ip=ip || "192.168.110."+rand(255).to_s
  end   
  end
  


 
end
