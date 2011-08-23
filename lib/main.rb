require_relative 'sources.rb' 
#require_relative 'apache.rb'
#require_relative 'sys_log.rb'
include Sources
#set starting time for the event within the Time.new()
$time_diff=Time.new(2011,10,17,0,0,0,"-05:00")-Time.now

$firewall=Firewall.new()
#white_noise={}
#linus=Syslog.new("linux_1")
#linus.boot
#linus.sshd("restart")
#linus.sshd("bad user","dumbass","192.168.99.98")
#linus.sshd("success","dumbass","192.168.99.98")
#linus.sudo("success","crontab -e","dumbass","root")
#linus.sudo("success","bash","dumbass","root")
#linus.useradd("test_user","0")
#
#apachez=Apache.new()
#apachez.sshd("success","root","127.0.0.1")
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

computer=$firewall.dhcp("aa54231df2cc")
#sleep 15
#puts "killing the fw white noise"
#white_noise[:fw].terminate

bc_sg=BluecoatSG.new()
bc_sg.web_traffic(computer, "distillery.wistia.com/crossdomain.xml","Gaius")
bc_sg.login(false,computer)
bc_sg.login(true,computer)