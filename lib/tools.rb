module Tools
  # will generate a mind map of the current environment
  
  def take_snapshot()
    @snapshots=[] unless @snapshots
    @snapshot.push({:domain_name=>$domain_name,:users=>$directory,:servers=>$servers, :firewall=>$firewall})
  end
  
  def diff()
    
  end
  
 def generate_child_node(text,position=nil)
    pos=" POSITION=\"#{position}\""   if position
        File.open(@filename,"a+") {|mm|
        mm.puts("<node CREATED=\"#{Time.now.to_i}#{rand(899)+100}\" ID=\"scenario_#{text.gsub(/[\.\ ]/,"_")}#{rand(3000)}\" MODIFIED=\"#{Time.now.to_i}#{rand(999)}\"#{position} TEXT=\"#{text}\"\/>")
      }
 end
 
 def generate_parent_node(text,position=nil, folded=nil)
        pos=" POSITION=\"#{position}\""   if position
        fold=" FOLDED=\"true\"" if folded
        File.open(@filename,"a+") {|mm|
        mm.puts("<node CREATED=\"#{Time.now.to_i}#{rand(899)+100}\" ID=\"scenario_#{text.gsub(/[\.\ ]/,"_")}#{rand(3000)}\" MODIFIED=\"#{Time.now.to_i}#{rand(999)}\"#{pos}#{fold} TEXT=\"#{text}\">")
      }
 end
 def close_parent_node
      File.open(@filename,"a+") {|mm|
        mm.puts("</node>")
      }   
 end
 
    def generate_mind_map(filename="./output/mm/scenario_start.mm")
      @filename=filename
      File.open(@filename,"w") {|mm|
        mm.puts("<map version=\"0.8.1\">")
      }
      # set the base node as the name of the domain
      generate_parent_node($domain_name)
      
      # generate the users
      generate_parent_node("Users","right")
      $directory.each {|user,groups|
        generate_parent_node(user)
        # write down groups
        generate_parent_node("Groups")
        groups.each {|group|
          generate_child_node(group)
        }
        close_parent_node
        
        # put down the email address:
        generate_parent_node("Email")
        generate_child_node($servers[:email].email_directory[user])
        close_parent_node
        
        # put down the machine the user is using
        generate_parent_node("Computer")
        generate_child_node($userbase[user].host)
        generate_child_node($userbase[user].ip)
        close_parent_node
        close_parent_node
      }
      close_parent_node
      
      # generate list of servers
      generate_parent_node("Servers","left")
      $servers.each {|name,server|
        generate_parent_node(name.to_s)
        generate_child_node(server.host)
        generate_child_node(server.ip)
        generate_child_node(server.class.to_s)
        if defined?(server.shadow) and server.shadow and not server.shadow.empty?
          generate_parent_node("Local Accounts")
          server.shadow.keys.each {|account|
            generate_child_node(account)
          }
          close_parent_node
        end
        if defined?(server.etc_group) and server.etc_group and not server.etc_group.empty?
          generate_parent_node("Local Groups")
          server.etc_group.values.each {|etc_group|
            generate_child_node(etc_group)
          }
          close_parent_node
        end
        if server.class.to_s == "Sources::Apache"
          generate_parent_node("sitemap")
          server.structure.each {|page|
            generate_child_node(page)
          }
          close_parent_node
        elsif server.class == Sources::BluecoatSG
          generate_parent_node("categories",nil,true)
          server.categories.keys.each {|cat_key|
            generate_child_node(cat_key)
          }
          close_parent_node
          generate_parent_node("blacklist")
          server.blacklist.each {|group,cat|
            generate_parent_node(group)
            cat.each{|c| generate_child_node(c)}
            close_parent_node
          }
          close_parent_node
        end
        close_parent_node
      }      
      close_parent_node
      
      #firewall settings
      generate_parent_node($firewall.host,"left")
      generate_child_node($firewall.ip)
      generate_parent_node("Zones")
      $firewall.zones.each {|zone,range|
        generate_parent_node(zone.to_s)
        generate_child_node(range)
        close_parent_node
      }
      close_parent_node
      generate_parent_node("Rules")
      $firewall.rule_set.each {|id,from,to,services|
        generate_parent_node(id.to_s)
          generate_parent_node("source")
            from.each{|source| generate_child_node(source)}
          close_parent_node
          generate_parent_node("destination")
            to.each {|dest| generate_child_node(dest)}
          close_parent_node
          generate_parent_node("service")
            services.each {|svc| generate_child_node(svc)}
          close_parent_node
        close_parent_node
      }
      close_parent_node      
      close_parent_node
      
           
      #close the main node
      close_parent_node
      File.open(@filename,"a+") {|mm|
        mm.puts("</map>")
      }
    end
end
