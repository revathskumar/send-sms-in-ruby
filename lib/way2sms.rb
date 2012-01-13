require "net/http"
require "net/https"
require "uri"

class Way2sms
  attr_accessor :username, :password

  URL = 'http://site6.way2sms.com'
 
  def initialize(username = "", password = "")
    @username = username
    @password = password
    @uri = URI.parse URL
    @cookie = nil
    @referer = URL
    @http = Net::HTTP.new(@uri.host,@uri.port)
  end

  def set_header(cookie=nil,referer=nil)
    {"Cookie" => cookie , "Referer" => referer ,"Content-Type" => "application/x-www-form-urlencoded",
      "User-Agent" => "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.3) Gecko/20091020 Ubuntu/9.10 (karmic) Firefox/3.5.3 GTB7.0" }
  end

  def validate(msisdn = nil)
    result = /^(\+|00)?(91)?(9|8|7)[0-9]{9}$/.match(msisdn)
    return {:success => false,:message => "Invalid Msisdn"} if result.nil?
    msisdn_formated = result[0][-10..-1]
    return {:success => true,:message => "Valid Msisdn",:msisdn => msisdn_formated}
  end

  def login
    data = 'username='+@username+'&password='+@password
    headers = set_header @cookie, @referer
    response = @http.post("/Login1.action",data,headers.delete_if {|i,j| j.nil? })
    case response.code
      when  /3\d{2}/
        if response['location'].include?("Main.action")
          @cookie ||= response['set-cookie']
          @referer ||= response['referer']
          return {:success => true,:message => "Login successfully"}
        end
        return {:success => false,:message => "Login failed"}
      else
        return "Http Error"
    end
  end

  def send_sms msisdn,message
    headers = set_header @cookie, @referer
    data = "MobNo=#{msisdn}&textArea=#{message}&HiddenAction=instantsms&login=&pass=&Action=abfghst5654g"
    return @http.post("/quicksms.action?custid=\"+custid+\"&sponserid=\"+sponserid+\"",data,headers.delete_if {|i,j| j.nil? })
  end

  def send msisdn,message
    if @cookie.nil?
      login_res = login
      return {:success => false,:message => "Login failed"} if !login_res[:success]
    end

    response = send_sms msisdn,message
    case response.code
      when  /2\d{2}/
        return {:success => true,:message => "Send successfully"}
      else
        return {:success => false,:message => "Sending failed"}
    end
  end

  def send_to_many msisdns, message
    if @cookie.nil?
      login_res = login
      return {:success => false,:message => "Login failed"} if !login_res[:success]
    end

    msisdns = msisdns.split(';')
    response = {}
    msisdns.each do | msisdn |
      response[msisdn] = send msisdn,message
    end
    return response
  end

  def logout
    response = @http.get("/jsp/logout.jsp");
    @cookie = nil
    case response.code
      when  /2\d{2}/
        return {:success => true,:message => "Logout successfully"}
      else
        return {:success => false,:message => "Logout failed"}
    end
  end
end