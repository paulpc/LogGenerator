require_relative 'sys_log.rb'
require_relative 'apache.rb'
require_relative 'firewall.rb'
require_relative 'log.rb'
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

# function to figure out the time from the time difference set up in the main.rb
def get_time()
return Time.now+$time_diff  
end
  
  class Windows
    def initialize(host,ip)
    @host=host || "agency_win_"+rand(999999).to_s.rjust(6,"0")      
    @ip=ip || "192.168.4."+rand(255).to_s
  end
  end
  
  class Ftp<Syslog
    def initialize(host,ip)
    @host=host || "ftp_"+rand(999999).to_s.rjust(6,"0")      
    @ip=ip || "192.168.110."+rand(255).to_s
  end   
  end
  
  class Mail<Syslog
   def initialize(host,ip)
    @host=host || "mail_"+rand(999999).to_s.rjust(6,"0")      
    @ip=ip || "192.168.90."+rand(255).to_s
  end  
  end

 
end
