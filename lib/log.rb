# To change this template, choose Tools | Templates
# and open the template in the editor.

module Log
    #log everything either out in a file
    # multiple files
    # the screen
    # the network
     def log(message)
      if $log_file.class==String
        File.open($log_file,"a+") {|logfile|
          logfile. print(message+"\r\n")
        }
      elsif $log_file.class == Hash
        # logging for multiple files. Will use the sender class names to separate the logs
        p self.class.name.split("::").last
        File.open("./output/#{$log_file[self.class.name.split("::").last]}","a+") {|logfile|
          logfile. print(message+"\r\n")
        }
      else
        print(message+"\r\n")
      end
    
     end
     
end
