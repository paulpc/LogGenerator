require_relative 'sys_log.rb'
require_relative 'log.rb'
module Sources
include Log
class BluecoatSG
  def initialize(host,ip)
    @host=host || "BklueCoatProxy_"+rand(999999).to_s.rjust(6,"0")      
    @ip=ip || "192.168.2."+rand(255).to_s
  end
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
