# To change this template, choose Tools | Templates
# and open the template in the editor.

module Sources
     class Syslog
       attr_accessor :tty, :shadow
       def initialize(host=nil,ip=nil)
         #generating a random hostname for this computer if the hostname is not already there
        @host=host || "agency_linux_"+rand(999999).to_s.rjust(6,"0")    
        #make sure to check this IP and see that it is not already taken
        @ip=ip || "192.168.4."+(1+rand(253)).to_s
        hex_ip=[]
        @ip.split(".").each {|octet| hex_ip+=[octet.to_i.to_s(16).rjust(2,"0")]}
        @ip_v6="fe80::221:9bff:#{hex_ip[0]+hex_ip[1]}:#{hex_ip[2]+hex_ip[3]}"
        @tty=rand(9)+1
        @shadow={}
    end
    
    def syslog_log(date=nil, program=nil, message=nil)
    #Jul 31 23:46:16 linux-s55c /usr/sbin/cron[1937]: (CRON) bad username (/etc/cron.d/smolt)
    # log("#{date.strdtime("%b %e %H:%M:%S")} #{@host} #{program}: #{message}")
    log "#{date.strftime("%b %e %H:%M:%S")} #{@host} #{program}: #{message}"
  end
  
  def boot()
    
cookie=rand(2885934096)
  messages=[
    ["kernel","imklog 5.6.5, log source = /proc/kmsg started." ],
    ["rsyslogd",'[origin software="rsyslogd" swVersion="5.6.5" x-pid="920" x-info="http://www.rsyslog.com"] start'],
    ["kernel"," [   12.937508] microcode: CPU0 sig=0x6fd, pf=0x1, revision=0xa3"," [   12.984751] microcode: CPU1 sig=0x6fd, pf=0x1, revision=0xa3",
      "[   12.986559] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba","[   13.275330] microcode: CPU0 updated to revision 0xa4, date = 2010-10-02",
      "[   13.275706] microcode: CPU1 updated to revision 0xa4, date = 2010-10-02"," [   13.605884] ip6_tables: (C) 2000-2006 Netfilter Core Team","[   13.838693] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)",
      "[   13.876714] ip_tables: (C) 2000-2006 Netfilter Core Team"],
    ["polkitd[1049]","started daemon version 0.99 using authority implementation `local' version `0.99'"],
    ["SuSEfirewall2","Firewall rules set to CLOSE"],
    ["ifup","lo","lo","IP address: 127.0.0.1/8"," "," ","IP address: 127.0.0.2/8  ", "eth0      device: Intel Corporation 82566DM-2 Gigabit Network Connection (rev 02)"],
    [" kernel","[   16.121283] e1000e 0000:00:19.0: irq 41 for MSI/MSI-X","[   16.172075] e1000e 0000:00:19.0: irq 41 for MSI/MSI-X","[   16.172553] ADDRCONF(NETDEV_UP): eth0: link is not ready"], 
    ["ifup","   eth0    ", "IP address: #{@ip}/28", " "],
    ["SuSEfirewall2", "/var/lock/SuSEfirewall2.booting exists which means system boot in progress, exit."],
    ["kernel","Kernel logging (proc) stopped."],
    ["rsyslogd", '[origin software="rsyslogd" swVersion="5.6.5" x-pid="920" x-info="http://www.rsyslog.com"] exiting on signal 15.'],
    ["kernel","imklog 5.6.5, log source = /proc/kmsg started"],
    ["rsyslogd", '[origin software="rsyslogd" swVersion="5.6.5" x-pid="1564" x-info="http://www.rsyslog.com"] start'],
    ["auditd[1600]","Started dispatcher: /sbin/audispd pid: 1602"],
    ["audispd","priority_boost_parser called with: 4","audispd: max_restarts_parser called with: 10","No plugins found, exiting"],
    ["auditd[1600]","Init complete, auditd 2.0.5 listening for events (startup state disable)"],
    ["sm-notify[1618]","Version 1.2.3 starting"],
    ["sshd[1649]","Server listening on 0.0.0.0 port 22","Server listening on :: port 22"],
    ["kernel","[   17.578874] e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX/TX","[   17.578878] e1000e 0000:00:19.0: eth0: 10/100 speed: disabling TSO"," [  17.579312] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready", "[   18.360923] BIOS EDD facility v0.16 2004-Jun-25, 1 devices found"],
    ["avahi-daemon[1756]","Found user #'avahi' (UID 104) and group 'avahi' (GID 106).","Successfully dropped root privileges.", "avahi-daemon 0.6.28 starting up.", "Loading service file /etc/avahi/services/sftp-ssh.service.", "Loading service file /etc/avahi/services/ssh.service.",
      "Loading service file /etc/avahi/services/udisks.service.", "Joining mDNS multicast group on interface eth0.IPv4 with address #{@ip}.", "New relevant interface eth0.IPv4 for mDNS.","Network interface enumeration completed.",
      "Registering new address record for #{@ip_v6} on eth0.","Registering new address record for #{@ip} on eth0.IPv4.", "Registering HINFO record with values #'X86_64'/'LINUX'."],
    ["avahi-daemon[1756]","Server startup complete. Host name is #{@host}.local. Local service cookie is #{cookie}."],
    ["acpid","1 client rule loaded"],
    ["avahi-daemon[1756]","Service \"#{@host}\" (/etc/avahi/services/udisks.service) successfully established.","Service \"#{@host}\" (/etc/avahi/services/ssh.service) successfully established.","Service \"#{@host}\" (/etc/avahi/services/sftp-ssh.service) successfully established."],
    ["ntpd[2110]","ntpd 4.2.6p3@1.2290 Tue Jun  7 03:07:00 UTC 2011 (1)","proto: precision = 0.116 usec","ntp_io: estimated max descriptors: 1024, initial socket boundary: 16","Listen and drop on 0 v4wildcard 0.0.0.0 UDP 123","Listen and drop on 1 v6wildcard :: UDP 123",
      "Listen normally on 2 lo 127.0.0.1 UDP 123","Listen normally on 3 lo 127.0.0.2 UDP 123","Listen normally on 4 eth0 #{@ip} UDP 123","Listen normally on 5 eth0 #{@ip_v6} UDP 123","Listen normally on 6 lo ::1 UDP 123", "peers refreshed"],
    ["acpid","1 client rule loaded"],
    ["sssd","Starting up"],
    ["sssd[be[default]]","Starting up"],
    ["sssd[pam]","Starting up"],
    ["sssd[nss]","Starting up"],
    ["/usr/sbin/cron[2307]","(CRON) STARTUP (1.4.7)","(CRON) bad username (/etc/cron.d/smolt)","(CRON) INFO (running with inotify support)"],
    ["smartd[2308]","smartd 5.40 2010-10-16 r3189 [x86_64-unknown-linux-gnu] (SUSE RPM)#012Copyright (C) 2002-10 by Bruce Allen, http://smartmontools.sourceforge.net#012",
      "Opened configuration file /etc/smartd.conf","Drive: DEVICESCAN, implied #'-a' Directive on line 26 of file /etc/smartd.conf","Configuration file /etc/smartd.conf was parsed, found DEVICESCAN, scanning devices",
      "Device: /dev/sda, type changed from #'scsi' to 'sat'","Device: /dev/sda [SAT], opened","Device: /dev/sda [SAT], found in smartd database.","Device: /dev/sda [SAT], is SMART capable. Adding to \"monitor\" list.",
      "Device: /dev/sda [SAT], state read from /var/lib/smartmontools/smartd.WDC_WD800JD_75MSA3-WD_WMAM9CZT2081.ata.state"," Monitoring 1 ATA and 0 SCSI devices","Device: /dev/sda [SAT], state written to /var/lib/smartmontools/smartd.WDC_WD800JD_75MSA3-WD_WMAM9CZT2081.ata.state",
      "smartd has fork()ed into background mode. New PID=2325"],
    ["SuSEfirewall2","Setting up rules from /etc/sysconfig/SuSEfirewall2 ...","SuSEfirewall2: Firewall rules successfully set"],
    ["kernel", "[   27.447566] bootsplash: status on console 0 changed to on","[   27.714004] eth0: no IPv6 routers present"],
    ["rtkit-daemon[4196]","Sucessfully called chroot.","Sucessfully dropped privileges","Sucessfully limited resources.","Running.","Canary thread running.","Watchdog thread running."] ]
   messages.each {|process|
     proc_name=process.delete_at(0)
     process.each {|message|
       syslog_log(Time.now,proc_name,message)
     }
     sleep(rand(3))
   }
   if self.respond_to?(:specialized_boot)
    self.method(:specialized_boot).call
  end
  end

  def shutdown(command="halt")

  if command=="halt"
    messages=messages=[["shutdown[9801]","shutting down for system halt"],
    ["init","Switching to runlevel: 0"]]
  elsif commmand=="reboot"
    messages=[["shutdown[9801]","shutting down for system reboot"],
    ["init","Switching to runlevel: 6"]]
  end

  messages+=[
    ["kernel","[ 6580.678155] bootsplash: status on console 0 changed to on"],
    ["avahi-daemon[1579]","Got SIGTERM, quitting.","avahi-daemon 0.6.28 exiting."],
  ["smartd[1981]","smartd received signal 15: Terminated","Device: /dev/sda [SAT], state written to /var/lib/smartmontools/smartd.WDC_WD800JD_75MSA3-WD_WMAM9CZT2081.ata.state","smartd is exiting (exit status 0)"],
  ["sssd[pam]","Shutting down"],
  ["sssd[nss]","Shutting down"],
  ["sssd[be[default]]","Shutting down"],
  ["network","Shutting down the NetworkManager"],
  ["auditd[1302]","The audit daemon is exiting."],
  ["rtkit-daemon[3646]","Exiting cleanly.","Demoting known real-time threads.","Demoted 0 threads.","Exiting watchdog thread.","Exiting canary thread."],
  ["rpcbind", "rpcbind terminating on signal. Restart with \"rpcbind -w\""],
  ["kernel","Kernel logging (proc) stopped."],
  ["rsyslogd","[origin software=\"rsyslogd\" swVersion=\"5.6.5\" x-pid=\"1266\" x-info=\"http://www.rsyslog.com\"] exiting on signal 15."]  ]
  
    messages.each {|process|
     proc_name=process.delete_at(0)
     process.each {|message|
       syslog_log(Time.now,proc_name,message)
     }
     sleep(rand(3))
   }

  end


    def sshd(command="restart",user=nil,source=nil)
            pid=10000+rand(10000)
      #emulating the sshd log. Planning
      case command
      when "restart"
      messages=["Received signal 15; terminating.","Server listening on 0.0.0.0 port 22.","sshd[11819]: Server listening on :: port 22."]
      when "stop"
        messages=["Received signal 15; terminating."]
      when "start"
        mesasges=["Server listening on 0.0.0.0 port 22.","sshd[11819]: Server listening on :: port 22."]
        when "bad user"
          messages=["Invalid user #{user} from #{source}","error: PAM: User not known to the underlying authentication module for illegal user #{user} from #{source}","Failed keyboard-interactive/pam for invalid user #{user} from #{source} port 55221 ssh2",
            "error: PAM: User not known to the underlying authentication module for illegal user #{user} from #{source}","Failed keyboard-interactive/pam for invalid user #{user} from #{source} port 55221 ssh2",
            "error: PAM: User not known to the underlying authentication module for illegal user #{user} from #{source}","Failed keyboard-interactive/pam for invalid user #{user} from #{source} port 55221 ssh2"]
      when "bad password"
        messages=["pam_ldap: error trying to bind as user \"uid=#{user},ou=People,dc=agency,dc=ok,dc=gov\" (Invalid credentials)","error: PAM: Authentication failure for #{user} from #{source}",
          "pam_ldap: error trying to bind as user \"uid=#{user},ou=People,dc=agency,dc=ok,dc=gov\" (Invalid credentials)","error: PAM: Authentication failure for #{user} from #{source}",
          "pam_ldap: error trying to bind as user \"uid=#{user},ou=People,dc=agency,dc=ok,dc=gov\" (Invalid credentials)","error: PAM: Authentication failure for #{user} from #{source}"]
      when "success"
        messages=["Accepted keyboard-interactive/pam for #{user} from #{source} port 40632 ssh2"]
      when "disconnect"
        mesages=["Received disconnect from #{source}: 11: disconnected by user"]
      end
                messages.each {|message| syslog_log(Time.now,"#{__method__}[#{pid}]",message)} unless messages.to_a.empty?
      
    end
    
    
    def sudo(status="success",command="su -",user="test",target="root")
      arguments=command.split(" ")
      comm_only=arguments.delete_at(0)
      comm_path=`which #{comm_only}`.strip
       if comm_path==""
         comm_path=command
       else
         comm_path+=" "+arguments.join(" ")
       end
      case status
      when "success"
        messages=[":     #{user} : TTY=pts/#{@tty} ; PWD=/home/#{user} ; USER=#{target} ; COMMAND=#{comm_path}"]
      when "failure"
        messages=["     #{user} : 3 incorrect password attempts ; TTY=pts/#{@tty} ; PWD=/home/#{user} ; USER=#{target} ; COMMAND=#{comm_path}"]
      end
    messages.each {|message| syslog_log(Time.now,__method__,message)} unless messages.to_a.empty?
    if self.respond_to?(comm_only) and status == "success"
      self.send(comm_only.to_sym, status, arguments.join(" "),user, target)
    end
    end
    
    def su(status="failure",command="-",user="test",target="root")
      case status
    when "failure"
      messages=["FAILED SU (to #{target}) #{user} on /dev/pts/#{@tty}"]
    when "success"
        messages=["(to #{target}) #{user} on /dev/pts/#{@tty}"]
    end
    messages.each {|message| syslog_log(Time.now,__method__,message)} unless  messages.to_a.empty? 
    end
    
    def crontab(status="success",command="-l",user="test",target="root")
            pid=10000+rand(10000)
      case command
      when "-l"
        messages=["(#{target}) LIST (#{target})"]
      when "-e"
        messages=["(#{target}) BEGIN EDIT (#{target})","(#{target}) REPLACE (#{target})","(#{target}) END EDIT (#{target})"]
      end
          messages.each {|message| syslog_log(Time.now,"#{__method__}[#{pid}]",message)} unless messages.to_a.empty?
    end
       
    def useradd(account="test",gid="33",user="0")
      uid=rand(2000)+30000
      pid=10000+rand(10000)
      messages=["new account added - account=#{account}, uid=#{uid}, gid=#{gid}, home=/home/#{account}, shell=/bin/bash, by=#{user}",
      "account added to group - account=test, group=users, gid=100, by=#{user}",
      "running USERADD_CMD command - script=/usr/sbin/useradd.local, account=#{account}, uid=#{uid}, gid=#{gid}, home=/home/#{account}, by=#{user}"
      ]
      @shadow[account]={:gid=>gid, :uid=>uid}
    messages.each {|message| syslog_log(Time.now,"#{__method__}[#{pid}]",message)} unless messages.to_a.empty?  
    end
    
    def usermod(account="test",gid="100",user="0")
      pid=10000+rand(10000)
      messages=["default group changed - account=#{account}, uid=#{@shadow[account][:uid]}, gid=#{gid}, old gid=#{@shadow[account][:gid]}, by=#{user}"]  
     @shadow[account][:gid]=gid
     messages.each {|message| syslog_log(Time.now,"shadow[#{pid}]",message)} unless messages.to_a.empty?  
    end
    
    def userdel(account="test",user="0")

      pid=10000+rand(10000)
      
      mesages=[
        ["shadow[#{pid}]","running USERDEL_PRECMD command - script=/usr/sbin/userdel-pre.local, account=#{account}, uid=#{@shadow[account][:uid]}}, gid=#{@shadow[account][:gid]}}, home=/home/#{account}, by=#{user}"],
        ["/usr/bin/crontab[#{pid+rand(4)}]","(root) DELETE (#{account})"],
        ["shadow[#{pid}]","account removed from group - account=#{account}, group=users, gid=100, by=#{user}"],
        ["shadow[#{pid}]","account deleted - account=#{account}, uid=#{@shadow[account][:uid]}}, by=#{user}"],
        ["shadow[#{pid}]","running USERDEL_POSTCMD command - script=/usr/sbin/userdel-post.local, account=#{account}, uid=#{@shadow[account][:uid]}}, gid=#{@shadow[account][:gid]}}, home=/home/#{account}, by=#{user}"]
        ]
             messages.each {|program,message| syslog_log(Time.now,program,message)} unless messages.to_a.empty?  
    end
    
    def passwd(account="test",user=nil)
      pid=10000+rand(10000)
      if user
        if user != "0"
          messages=["password change denied - account=#{account}, uid=#{@shadow[account][:uid]}, by=#{user}","#{user} cannot change shadow data for `#{account}'"]
          else
            messages=["gkr-pam: couldn't update the login keyring password: no old password was entered","password changed - account=#{account}, uid=#{@shadow[account][:uid]}, by=#{user}"]
        end
      else
        messages=["gkr-pam: couldn't change password for the login keyring.","password changed - account=#{account}, uid=#{@shadow[account][:uid]}, by=#{@shadow[account][:uid]}"]
      end    
      messages.each {|message| syslog_log(Time.now,"#{__method__}[#{pid}]",message)} unless messages.to_a.empty?  
    end
    
    def mark()
      #Jul 15 21:05:59 linux-s55c rsyslogd: -- MARK --
      syslog_log(Time.now,host,"rsyslogd"," -- MARK --")
    end
    
     end
end
