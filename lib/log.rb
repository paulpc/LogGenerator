# To change this template, choose Tools | Templates
# and open the template in the editor.

module Log
     def log(message)
      if $log_file
        File.open($log_file,"a+") {|logfile|
          logfile.puts message
        }
      else
        puts(message)
      end
    
     end
     
end
