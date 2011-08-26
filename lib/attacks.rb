module Attacks
include IpConversion

def userlist()
  require 'yaml'
  users=[]
  File.open( './config/user_dictionary.yml' ) { |yf| users=YAML::load( yf ) }
end  

class Bruteforce
  # start a bruteforce attack
  attr_reader :ip, :host
  def initialize(host="blackhat"+rand(999999).to_s.rjust(6,"0"))
    @ip=Sources::rand_ip()
    @host=host
  end
  
  # pretend to perform a portscan on the destination range from the source ip, looking for the port range
  # if the port range is nil the entire range of ports will be scanned
  def port_scan(destination_range,source=@ip,port_range=nil)
    destination_array=range_to_array(destination_range)
    port_range=$firewall.services.keys[0..1024] unless port_range
      random_destination=[]
      while not destination_array.empty?
        random_destination.push(destination_array.delete(destination_array.sample))
      end
      
    port_range.each {|port|
      random_destination.each{|destination|
        $firewall.traffic(source,to_ip(destination.to_s(16)),port)
        sleep(rand(1))
      }
    }
  end
  
  # create the impression of a ssh user bruteforce. Create firewall traffic 
  def ssh_sweep(destination,source=@ip,userlist=nil)
    userlist=Attacks::userlist unless userlist
    # first do a comb over of the server and 
      userlist.each {|user|
        p destination, $servers[destination].ip
        $servers[destination].login(user,@ip,false)  if $firewall.traffic(source,$servers[destination].ip,"ssh")
      }
  end
  
  #ssh password bruteforce for a known user
  def ssh_bruteforce(destination,user,source=@ip,succesful=false)
   tries=[false]*(1000+rand(2000))
   tries.push(true) if succesful
   tries.each {|try|
       $servers[destination].login(user,@ip,try) if $firewall.traffic(source,$servers[destination].ip,"ssh")
   }
  end
  
  #do an rdp sweep if we're in the network
  def rdp_sweep(source=@ip, userlist=nil)
    userlist=Attacks::userlist unless userlist
    #make sure the ip is in the 
    userlist.each {|user|
      computer=$userbase.values.sample
      computer.login(user,528, 10, source) if $firewall.traffic(source,computer.ip,"ms-term-serv")
    }
  end
  
end
  
#class for creating spam emails
class Spam
  #initialize the victim host that produces the different types of spam 
  def initialize(host="blackhat"+rand(999999).to_s.rjust(6,"0"))
    
  end
  
  # Free Viagra Pills
  def viagra(source, destination)
    
  end
  
 
end

end
