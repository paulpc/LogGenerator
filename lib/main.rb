require_relative 'sources.rb' 
require_relative 'attacks.rb'
require_relative 'tools.rb'
include Sources
include Attacks
include Tools

#set starting time for the event within the Time.new()
$time_diff=Time.new(2011,10,17,8,0,0,"-05:00")-Time.now
#$log_file="./output/temp_logs.txt"
$log_file={"Syslog"=>"messages", "Apache"=>"messages", "Mail"=>"mail.log", "Firewall"=>"firewall.log","Windows"=>"WindowsSecurity.log", "BluecoatSG"=>"proxySG_access_logs.log"}
#$log_file=["172.16.48.216"]

# loading user directory
 $directory={}
File.open( './config/users.yml' ) { |yf| $directory=YAML::load( yf ) }
# setting domain name
$domain_name="dopct"

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
    $directory.about:homekeys.each {|username|
      $userbase[username]=nil
    }
  end
  sleep 60
end
}
daily_base.run
#for testing we'll stop the white noise after the 
sleep 45


white_noise={}

#generating white noise 
white_noise[:web]=Thread.new {$servers[:apachez].white_noise }
white_noise[:fw]=Thread.new {$firewall.white_noise}
white_noise[:mail]=Thread.new {$servers[:email].white_noise}

p "[#{Time.now}] white noise generator should have started if true=#{$all_normal}"
#leaving 30 minutes of peace and quiet before digestive by-product colides with stationary rotary wing object
#sleep 1800 if $all_normal
p "[#{Time.now}] generating mind map before all the evil happens"
Tools::generate_mind_map
p "[#{Time.now}] starting the reconnesaince"
hacker=Bruteforce.new()
$firewall.zones.values.flatten.each {|zone|
hacker.port_scan(zone)  if zone !~ /192\.168/ and zone !~ /127\.0\.0/
}
p "[#{Time.now}] should start web recon here"
# continuing with a scan of the web servers
hacker.web_recon($servers[:apachez])

# email from vendor to one of the sys}admins (scipio)
# opening port in firewall, creating user on the qa machine and setting a crappy password
p "[#{Time.now}] vendor changes are abrewing"
vendor_ip=rand_ip()
$servers[:apachez_qa].apache_access_log(vendor_ip,get_time(),user_agent("chrome","windows7"),"","/status.php")
sleep 2
$servers[:apachez_qa].apache_access_log(vendor_ip,get_time(),user_agent("firefox","windows7"),"","/status.php")
sleep 2
$servers[:apachez_qa].apache_access_log(vendor_ip,get_time(),user_agent("ie","windows7"),"","/status.php")
sleep 10
$servers[:email].log_received({:host=>"vendor.com",:ip=>vendor_ip,:mail=>"innatentive.engineer@vendor.com"},$servers[:email].email_directory["Scipio"],true)
sleep 25
$firewall.admin_login($userbase["Scipio"].ip,"success",'Scipio')
sleep(10)
p "[#{Time.now}] improperly setting up firewall rules"
$firewall.zones["apache_qa"]="212.118.247.128/27"
$firewall.rule_set.push([10,["Untrust","Trust"],["apache_qa"],["all"]])
$firewall.rule_set.push([11,["apache_qa"],["Trust"],["all"]])
$firewall.sysconfig_change($userbase["Scipio"].ip,"Scipio")
#logging in the server and changing ips
$servers[:apachez_qa].login("Scipio",$userbase["Scipio"].ip,true)
$servers[:apachez_qa].ip=$firewall.assign("apache_qa")
$servers[:apachez_qa].sudo("success","ifconfig eth0 #{$servers[:apachez_qa].ip} netmask 255.255.255.224","Scipio","root")
sleep 2
$servers[:apachez_qa].sudo("success","route add default gw 212.118.247.129","Scipio","root")
sleep 2
$servers[:apachez_qa].sudo("success","su -","Scipio","root")
sleep 2
$servers[:apachez_qa].useradd("vendor_root","0","0")
sleep 2
$servers[:apachez_qa].passwd("vendor_root","0")
sleep 3
p "[#{Time.now}] vendor will now try to log in while attacker attakcs"
# as the vendor tries to log in, another portscan happens
actions={}
actions[:hacker]=Thread.new {
  while $all_normal
  sleep 300
  random_hacker=Bruteforce.new()
  random_hacker.ip=rand_ip()
  $firewall.zones.values.flatten.each {|zone|
  random_hacker.port_scan(zone)  if zone !~ /192\.168/ and zone !~ /127\.0\.0/
  sleep 15
  }
  sleep 5
  random_hacker.web_recon($servers[:apachez_qa])
  sleep 120
  random_hacker.ssh_sweep(:apachez_qa)
  random_hacker=nil
  end
}
#actions[:hacker].run

