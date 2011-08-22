# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'csv'
CSV.open("exercise_2010.csv","r").each {|line|
  match = line.first.match(/^<(\d+)>(.+)$/)
  if match
    filename=match[1] || "misc"
    logline=match[2] || line.first
  else
    filename="misc"
      logline=line.first
  end

  File.open("./logs/#{filename}","a") {|logfile|
    logfile.puts(logline)
  }
}