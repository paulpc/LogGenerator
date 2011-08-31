require 'socket'

module Log
    #log everything either out in a file
    # multiple files
    # the screen
    # the network
     def log(message,filename=nil)
      if $log_file.class==String
        File.open($log_file,"a+") {|logfile|
          logfile. print(message+"\r\n")
        }
      elsif $log_file.class == Hash
        # logging for multiple files. Will use the sender class names to separate the logs
        #p self.class.name.split("::").last
        if filename
          File.open("./output/#{filename}","a+") {|logfile|
          logfile. print(message+"\r\n")
        }
        else
        File.open("./output/#{$log_file[self.class.name.split("::").last] || "misc.log"}","a+") {|logfile|
          logfile. print(message+"\r\n")
        }
        end
        elsif $log_file.class == Array
        $log_file.each {|host|
         network_log(host,message) 
        }
         
      else
        print(message+"\r\n")
      end
    
     end
     
     #sends loglines over the network
     def network_log(destination, message,port=514)
       TCPSocket.open(destination,port) {|s|
         s.puts message
       }       
     end
     
end
