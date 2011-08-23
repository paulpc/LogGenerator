# To change this template, choose Tools | Templates
# and open the template in the editor.

module Sources
class BluecoatSG
  def initialize(host)
    @host=host || "BlueCoatProxy_"+rand(999999).to_s.rjust(6,"0")      
    if $firewall
      @ip=$firewall.assign("DMZ")
    else
      @ip= "192.168.1."+(17+rand(30)).to_s
    end
    
  end
end
end
