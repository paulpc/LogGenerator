require_relative 'sources.rb' 
require_relative 'apache.rb'
require_relative 'sys_log.rb'
include Sources

linus=Syslog.new("linux_1")
linus.boot
#linus.sshd("restart")
#linus.sshd("bad user","dumbass","192.168.99.98")
#linus.sshd("success","dumbass","192.168.99.98")
#linus.sudo("success","crontab -e","dumbass","root")
#linus.sudo("success","bash","dumbass","root")
#linus.useradd("test_user","0")
apachez=Apache.new()
apachez.sshd("success","root","127.0.0.1")
#apachez.shadow["test"]={:gid=>"234",:uid=>"324"}
#apachez.shadow["apache"]={:gid=>"8",:uid=>"30"}
#apachez.passwd("apache","234")s
