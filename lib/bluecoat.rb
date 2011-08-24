
module Sources
  class BluecoatSG
    def initialize(host="BlueCoatProxy_"+rand(999999).to_s.rjust(6,"0"))
      @host=host
      if $firewall
        @ip=$firewall.assign("DMZ")
      else
        @ip= "192.168.1."+(17+rand(30)).to_s
      end
      # the categories present here are just a small sample (and they are not even using the Blue Coat categorization engine
      @categories={}
      #start_time=get_time
      File.open( './config/categories.yml' ) { |yf| @categories=YAML::load( yf ) }
      #p "finished readind categories in #{(get_time()-start_time).to_i} seconds"
      @blacklist={}
      File.open( './config/blacklist.yml' ) { |yf| @blacklist=YAML::load( yf ) }
      @status_actions={"200"=>"TCP_NC_MISS","401"=>"TCP_DENIED","307"=>"TCP_AUTH_REDIRECT","302"=>"TCP_AUTH_REDIRECT","403"=>"CONTENT_FILTER_DENIED","304"=>"TCP_HIT"}
    end
    

    
    # in order to analyze the traffic, we will figure out if the destination belongs in any categories already defined, and if not, we will place them in an unknown category and allow it
    # also, we will check the category(ies) against the blacklist applicable to the user
    def analize_traffic(user,dest)      
      group="-"
      cat_app=[]
      @categories.each {|category,values|
        values.each {|domain|
          cat_app.push(category) if dest.include?(domain)
        }
      }
      cat_app.uniq!
      host=dest.split("/").first
      path,query=dest.reverse.chomp(host.reverse).reverse.split("?")
      path="/" unless path
      query= "-" unless query
      if $directory[user]
      potential_groups=$directory[user]
      blacklist_applicable=[]
      potential_groups.each {|po_gr|
        if not blacklist_applicable.empty? and @blacklist[po_gr]
          blacklist_applicable=@blacklist[po_gr]
          group=po_gr
        end      
      }
      group=potential_groups.first if group == "-"
      blacklisted=nil
      blacklist_applicable.each {|category|
        blacklisted=category if cat_app.include?(category)
      }
      
      if blacklisted
        filter_result="DENIED"
        exception_id="content_filter_denied"
        status="403"
      else 
        filter_result="OBSERVED"
        exception_id="-"
        status="200"
      end
      else
        group="-"
        user="-" 
        filter_result="DENIED"
        exception_id="authentication_failed"        
        status="401"
      end
      cat_app.push("unknown") if cat_app.empty?
      return {:user=>user, :group=>group, :categories=>cat_app, :filter_result=>filter_result, :exception_id=>exception_id, :status=>status, :host=>host, :path=>path, :query=>query}
    end
    
    def web_traffic(source,  dest, user_name="-", referer="-")
      analysis=analize_traffic(user_name,dest)
      if dest =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
        dest_ip=dest.scan(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/).flatten.first
      else
        dest_ip=rand_ip()
      end
      $firewall.traffic(source,dest_ip,"http")
      log("#{get_time().strftime("%Y-%m-%d %H:%M:%S")} #{rand(16)} #{source} #{analysis[:user]} #{analysis[:group]} #{analysis[:exception_id]} #{analysis[:filter_result]} \"#{analysis[:categories].join(",")}\" #{referer} #{analysis[:status]} #{@status_actions[analysis[:status]]} GET text/xml;%20charset=UTF-8 http #{analysis[:host]} 80 #{analysis[:path]} #{analysis[:query]} - #{user_agent("ie","windowsXP")} #{@ip} #{rand(256)} #{rand(2560)} - \"none\" \"none\"")  
    end    
    
    #logs a user into the appliance
    def login(success=true,src_ip=$firewall.assign("Trust",true),user="root")
      if success
      log_admin("\"Administrator login from #{src_ip}, user '#{user}'\"  0 25001E:96   authconsole.cpp:278")
      log_admin("\"Read/write mode entered from #{src_ip} for user '#{user}'\"  0 25001F:96   authconsole.cpp:248")
      else
        log_admin("Console user password authentication from #{src_ip} failed for user '#{user}' 0 NORMAL_EVENT authconsole.cpp 177")
      end
    end
    
    def log_admin(message)      
      log("#{get_time().strftime("%Y-%m-%d %H:%M:%S%z%Z")}  #{message}")
    end
    
    # creating whitenoise by picking a random url to generate the traffic, as well as a random user from the pool of users
    def white_noise
      urls={}
      #make sure to not break the user/computer combinations once you set usernames to computers. May even consider settign the source as a symbol to the computer name
      File.open( './config/urls.yml' ) { |yf| urls=YAML::load( yf ) }
      blacklist=@blacklist.values.flatten.uniq
      urls.keys.each {|list|
        urls[list]=nil if blacklist.include?(list)
      }
      urls_array=urls.values.flatten.uniq
      urls=nil
      while $all_normal
        dest=urls_array.sample 
        user=$userbase.keys.sample
        source_ip=$user_base[user].ip
        web_traffic(source_ip,dest,user)
        sleep(rand(2))
      end
    end  
  end



end
