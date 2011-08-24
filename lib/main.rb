require_relative 'sources.rb' 
include Sources

#set starting time for the event within the Time.new()
$time_diff=Time.new(2011,10,17,8,0,0,"-05:00")-Time.now
$log_file="temp_logs.txt"
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

sleep 60

#white_noise={}
linus=Syslog.new("security_srv")
linus.boot
#linus.sshd("restart")
#linus.sshd("bad user","dumbass","192.168.99.98")
$firewall.traffic($userbase["Gaius"].ip,linus.ip,"ssh")
linus.sshd("success","Gaius",$userbase["Gaius"].ip)
#linus.sudo("success","crontab -e","dumbass","root")
#linus.sudo("success","bash","dumbass","root")
linus.useradd("haxx","0")
#
apachez=Apache.new()
$firewall.traffic($userbase["Gaius"].ip,apachez.ip,"ssh")
apachez.sshd("success","Gaius",$userbase["Gaius"].ip)

$userbase["Sulla"].useradd("Sulla","John","admin")
$userbase["Sulla"].usermod("Sulla","John",nil,626)
$userbase["Sulla"].login("John",534)


#apachez.shadow["test"]={:gid=>"234",:uid=>"324"}
#apachez.shadow["apache"]={:gid=>"8",:uid=>"30"}
#apachez.passwd("apache","234")s
#p "starting white noise"

#white_noise[:web]=Thread.new {apachez.white_noise }
#white_noise[:fw]=Thread.new {$firewall.white_noise}
#white_noise[:proxy]=Thread.new {bc_sg.white_noise}
#white_noise.values.join

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
p "sleeping for 360 before stopping the thread"
sleep 360
$all_normal=false
p "program over"
#sleep 15
#puts "killing the fw white noise"
#white_noise[:fw].terminate

