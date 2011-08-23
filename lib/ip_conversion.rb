module IpConversion
  def to_hex(ip)
    hex_ip=""
    ip.split(".").each {|octet| hex_ip+=octet.to_i.to_s(16).rjust(2,"0")}
    return hex_ip.rjust(8,"0")
  end

  def big_int_to_hex(ip)
    hex_ip=""
    0.upto(3) {|oct_nr| hex_ip+=ip[oct_nr*3,3].to_i.to_s(16).rjust(2,"0") }
    return hex_ip.rjust(8,"0")
  end
  
  def  to_ip(hex)
    ip=[]
    0.upto(3) {|octet|  ip+=[hex[octet*2,2].to_i(16)] }
    return ip.join(".")
  end

  def get_range(start_ip,end_ip)
    start_i=to_hex(start_ip).to_i(16)
    end_i=to_hex(end_ip).to_i(16)
    range=end_i-start_i
    return{:netmask=>to_ip(("FFFFFFFF".to_i(16)-range).to_s(16)),:cidr=>32-Math.log2(range+1).to_i,:address_no=>range+1}
  end
  
  def in_range?(ip,range)
    ip_int=to_hex(ip).to_i(16)
    start_ip,cidr=range.split("/")
    start_int=to_hex(start_ip).to_i(16)
    end_int=start_int+2**(32-cidr.to_i)
    return true if ip_int>start_int and ip_int<end_int
  end
end

