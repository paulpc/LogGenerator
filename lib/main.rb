require_relative 'sources.rb' 
require_relative 'attacks.rb'
require_relative 'tools.rb'
include Sources
include Attacks
include Tools

#set starting time for the event within the Time.new()
$time_diff=Time.new(2011,10,17,8,0,0,"-05:00")-Time.now
$log_file="./output/temp_logs.txt"
#$log_file={"Syslog"=>"messages", "Apache"=>"messages", "Firewall"=>"firewall.log","Windows"=>"Security.log", "Bluecoat"=>"bluecoat_sg_access_log.log"}
#$log_file=["172.16.48.216"]

# loading user directory
 $directory={}
File.open( './config/users.yml' ) { |yf| $directory=YAML::load( yf ) }
# setting domain name
$domain_name="mystery_agency"

# starting the firewall and the web proxy - they need to both be on for the user piece to work
$firewall=Firewall.new()
$servers={}
$servers[:bc_sg]=BluecoatSG.new()
# variable that will stay true as long as no major catastrophe happens
# for testing purposes, we will take out the white noise
$all_normal=true

# initializing all the servers
 $servers[:email]=Mail.new()
 $servers[:linus]=Syslog.new("security_srv")
 $servers[:apachez]=Apache.new()
 $servers[:apachez_qa]=Apache.new()





# creating the windows environment with logged in users  - will become the base for the bluecoat whitenoise
# 
$userbase={}
# the windows machines will be in an array

# assign each user a computer - create the daily logon process
# at 8:00 everybody loggs on, at 17:00 everybody loggs off

#keeping track of the servers in one hash array in order to keep track of them


daily_base=Thread.new {
while $all_normal
  current_time=get_time()
  if not current_time.saturday? and not current_time.sunday? and current_time.hour==8 and current_time.min==00
    $directory.keys.each {|username|
    windows_box=Windows.new()
    windows_box.login(username)
    $userbase[username]=windows_box
    sleep(rand(4))
    }
  elsif not current_time.saturday? and not current_time.sunday? and current_time.hour==17 and current_time.min==00
    $directory.keys.each {|username|
      $userbase[username]=nil
    }
  end
  sleep 60
end
}
daily_base.run
#for testing we'll stop the white noise after the 
$all_normal=false
sleep 45



white_noise={}
$servers[:linus].sshd("restart")
$servers[:linus].sshd("success","Gaius",$userbase["Gaius"].ip)
$servers[:apachez_qa].structure+=["/statistics.php","/status.php"]


#generating white noise 
white_noise[:web]=Thread.new {$servers[:apachez].white_noise }
white_noise[:fw]=Thread.new {$firewall.white_noise}
white_noise[:mail]=Thread.new {$servers[:email].white_noise}

#leaving 30 minutes of peace and quiet before digestive by-product colides with stationary rotary wing object
sleep 1800 if $all_normal
# starting the attack
hacker=Bruteforce.new()
$firewall.zones.values.flaten.each {|zone|
hacker.port_scan(zone)  if zone !~ /192\.168/
}
# continuing with a scan of the web servers
hacker.web_recon($servers[:apache_qa])
hacker.web_recon($servers[:apache])

# email from vendor to one of the sysadmins (scipio)
# opening port in firewall, creating user on the qa machine and setting a crappy password
vendor_ip=rand_ip()
$servers[:email].log_received({:host=>"vendor.com",:ip=>vendor_ip,:mail=>"innatentive.engineer@vendor.com"},@email_directory["Scipio"],true)
sleep 25
$firewall.admin_login($userbase["Scipio"].ip,"success",'Scipio')
sleep(10)
$firewall.zones["apache_qa"]="212.118.247.128/27"
$firewall.rule_set.push([10,["Untrust"],["apache_qa"],["ssh"]])
$firewall.sysconfig_change($userbase["Scipio"].ip,"Scipio")
#logging in the server and changing ips
$servers[:apache_qa].login("Scipio",$userbase["Scipio"].ip,true)
$servers[:apache_qa].ip=$firewall.assign("apache_qa")
$servers[:apache_qa].sudo("success","ifconfig eth0 #{$servers[:apache_qa].ip} netmask 255.255.255.224","Scipio","root")
sleep 2
$servers[:apache_qa].sudo("success","route add default gw 212.118.247.129","Scipio","root")
sleep 2
$servers[:apache_qa].sudo("success","su -","Scipio","root")
sleep 2
$servers[:apache_qa].useradd("vendor_root","0","0")
sleep 2
$servers[:apache_qa].passwd("vendor_root","0")
sleep 3
$servers[:apache_qa].shutdown("reboot")
$servers[:apache_qa].apache_daemon("start")
sleep 10
$servers[:apache_qa].login(vendor_ip,"success","vendor_root")



#apachez.shadow["test"]={:gid=>"234",:uid=>"324"}
#apachez.shadow["apache"]={:gid=>"8",:uid=>"30"}
#apachez.passwd("apache","234")s





#sleep 150
##puts "killing the fw white noise"
#
#
#

##p "starting to look for password for Decimus"
# hacker.ssh_bruteforce(:linus,"Decimus",hacker.ip,true)
#sleep(20)
#$servers[:linus].sudo("success","su -","Decimus","root")
#$servers[:linus].useradd("Dec_hax",rand(500).to_s,user="0")
#$servers[:linus].passwd("Dec_hax","0")
#
#hacker.rdp_sweep()

#p "changing the firewall rules"
#$firewall.sysconfig_change($servers[:linus].ip,"Decimus")
#$firewall.rule_set.push([8,["DMZ"],["Trust"],"ms-term-serv"])
#$all_normal=false
#sleep(15)
#hacker.rdp_sweep($servers[:linus].ip)

#$servers[:apachez].login("Scipio",$servers[:linus].ip,true)

p "generating mind map"
Tools::generate_mind_map
sleep 120
$all_normal=false
p "you should have stopped now"
