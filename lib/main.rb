require_relative 'sources.rb' 
require_relative 'attacks.rb'
include Sources
include Attacks

#set starting time for the event within the Time.new()
$time_diff=Time.new(2011,10,17,8,0,0,"-05:00")-Time.now
#$log_file="./output/temp_logs.txt"
#$log_file={"Syslog"=>"messages", "Apache"=>"messages", "Firewall"=>"firewall.log","Windows"=>"Security.log", "Bluecoat"=>"bluecoat_sg_access_log.log"}
$log_file=["172.16.48.216"]
# starting the firewall
$firewall=Firewall.new()
# variable that will stay true as long as no major catastrophe happens
$all_normal=true

# loading user directory
 $directory={}
File.open( './config/users.yml' ) { |yf| $directory=YAML::load( yf ) }
# setting domain name
$domain_name="mystery_agency"

# starting the proxy server
bc_sg=BluecoatSG.new()

# creating the windows environment with logged in users  - will become the base for the bluecoat whitenoise
# 
$userbase={}
# the windows machines will be in an array

# assign each user a computer - create the daily logon process
# at 8:00 everybody loggs on, at 17:00 everybody loggs off

#keeping track of the servers in one hash array in order to keep track of them
$servers={}

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
sleep 45

white_noise={}
$servers[:linus]=Syslog.new("security_srv")
#server[:linus].boot
$servers[:linus].sshd("restart")
#server[:linus].sshd("bad user","dumbass","192.168.99.98")
#$firewall.traffic($userbase["Gaius"].ip,server[:linus].ip,"ssh")
$servers[:linus].sshd("success","Gaius",$userbase["Gaius"].ip)
#server[:linus].sudo("success","crontab -e","dumbass","root")
#server[:linus].sudo("success","bash","dumbass","root")
#server[:linus].useradd("haxx","0")
#
$servers[:apachez]=Apache.new()
$firewall.traffic($userbase["Gaius"].ip,$servers[:apachez].ip,"ssh")
$servers[:apachez].sshd("success","Gaius",$userbase["Gaius"].ip)

$userbase["Sulla"].useradd("Sulla","John","admin")
$userbase["Sulla"].usermod("Sulla","John",nil,626)
$userbase["Sulla"].login("John",534)


#apachez.shadow["test"]={:gid=>"234",:uid=>"324"}
#apachez.shadow["apache"]={:gid=>"8",:uid=>"30"}
#apachez.passwd("apache","234")s
#p "starting white noise"

white_noise[:web]=Thread.new {apachez.white_noise }
white_noise[:fw]=Thread.new {$firewall.white_noise}
white_noise[:proxy]=Thread.new {bc_sg.white_noise}
white_noise.values.join

#p "should generate 60 seconds worth of white noise"
#sleep 5
#$firewall.traffic("8.8.8.8","192.168.50.3","ssh")
#sleep 5
#$firewall.traffic("192.168.8.24","192.168.50.3","ssh")
#sleep 5
#$firewall.traffic("192.168.8.24","74.58.184.24","https")
#sleep 15
#white_noise[:web].terminate
#p "should stop random web traffic"
#p "sleeping for 360 before stopping the thread"
#sleep 6
#
#p "program over"


sleep 150
#puts "killing the fw white noise"


hacker=Bruteforce.new()
#serve.port_scan("212.118.247.32/27")
hacker.ssh_sweep(:linus)

#p "starting to look for password for Decimus"
 hacker.ssh_bruteforce(:linus,"Decimus",hacker.ip,true)
sleep(20)
$servers[:linus].sudo("success","su -","Decimus","root")
$servers[:linus].useradd("Dec_hax",rand(500).to_s,user="0")
$servers[:linus].passwd("Dec_hax","0")

hacker.rdp_sweep()

#p "changing the firewall rules"
$firewall.sysconfig_change($servers[:linus].ip,"Decimus")
$firewall.rule_set.push([8,["DMZ"],["Trust"],"ms-term-serv"])
$all_normal=false
sleep(15)
hacker.rdp_sweep($servers[:linus].ip)

$servers[:apachez].login("Scipio",$servers[:linus].ip,true)

#white_noise[:fw].terminate
#white_noise[:web].terminate
#white_noise[:proxy].terminate