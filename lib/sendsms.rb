#############################################################################
#                                                                           #
#    Copyright (C) 2012  Revath S Kumar                                     #
#                                                                           #
#    This program is free software: you can redistribute it and/or modify   #
#    it under the terms of the GNU General Public License as published by   #
#    the Free Software Foundation, either version 3 of the License, or      #
#    (at your option) any later version.                                    #
#                                                                           #
#    This program is distributed in the hope that it will be useful,        #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of         #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          #
#    GNU General Public License for more details.                           #
#                                                                           #
#    You should have received a copy of the GNU General Public License      #
#    along with this program.  If not, see <http://www.gnu.org/licenses/>   #
#                                                                           #
#############################################################################

require "net/http"
require "net/https"
require "uri"
require "hpricot"

#
# The class which handles sending sms with way2sms
#
# @author Revath S Kumar
#
class SendSms
  attr_accessor :username, :password

  # The way2sms root url
  URL = 'http://site6.way2sms.com'
 
  #
  # Initiate Sendsms class with way2sms username and password
  #
  # @param [String] username way2sms username
  # @param [String] password way2sms password
  # @param [true,false] auto_logout
  #   Set to logout after sending SMS. we don't need to call the logout explicitly
  #   Recommended to turn it off when you are sending SMS repeatedly
  #
  #
  def initialize(username , password ,auto_logout = true)
    @username = username
    @password = password
    @uri = URI.parse URL
    @cookie = @action = nil
    @referer = URL
    @auto_logout = auto_logout
    @http = Net::HTTP.new(@uri.host,@uri.port)
  end


  # Login to way2sms.com
  #
  # @visibility public
  # @return [json]
  #   A json response with status and message
  #     { :success => true, :message => "Login Successful" }
  #     { :success => false, :message => "Login Failed" }
  #
  def login
    data = "username=#{@username}&password=#{@password}"
    headers = set_header @cookie, @referer
    response = @http.post("/Login1.action",data,headers.delete_if {|i,j| j.nil? })
    case response.code
      when  /3\d{2}/
        if response['location'].include?("Main.action")
          @cookie ||= response['set-cookie']
          @referer ||= response['referer']
          @action = getAction
          return {:success => true,:message => "Login successfully"}
        end
        return {:success => false,:message => "Login failed"}
      else
        return {:success => false,:message => "Http Error"}
    end
  end

  #
  # To send Individual and Group SMS
  # This method support Group SMS from version 0.0.5
  #
  # @param [Mixed] msisdns
  #   The msisdn/msisdns to send the SMS
  #     Individual
  #       A single msisdn as String Eg: "9995436867"
  #     Group
  #       An array of msisdns
  #         Eg: ["9995436867","9037107542","9037864203"]
  #       An hash of msisdns
  #         Eg: {0 => "9995436867",1 => "9037107542",2 => "9037864203"}
  #       A semicolon(;) seperated string of msisdns
  #         Eg: "9995436867;9037107542;9037864203"
  # @param [String] message The message to send
  #
  # @visibility public
  # @return [json]
  #   A json response with status and message
  #     Individual
  #       {:success => true,:message => "Send successfull"}
  #       {:success => false,:message => "Send failed"}
  #     Group
  #       {
  #         "9995436867" => {:success => true,:message => "Send successfully"},
  #         "9037864203" => {:success => true,:message => "Send successfully"},
  #         "9037107542" => {:success => true,:message => "Send successfully"}
  #       }
  #
  def send msisdns,message
    if @cookie.nil?
      login_res = login
      return {:success => false,:message => "Login failed"} if !login_res[:success]
    end
    if msisdns.kind_of?(String) && !msisdns.include?(";")
      response = send_sms msisdns,message
      logout if @auto_logout
      return response
    else
      if msisdns.kind_of?(String) && msisdns.include?(";")
        msisdns = msisdns.split(';')
      end
      response = {}
      msisdns.each do | key, msisdn |
        msisdn = key if msisdn.nil?
        response[msisdn] = send_sms msisdn,message
      end
      logout if @auto_logout
      return response
    end
  end

  #
  # To send Group SMS
  #
  # @deprecated Use {#send} instead of this method
  # 
  #
  # @param [String] msisdns
  #   A semicolon seperated string of msisdns
  #   Eg: "9995436867;9037107542;9037864203"
  # @param [String] message The message to send
  #
  # @visibility public
  #
  # @return [json]
  #   A json response with status and message
  #     {
  #       "9995436867" => {:success => true,:message => "Send successfully"},
  #       "9037864203" => {:success => true,:message => "Send successfully"},
  #       "9037107542" => {:success => true,:message => "Send successfully"}
  #     }
  #
  #
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

  #
  # To logout the way2sms session
  #
  # @visibility public
  #
  # @return  [json]
  #   A json with status and message
  #     { :success => true,:message => "Logout successfully" }
  #
  #
  #
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

  private

  #
  # Method to fetch the unique identifier in the send sms form
  # @visibility private
  # @return [String]
  #   The unique identifier
  #
  def getAction
    headers = set_header @cookie, @referer
    response = @http.get("/jsp/InstantSMS.jsp",headers.delete_if {|i,j| j.nil? })
    hdoc = Hpricot(response.body)
    return (hdoc/"#Action").attr('value')
  end

  #
  # To set the Headers for each request
  #
  # @param [Sting] cookie
  #   The cookie which need to set
  # @param [String] referer
  #   The referer which need to set
  #
  # @visibility private
  # @return [Json] A json header
  #
  def set_header(cookie=nil,referer=nil)
    {"Cookie" => cookie , "Referer" => referer ,"Content-Type" => "application/x-www-form-urlencoded",
      "User-Agent" => "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.3) Gecko/20091020 Ubuntu/9.10 (karmic) Firefox/3.5.3 GTB7.0" }
  end

  #
  # To validate and format the msisdn passed by the user
  # Format the msisdn into 10 digit.
  # Accepted Formats
  #
  #   00919995436867
  #   +919995436867
  #   919995436867
  #   9995436867
  #
  # @param [String] msisdn
  #   The msisdn which need to validated
  #
  # @visibility private
  # @return [Json]
  #   A Json with status and message
  #
  def validate(msisdn = nil)
    result = /^(\+|00)?(91)?(9|8|7)[0-9]{9}$/.match(msisdn)
    return {:success => false,:message => "Invalid Msisdn"} if result.nil?
    msisdn_formated = result[0][-10..-1]
    return {:success => true,:message => "Valid Msisdn",:msisdn => msisdn_formated}
  end

  #
  # The method which post the msisdn, message and unique identifier to way2sms
  #
  # @param [String] msisdn
  #   A string of msisdn
  # @param [String] message
  #   A string of message
  #
  # @visibility private
  #
  # @return [HttpPost]
  #   The Http post object
  #
  #
  def send_sms msisdn,message
    headers = set_header @cookie, @referer
    data = "MobNo=#{msisdn}&textArea=#{message}&HiddenAction=instantsms&login=&pass=&Action=abfghst5654g"
    response = @http.post("/quicksms.action?custid=\"+custid+\"&sponserid=\"+sponserid+\"",data,headers.delete_if {|i,j| j.nil? })
    case response.code
      when  /2\d{2}/
        {:success => true,:message => "Send successfully"}
      else
        {:success => false,:message => "Sending failed"}
    end
  end
end