$servers[:apachez_qa].shutdown("reboot")
$servers[:apachez_qa].apache_daemon("start")
sleep 10
$servers[:apachez_qa].login("vendor_root",vendor_ip,true)
sleep 72
$servers[:apachez_qa].sudo("success","su -","vendor_root","root")
sleep 7
$servers[:apachez_qa].structure+=["/statistics.php","/status.php"]
$servers[:apachez_qa].apache_daemon("restart")
sleep(2)
$servers[:apachez_qa].apache_access_log(vendor_ip,get_time(),user_agent("chrome","windows7"),"","/status.php")
$servers[:apachez_qa].sshd("disconnect","vendor_root",vendor_ip)




sleep 15
p "[#{Time.now}] attempting a bruteforce for the <vendor_root> user"
hacker.ssh_bruteforce(:apachez_qa, "vendor_root", rand_ip(),true)
p "[#{Time.now}] attacker breaks the password finally"
$servers[:apachez_qa].sudo("success","su -","vendor_root","root")
sleep 2
$servers[:apachez_qa].useradd("brutus","0","0")
sleep 2
$servers[:apachez_qa].passwd("brutus","0")
sleep 2
$servers[:apachez_qa].passwd("vendor_root","0")
sleep 2
$servers[:apachez_qa].passwd("root")
sleep 5
$servers[:apachez_qa].structure+=["/bunatati/","/bunatati/unelte.html","/bunatati/pornosaguri.html","/bunatati/marfuri.html", "/bunatati/proxy_instructions.html"]
sleep 30
$servers[:apachez_qa].apache_daemon("restart")
$servers[:apachez_qa].useradd("utilizator","100","0")
$servers[:apachez_qa].sshd("disconnect","brutus",hacker.ip)
sleep 120

hacked_user="-"
p "[#{Time.now}] attacker turns this server into and unsuccessful ssh proxy - the bluecoat proxy will stop the traffic"
actions[:proxy]=Thread.new {
  while $all_normal
  attacker_ip=rand_ip()
  $servers[:apachez_qa].login("utilizator",attacker_ip,true)
  $servers[:bc_sg].web_traffic($servers[:apachez_qa].ip, hacked_user,$servers[:bc_sg].generate_forbidden_url, "-", user_agent("firefox","linux"))
  $servers[:apachez_qa].sshd("disconnect","utilizator",attacker_ip)  
  sleep(rand(20))
  end
}


sleep 120
p "[#{Time.now}] getting metasploit for the server to grab credentials after the unsuccessful sweep"
$servers[:apachez_qa].login("brutus",hacker.ip,true)
hacker.rdp_sweep($servers[:apachez_qa].ip)
$servers[:apachez_qa].sudo("success","chmod +xxx /home/brutus/framework-4.0.0-linux-mini.run","brutus","root")
$servers[:apachez_qa].sudo("success","/home/brutus/framework-4.0.0-linux-mini.run","brutus","root")

sleep 60
$userbase.values {|pc|
$firewall.traffic($servers[:apachez_qa], pc.ip, "microsoft-ds")  
}
# reverse shell
$firewall.traffic($userbase["Quintus"].ip,$servers[:apachez_qa].ip,"sun-answerbook")
hacked_user="Sulla"

p "[#{Time.now}] coopt the desktops and make them into bots"
$userbase["Quintus"].browse_web("www2.personal-ckguard.rr.nu/bot10297.exe")
sleep 30

$userbase.each {|user,pc|
  pc.login("Sulla", 528, 5, $servers[:apachez_qa].ip)
sleep 20+rand(25)
}

p "[#{Time.now}] turn the web server into a spam machine"
actions[:spam]=Thread.new {
  i=1
  while $all_normal
    is_spam=[true]*10+[false]*2*i
    hacker.spam($servers[:apachez_qa],is_spam.sample)
    i+=1
    sleep 1+rand(15)    
  end
}


print "[#{Time.now}] waiting to generate some more traffic"
1.upto(60){
  print "."
  sleep 10
}
$all_normal=false
p "done"
