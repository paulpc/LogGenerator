module Attacks
include IpConversion

def userlist()
  require 'yaml'
  users=[]
  File.open( './config/user_dictionary.yml' ) { |yf| users=YAML::load( yf ) }
  return users
end  

class Bruteforce
  # start a bruteforce attack
  attr_reader :host
  attr_accessor :ip
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
      userlist.each {|user|1
        $servers[destination].login(user,@ip,false)  if $firewall.traffic(source,$servers[destination].ip,"ssh")
        sleep(rand(1))
      }
  end
  
  #ssh password bruteforce for a known user
  def ssh_bruteforce(destination,user,source=@ip,succesful=false)
   tries=[false]*(100+rand(200))
   tries.push(true) if succesful
   tries.each {|try|
       $servers[destination].login(user,@ip,try) if $firewall.traffic(source,$servers[destination].ip,"ssh")
       sleep(rand(3))
   }
  end
  
  #do an rdp sweep if we're in the network
  def rdp_sweep(source=@ip, userlist=nil)
    userlist=Attacks::userlist unless userlist
    #make sure the ip is in the trust
    userlist.each {|user|
      computer=$userbase.values.sample
      computer.login(user,528, 10, source) if $firewall.traffic(source,computer.ip,"ms-term-serv")
    }
  end
  
  #do a bit of recon on the web server and focus on the directory
  def web_recon(victim,source=@ip)
        #p "[#{Time.now}] looking at #{victim.host}"
        requests=[]
          1.upto(250) { requests.push("/#{(0...(rand(15)+1)).map{97.+(rand(25)).chr}.join}.html") }
          requests+=victim.structure
          requests.sample(requests.length).each {|req|
            victim.apache_access_log(source,get_time(),"random","",req)     
            sleep rand(2)
          }
        users=userlist()
        users+=$directory.keys
        users.sample(users.length).each {|user|
            request="/directory.php?name=#{user}&details=ALL"
            victim.apache_access_log(source,get_time(),"random","",request)
            sleep rand(2)
        }
        
  end
  
def spam(victim,unsaturated=true)
  recipients=userlist.sample(15)
  foreign_domain=rand_domain("mail")
  foreign_ip=rand_ip()
  recipients.each {|person|
    foreign_email="#{person.downcase}@#{foreign_domain.sub(/mail\./,"")}"
    $firewall.traffic(victim.ip,$servers[:email].ip,"smtp")
    $servers[:email].log_sent({:host=>foreign_domain,:ip=>foreign_ip,:mail=>foreign_email},$servers[:email].email_directory.values.sample,unsaturated)
    
  }
end

end
  

end
