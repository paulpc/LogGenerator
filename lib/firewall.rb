# To change this template, choose Tools | Templates
# and open the template in the editor.
require_relative 'ip_conversion.rb'

module Sources
  class Firewall
    include IpConversion
    attr_reader :zones, :rule_set, :internal_ip, :ip, :host
    def initialize(host=nil,ip=nil)
      @assigned_ips=Hash.new
      @session_id=18731
    @zones = {"firewalls"=>"192.168.1.0/28","web_servers"=>"212.118.247.0/27", "mail_servers"=>"212.118.246.232/29", "Trust"=>"192.168.8.1/23", 
      "DMZ"=>"212.118.247.32/27", "ftp_servers"=>"212.118.246.240/28", "localhost"=>"127.0.0.0/8", "public_gateway"=>"212.118.246.224/29", "database_servers"=>"192.168.50.1/25"}
    # unknown zones will default to Untrust
    #  let's pretend to be this zone: 
    #  212.118.246.224 - 212.118.247.255
      @rule_set=[
           [1, ["Untrust","Trust"],["web_servers"],["http","https"]], 
           [2, ["Untrust","Trust"],["mail_servers"],["smtp","pop3","imap"]], 
           [3, ["Untrust","Trust"],["ftp_servers"],["ftp"]],
           [4, ["Trust"],["web_servers","database_servers","DMZ","ftp_servers","mail_servers"],["ssh","icmp"]],
           [5, ["Trust"],["firewalls"],["ssh","https"]],
           [6, ["web_servers"],["database_servers"],["mysql","oracle"]],
           [7,["Trust"],["Untrust"],["https","http"]]
        ]      
      @nat_zones=["Trust","database_servers"]
      
      @services={}
      #creating a list of services - using the nmap list
    File.open("nmap-services.txt","r").each {|line|
      if line !~ /^[\s\t]*#/
        serv_components=line.split(/\t/)        
        port,protocol=serv_components[1].split(/\//)
         serv_components[0]="#{protocol}/port:#{port}" if serv_components[0]=="unknown"
        @services[serv_components[0]]={} unless @services[serv_components[0]]
        @services[serv_components[0]][protocol]=port
      end
       }
        
      @internal_ip=assign("firewalls")
      @ip=assign("public_gateway")
      @host= host || "ns5xt_"+rand(999999).to_s.rjust(6,"0")
    
    end
    
    # generate traffic white noise to confuse participants and to mimic the background noise of the interwebs   
    def white_noise
          
    end
    
    # simulate an admin login - either successful or unsuccessful
    def admin_login(source,status,user='netscreen')
    case status
    when "success"
      fw_log(519,"Admin user \"#{user}\" logged in for Web(http) management (port 80) from #{source}:#{rand(50000)+1752} (#{get_time().strftime("%Y-%m-%d %H:%M:%S")})")
    when "failure"
      fw_log(518,"Admin user \"#{user}\" login attempt for Web(http) management (port 80) from #{source}:#{rand(50000)+1752} failed. (#{get_time().strftime("%Y-%m-%d %H:%M:%S")})")
    end
    end
    
    # simulate a change of firewall rules 
    def sysconfig_change(source,user='netscreen')
      fw_log(767,"System configuration saved by netscreen via web from host #{source} to #{@internal_ip}:80 by #{user} (#{get_time().strftime("%Y-%m-%d %H:%M:%S")})")
    end
    
    # simulate a dhcp lease from the firewall to the Trust computers. Pretty much a logged assign
    def dhcp(mac)
      ip=assign("Trust")
      fw_log(527,"IP address #{ip} has been assigned to #{mac} (#{get_time().strftime("%Y-%m-%d %H:%M:%S")})")
      return ip
    end
    
    # assign an ip to the computers in the fw_zone by request
    def assign(fw_zone)
      @assigned_ips[fw_zone]=Array.new unless @assigned_ips[fw_zone]
      start_ip,cidr=@zones[fw_zone].split("/")
      start_int=(to_hex(start_ip).to_i(16))+1
      end_int=(start_int+2**(32-cidr.to_i))-1
      a_ip=nil
      start_int.upto(end_int) {|int_ip|
        ip=to_ip(int_ip.to_s(16))
        a_ip = ip unless @assigned_ips[fw_zone].include?(ip) or a_ip
      }      
      if a_ip
        @assigned_ips[fw_zone].push(a_ip)
        return a_ip
      else
        raise "Unable to assign another IP to zone #{fw_zone}. \nIPs already in the zone:\n#{@assigned_ips[fw_zone].join("\n")}"
      end
      
    end
    
    # keep track of the firewall sessions in order to have sequential numbers for the events
    def next_session_id()
    @session_id+=1
    @session_id=2184 if @session_id >120000
    return @session_id
    end
    
    
    #engine to figure out where a certain IP belongs  
    def get_zone(ip)
      @zones.each {|fw_zone,ip_range|
        return fw_zone if in_range?(ip,ip_range)
      }
      return nil
    end
    
    #engine to analyze traffic from sourceIP to destinationIP on the service desired agains the firewall rules defined in @rule_set
    def analize_traffic(sourceIP,destinationIP,service)
      src_zone=get_zone(sourceIP) || "Untrust"
      dest_zone=get_zone(destinationIP) || "Untrust"
      permit=nil
      @rule_set.each {|rule_id,src_zones,dest_zones,services|
        if src_zones.include?(src_zone) and dest_zones.include?(dest_zone) and services.include?(service)
          permit={:polid=>rule_id,:action=>"Permit",:src_zone=>src_zone,:dst_zone=>dest_zone}
        end
      }
      return permit || {:polid=>99,:action=>"Deny",:src_zone=>src_zone,:dst_zone=>dest_zone}
    end

    
    def fw_log(type,message)
     case type
      when 257
        message_type="[Root]system-notification-00257(traffic)"  
      when 518..519
        message_type="[Root]system-warning-00#{type}"
      when 527,551,767
        message_type="[Root]system-information-00#{type}"
      end
      log("#{@host}: NetScreen device_id=#{@host}  #{message_type}: #{message}")
    end
    
    #log traffic from a source IP to a destination IP. It takes the following variables:
    def traffic(source,destination,service=@services.keys.sample,date=get_time(),src_port=rand(45000)+20000,bytes=rand(1900))
      flow=analize_traffic(source,destination,service)  
      if service=="icmp"
        proto=1
      elsif @services[service].keys.include?("tcp")
        proto=6
      else
        proto=17
      end
      
      if @nat_zones.include?(flow[:src_zone]) and flow[:dst_zone] == "Untrust"
        src=source
        dest=destination
        xsrc=@ip
        xdest=destination
      elsif flow[:src_zone] == "Untrust" and @nat_zones.include?(flow[:dst_zone])
        src=source
        dest=@ip
        xsrc=source
        xdest=destination
      else
        src=source
        xsrc=source
        dest=destination
        xdest=destination
      end
      
        if flow[:polid] == 99
          fw_log(257,"start_time=\"#{date.strftime("%Y-%m-%d %H:%M:%S")}\" duration=0 policy_id=#{flow[:polid]} service=#{service} proto=#{proto} src zone=#{flow[:src_zone]} dst zone=#{flow[:dst_zone]} action=#{flow[:action]} sent=#{rand(128)} rcvd=#{rand(128)} src=#{src} dst=#{dest} src_port=#{src_port} dst_port=#{@services[service].values.first} session_id=#{next_session_id}")
        else
          fw_log(257,"start_time=\"#{date.strftime("%Y-%m-%d %H:%M:%S")}\" duration=#{rand(10)} policy_id=#{flow[:pol_id]} service=#{service} proto=#{proto} src zone=#{flow[:src_zone]} dst zone=#{flow[:dst_zone]} action=#{flow[:action]} sent=#{bytes} rcvd=#{bytes} src=#{src} dst=#{dest} src_port=#{src_port} dst_port=#{@services[service].values.first} src-xlated ip=#{xsrc} port=#{src_port} dst-xlated ip=#{xdest} port=#{@services[service].values.first} session_id=#{next_session_id}")
        end
    
    end
    
  private :get_zone, :analize_traffic, :next_session_id  
  end
  
end
