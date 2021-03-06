# To change this template, choose Tools | Templates
# and open the template in the editor.

module Sources
  class Apache<Syslog
    attr_accessor :random_traffic, :structure
    def initialize(host=nil)
      @host=host || "web_"+rand(999999).to_s.rjust(6,"0")      
      if $firewall
        @ip=$firewall.assign("web_servers")
      else
        @ip="192.168.100."+rand(255).to_s
      end
      hex_ip=[]
      @mac=rand(280533990614619).to_s(16).rjust(12,"0")
      @ip.split(".").each {|octet| hex_ip+=[octet.to_i.to_s(16).rjust(2,"0")]}
      @ip_v6="fe80::221:9bff:#{hex_ip[0]+hex_ip[1]}:#{hex_ip[2]+hex_ip[3]}"
      @tty=rand(9)+1
      @shadow={"root"=>{:gid=>"0", :uid=>"0"}}
      @etc_group={"0"=>"root","100"=>"users"}
      @random_traffic=true
      @structure=["/","/aboutus.html","/contact.html","/quote.html","/services.php", "/directory.php","/login.php"]
    end
  
    #log the start/stop/restart command on the daemon
    def apache_daemon(command="restart")
      case command
      when "start"
        apache_error(get_time(),nil,"notice","Apache/2.2.10 (Linux/SUSE) mod_ssl/2.2.10 OpenSSL/0.9.8h configured -- resuming normal operations")
      when "stop"
        apache_error(get_time(),nil,"notice","caught SIGTERM, shutting down")
      when "restart"
        apache_error(get_time(),nil,"notice","Graceful restart requested, doing restart")
        sleep(rand(4))
        apache_error(get_time(),nil,"notice","Apache/2.2.10 (Linux/SUSE) mod_ssl/2.2.10 OpenSSL/0.9.8h configured -- resuming normal operations")
      end    
    end
  
    #create a line in the apache access log format based on a set of parameters:
    #      source - the source IP where the traffic is coming from - defautls to "::1"
    #        date - the time the traffic happens - will default to now if nothing is entered
    #          ua - user agent - a chouice between linux, osx, windowsxp and windows7. Will default to random (see user_agent for more info on this method
    #     referer - the refering link to this request - will default to an empty string
    #     request - the url requested from this apache server
    # status_code - the code corresponding to this request - will default to 200 (OK)
    def apache_access_log(source="::1",date=get_time(),ua="random",referer="",request="/",status_code="200",size="-",user="-")
      $firewall.traffic(source,@ip,"http") if $firewall
      page=request.split("?").first
      unless @structure.include?(page)
        status_code="404" 
        apache_error(date,"error",source,"File does not exist: #{request}")
      end
      log("#{source} - #{user} [#{date.strftime("%d/%b/%Y:%H:%M:%S %z")}] \"GET #{request}\" #{status_code} #{size} \"#{referer}\" \"#{user_agent(ua)}\"","access_log")
   
    end
  
  
    # will generate random trafic from random IP addesses - think about looking to see if there's a firewall and transmitting traffic there as well.
    # We will need both a search engine crawler traffic and people traffic
    def white_noise()
      while $all_normal
        sleep(rand(6))
        #creating a random string to request
        random_request="/#{(0...(rand(15)+1)).map{97.+(rand(25)).chr}.join}.html"
        request=@structure*3+[random_request]
        source=rand_ip()
        apache_access_log(source,get_time(),"random","http%3//www.google.com/search%3widgets+agency+ok",request.sample) 
      end
    
    end
    
  # generates an error log line
    def apache_error(date=get_time(),level="error",client="127.0.0.1",message="File does not exist: /imagez")
      log("[#{date.strftime("%a %b %e %H:%M:%S %Y")}] [#{level}] [client #{client}] #{message}","error_log")
    end
  end
end
