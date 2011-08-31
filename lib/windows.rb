# To change this template, choose Tools | Templates
# and open the template in the editor.

module Sources
  class Windows
    attr_reader :ip,:mac,:host, :localusers, :logged_in_user
    def initialize(host="agency_win_"+rand(999999).to_s.rjust(6,"0"))
      @host=host
      @mac=rand(281474976710655).to_s(16)
      @ip=($firewall.dhcp("Trust") if $firewall) || "192.168.4."+rand(255).to_s
      @localusers={"Administrator"=>["Administrators"]}
      @passwd={"Administrator"=>get_time()-33*24*60*60}
      @logged_in_user=nil
      ib=Thread.new {idle_browsing()}
      ib.run
      
    end
  
    # adds another local user.  Use with the last parameter of "admin" in order to add an administrative user
    def useradd(user,target_user,role="user")
      @localusers[target_user]=[]
      usermod(user,target_user,nil,624)    
      if role=="admin"
        usermod(user,target_user,"Administrators",636)
      end
      usermod(user,target_user,nil,628)
    end

    # browse the interwebs for a certain site
    def browse_web(site)
      $servers[:bc_sg].web_traffic(@ip,@logged_in_user,site)
    end
    
    #generates idle browsing for the user while the object exists
    def idle_browsing()
      while $all_normal
        sleep rand(120)
        $servers[:bc_sg].web_traffic(@ip,@logged_in_user)       
      end
    end
        
    # initiates deletion of useraccount [target_user] by [user]
    def userdel(user, target_user)
      group=@localusers[target_user].to_a.first || $directory[target_user].to_a.first || "Users"
      usermod(user,target_user,group,630)      
    end

    # base procedure to operate with user and group objects
    # performs different actions based on the event_id
    #   624 - creates the account [target_user]
    #   642 - changes the account [target_user]
    #   626 - enables the account [target_user]
    #   630 - deletes the account [target_user]
    #   632 - adds [target_user] to the domain group [group] - automatically turned local if the domain group does not exist
    #   633 - removes [target_user] from the domain group [group] - automatically turned local if the domain group does not exist
    #   636 - adds [target_user} to local group [group]
    #   637 - removes [target_user] from local group [group]
    # see: http://www.microsoft.com/technet/support/ee/transform.aspx?ProdName=Windows+Operating+System&ProdVer=5.2&EvtID=[event_id]&EvtSrc=Security for more details on specific a [event_id]
    def usermod(user,target_user, group, event_id=642, target_user_name=target_user)
      if @localusers[user]
        caller_domain=@host
      else
        caller_domain=$domain_name
      end
      
      message={:event_id=>event_id,:event_type=>8,:event_category=>7,:record_number=>rand(1000)+300, :time_generated=>get_time().to_i, :user=>user}
      if group and not $directory.values.flatten.uniq.include?(group) and [632,633].include?(event_id)
        message[:event_id]=message[:event_id]+4
      end
      
      case message[:event_id]
       when 624
        #user account created
        message[:message]="User Account Created:   New Account Name: #{target_user}   New Domain: #{@host}   New Account ID: #{@host}\\#{target_user}   Caller User Name:  #{user}  Caller Domain: #{caller_domain}   Caller Logon ID: (0x0,0x#{rand(1048575).to_s(16)})   Privileges  -  "
      when 630
        # user account deleted
        message[:message]="User Account Deleted:   Target Account Name: #{target_user}   Target Domain: #{caller_domain}   Target Account ID: %{S-1-5-21-1060284298-1580436667-1343024091-#{rand(1000)+1000}}   Caller User Name: #{user}   Caller Domain: #{caller_domain}   Caller Logon ID: (0x0,0x#{rand(1048575).to_s(16)})   Privileges: -  "
        @localusers[target_user]=nil
      when 642
        #account changed
        message[:message]="User Account Changed:   -   Target Account Name: #{target_user}   Target Domain: #{@host}   Target Account ID: #{@host}\\#{target_user}   Caller User Name: #{user}   Caller Domain: #{caller_domain}   Caller Logon ID: (0x0,0x#{rand(1048575).to_s(16)})   Privileges: -  Changed Attributes:   Sam Account Name: #{target_user}   Display Name: #{target_user_name}   User Principal Name: -   Home Directory: %%1793   Home Drive: %%1793   Script Path: %%1793   Profile Path: %%1793   User Workstations: %%1793   Password Last Set: #{get_time().strftime("%m/%d/%Y %I:%M:%S %p")}    Account Expires: %%1794   Primary Group ID: 513   AllowedToDelegateTo: -   Old UAC Value: 0x9B5D0   New UAC Value: 0x9B5D0   User Account Control: -   User Parameters: -   Sid History: -   Logon Hours: %%1792  "
      when 626
        #account enabled
        message[:message]="User Account Enabled:   Target Account Name: #{target_user}   Target Domain: #{@host}   Target Account ID: #{@host}\\#{target_user}   Caller User Name: #{user}   Caller Domain: #{caller_domain}   Caller Logon ID: (0x0,0x#{rand(1048575).to_s(16)})  "
      when 632
        #domain group member added
        message[:message]="Security Enabled Global Group Member Added:   Member Name: -   Member ID: #{@host}\\#{target_user}   Target Account Name: None   Target Domain: #{caller_domain}   Target Account ID: #{caller_domain}\\None   Caller User Name: #{user}   Caller Domain: #{caller_domain}   Caller Logon ID: (0x0,0x#{rand(1048575).to_s(16)})   Privileges: -  "
        $directory[target_user].to_a.push(group)
      when 633
        #global group member removed
        message[:message]="Security Enabled Global Group Member Removed:   Member Name: -   Member ID: #{@host}\\#{target_user}   Target Account Name: None   Target Domain: #{caller_domain}   Target Account ID: #{caller_domain}\\None   Caller User Name: #{user}   Caller Domain: #{caller_domain}   Caller Logon ID: (0x0,0x#{rand(1048575).to_s(16)})   Privileges: -  "
        $directory[target_user].delete(group)
      when 636
        # local group member added
        message[:message]="Security Enabled Local Group Member Added:   Member Name: -   Member ID: #{@host}\\#{target_user}   Target Account Name: #{group}   Target Domain: Builtin   Target Account ID: BUILTIN\\#{group}   Caller User Name: #{user}   Caller Domain: #{caller_domain}   Caller Logon ID: (0x0,0x#{rand(1048575).to_s(16)})   Privileges: -  "
        @localusers[target_user].push(group)
      when 637
        #local group member deleted
        message[:message]="Security Enabled Local Group Member Removed:   Member Name: -   Member ID: %{S-1-5-21-1060284298-1580436667-1343024091-#{rand(1000)+1000}}   Target Account Name: #{group}   Target Domain: Builtin   Target Account ID: BUILTIN\\#{group}   Caller User Name: #{user}   Caller Domain: #{caller_domain}   Caller Logon ID: (0x0,0x#{rand(1048575).to_s(16)})   Privileges: -  "
        @localusers[target_user].delete(group)
      when 628
        # setting the password for the user
        message[:message]="User Account password set:   Target Account Name: #{target_user}   Target Domain: #{@host}   Target Account ID: #{@host}\\#{target_user}   Caller User Name: #{user}   Caller Domain: #{caller_domain}   Caller Logon ID: (0x0,0x#{rand(1048575).to_s(16)})"
        @passwd[target_user]=get_time
      else
        raise "unknown event_id - #{message[:event_id]} - you might need to add the line to the code to process it"
      end
      security_log(message)
