# To change this template, choose Tools | Templates
# and open the template in the editor.

module Sources
  class Mail < Syslog
   def initialize(host)
    @host=host || "mail_"+rand(999999).to_s.rjust(6,"0")      
            if $firewall
         @ip= $firewall.assign("DMZ")
        else
          @ip = "192.168.4."+(1+rand(253)).to_s
        end
      @mac=rand(280533990614619).to_s(16).rjust(12,"0")
      @ip.split(".").each {|octet| hex_ip+=[octet.to_i.to_s(16).rjust(2,"0")]}
      @ip_v6="fe80::221:9bff:#{hex_ip[0]+hex_ip[1]}:#{hex_ip[2]+hex_ip[3]}"
      @tty=rand(9)+1
      @shadow={}
      generate_agency_emails()
    end
    
   
   def generate_agency_emails()
     @email_directory={}
     $directory.keys.each {|employee|
       email="#{employee.gsub(/\s/,".").downcase}@#{$domain_name}.ok.gov"
       @email_directory[employee]=email
     }
   end
   
# log successful and unsuccessful emails receipts
   def log_received(sender={:host=>rand_domain("mail"),:ip=>rand_ip()},recipients=@email_directory.values.sample(4),accept=false)
      pid=rand(2000)+1000
      msgid="<#{(("a".."z").to_a+("0".."9").to_a).sample(12).join}-#{27000000+rand(99999)}-#{(("a".."z").to_a+("0".."9").to_a).sample(16).join}>"
      if accept
        syslog_log(get_time(),"sendmail[#{pid}]","p7PDobd7#{pid.rjust(6,"0")}: from=<#{sender[:mail]}>, size=#{rand(2039)}, class=0, nrcpts=1, msgid=<#{msgid}>, proto=ESMTP, daemon=MTA, relay=[#{sender[:ip]}]")
        syslog_log(get_time(),"sendmail[#{pid}]","p7PDobd7#{pid.rjust(6,"0")}: to=<#{recipient}>, delay=00:00:00, xdelay=00:00:00, mailer=esmtp, pri=122039, relay=#{@host}. [#{@ip}], dsn=2.0.0, stat=Sent (p7PDobd7#{pid.rjust(6,"0")} Message accepted for delivery)")
      else
        syslog_log(get_time(),"sendmail[#{pid}]","p79DwHsd00#{pid.rjust(6,"0")}: from=<#{sender[:mail]}>, size=#{rand(300)}, class=0, nrcpts=3, msgid=#{msgid}, proto=SMTP, daemon=MTA, relay=#{sender[:host]} [#{rand_ip()}]")
        recipients.each {|recipient| syslog_log(get_time(),"sendmail[#{pid}]", "p79DwHsd#{pid}: Milter delete: rcpt <#{recipient}>")}
        syslog_log(get_time(),"sendmail[#{pid}]","p79DwHsd#{pid.rjust(6,"0")}: Milter add: header: X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10432:5.4.6813,1.0.211,0.0.0000\n definitions=2011-08-09_05:2011-08-09,2011-08-08,1970-01-01 signatures=0")
        syslog_log(get_time(),"sendmail[#{pid}]","p79DwHsd#{pid.rjust(6,"0")}: Milter add: header: X-Proofpoint-Spam-Details: rule=spam policy=default score=100 spamscore=100 ipscore=0 suspectscore=0\n phishscore=38 bulkscore=100 adultscore=1 classifier=spam adjust=0\n reason=mlx engine=6.0.2-1012030000 definitions=main-1108090099")
        syslog_log(get_time(),"sendmail[#{pid}]","p79DwHsd#{pid.rjust(6,"0")}: Milter: data, discard")
        syslog_log(get_time(),"sendmail[#{pid}]","p79DwHsd#{pid.rjust(6,"0")}: discarded")
      end
      
    end
    
    # log successful and unsuccessful send emails
    def log_sent(recipient={:ip=>rand_ip(),:host=>rand_domain("mail")}, sender=@email_directory.values.sample, accept=false)
       pid=rand(2000)+1000
       msgid="<#{(("a".."z").to_a+("0".."9").to_a).sample(12).join}-#{27000000+rand(99999)}-#{(("a".."z").to_a+("0".."9").to_a).sample(16).join}>"
      if accept
        syslog_log(get_time(),"sendmail[#{pid}]","p79DwQkF#{pid.rjust(6,"0")}: from=<#{sender}>, size=#{rand(1500)}, class=0, nrcpts=1, msgid=<#{msgid}>, proto=ESMTP, daemon=MTA, relay=[#{@host}]")
        syslog_log(get_time(),"sendmail[#{pid}]","p79DwQkF#{pid.rjust(6,"0")}: to=<#{recipient[:mail]}>, delay=00:00:00, xdelay=00:00:00, mailer=esmtp, pri=121362, relay=#{recipient[:host]}. [#{recipient[:ip]}], dsn=2.0.0, stat=Sent (p79DwQkF#{pid.rjust(6,"0")} Message accepted for delivery)")

      else
        error_msg_pool=["451 Temporary recipient validation error", "Connection timed out with #{recipient[:host]}.","Name server: #{recipient[:host]}: host name lookup failure"]
        syslog_log(get_time(),"sendmail[#{pid}]","p7O1F0JB#{pid.rjust(6,"0")}: to=#{recipient[:mail]}, delay=1+12:33:58, xdelay=00:00:00, mailer=esmtp, pri=6780538, relay=#{recipient[:host]}., dsn=4.0.0, stat=Deferred: #{error_msg_pool.sample}")
      end
    end
  end
end