end 

    # login piece for windows workstations:
    # user stands for the username logging in. The function will check to see if the user exists in the domain
    # Logon types can be:
    #   2 – Interactive
    #   5 – Service
    #   10 – RemoteInteractive
    #   
    # the event_id for logins:
    #   528 - successful login
    #   529 - bad user / password
    #   593 - account locked out
    #   533 - user not allowed to logon the computer
    #   534 - user has not been granted the requested logon type at this machine
    def login(user, event_id=528, logon_type=2, source=@ip)
      message={:record_number=>rand(1000)+300, :time_generated=>get_time().to_i, :event_type=>16, :event_category=>2, :user=>user}
      #looking for users in the domain list. If the user is unknown to the domain, we'll get a bad password
      if ($directory.keys.flatten+@localusers.keys.flatten).include?(user)
        message[:event_id]=event_id
      else
        message[:event_id]=529
      end
      #if it is a remote login, setting the proper strings for it
      remote_login="  Caller User Name: #{@host}$   Caller Domain: #{$domain_name}   Caller Logon ID: (0x0,0x#{rand(1048575).to_s(16)})   Caller Process ID: 660   Transited Services: -   Source Network Address: #{source}   Source Port: 1037" if logon_type==10
      #looking at the different codes
      case message[:event_id]
      when 528
        # successful Login
        message[:event_type]=8
        message[:event_category]=2
        message[:message]="Successful Logon:   User Name: #{user}   Domain:  #{$domain_name}   Logon ID:  (0x0,0x#{rand(1048575).to_s(16)})   Logon Type: #{logon_type}   Logon Process: User32     Authentication Package: Negotiate   Workstation Name: #{@host}   Logon GUID: {00000000-0000-0000-0000-000000000000}#{remote_login}"
        @logged_in_user=user if logon_type==2 or logon_type==10
      when 529
        # Unknown user or bad password
        message[:message]="Logon Failure:   Reason:  Unknown user name or bad password   User Name: #{user}   Domain:  #{$domain_name}   Logon Type: #{logon_type}   Logon Process: User32     Authentication Package: Negotiate   Workstation Name: #{@host}#{remote_login}"
      when 593
        # Account locked out
        message[:message]="Logon Failure:   Reason:  Account locked out    User Name: #{user}   Domain:  #{$domain_name}   Logon Type: #{logon_type}   Logon Process: User32     Authentication Package: Negotiate   Workstation Name: #{@host}#{remote_login}"  
      when 534
        # The user has not been granted the requested logon type at this machine
        message[:message]="Logon Failure:   Reason:  The user has not been granted the requested logon type at this machine    User Name: #{user}   Domain:  #{$domain_name}   Logon Type: #{logon_type}   Logon Process: User32     Authentication Package: Negotiate   Workstation Name: #{@host}#{remote_login}"  
      when 533
        # User not allowed to logon at this computer
        message[:message]="Logon Failure:   Reason:  User not allowed to logon at this computer    User Name: #{user}   Domain:  #{$domain_name}   Logon Type: #{logon_type}   Logon Process: User32     Authentication Package: Negotiate   Workstation Name: #{@host}#{remote_login}"
      end            
      security_log(message)
    end
    
    def security_log(message)
      log("#{get_time().strftime("%b %d %H:%M:%S")} #{@ip} AgentDevice=WindowsLog    AgentLogFile=Security   Source=Security Computer=#{@host} User=#{message[:user]} Domain=#{$domain_name}        EventID=#{message[:event_id]}     EventIDCode=#{message[:event_id]} EventType=#{message[:event_type]}    EventCategory=#{message[:event_category]} RecordNumber=#{message[:record_number]}        TimeGenerated=#{message[:time_generated]}        TimeWritten=#{message[:time_generated]}  Message=#{message[:message]}")
    end
  end
end
