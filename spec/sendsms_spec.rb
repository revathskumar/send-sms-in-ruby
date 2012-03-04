$: << "."
require 'spec_helper'
require 'sendsms'


describe SendSms, "send SMS via way2sms" do

  ####################################################################################
  #                         Substitute the VALID CREDENTIALS and                     #
  #                         uncomment the commented tests to run                     #
  #                         the whole tests                                          #
  ####################################################################################

  let(:sms) { SendSms.new '9995436867','123456'}

  it "should respond to login, send, send_to_many, logout" do
    sms.should respond_to :login
    sms.should respond_to :send
    sms.should respond_to :send_to_many
    sms.should respond_to :logout
  end

  it "should fail to login attempt" do
    sms.password = '123456'
    sms.login.should == {:success => false,:message => "Login failed"}
  end

  it "should set the headers" do
    sms.__send__(:set_header).should == {"Cookie" => nil , "Referer" => nil ,"Content-Type" => "application/x-www-form-urlencoded",
      "User-Agent" => "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.3) Gecko/20091020 Ubuntu/9.10 (karmic) Firefox/3.5.3 GTB7.0" }
    sms.__send__(:set_header,"test_cookie",'test_referer').should == {"Cookie" => 'test_cookie' , "Referer" => 'test_referer' ,"Content-Type" => "application/x-www-form-urlencoded",
      "User-Agent" => "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.3) Gecko/20091020 Ubuntu/9.10 (karmic) Firefox/3.5.3 GTB7.0" }
  end

  it "should validate msisdn" do
    sms.__send__(:validate,"903786420").should == {:success => false,:message => "Invalid Msisdn"}
    sms.__send__(:validate).should == {:success => false,:message => "Invalid Msisdn"}
    sms.__send__(:validate,"9037864203").should == {:success => true,:message => "Valid Msisdn",:msisdn => '9037864203'}
    sms.__send__(:validate,"+919037864203").should == {:success => true,:message => "Valid Msisdn",:msisdn => '9037864203'}
    sms.__send__(:validate,"919037864203").should == {:success => true,:message => "Valid Msisdn",:msisdn => '9037864203'}
    sms.__send__(:validate,"00919037864203").should == {:success => true,:message => "Valid Msisdn",:msisdn => '9037864203'}
  end

  it "should not send sms without logging in" do
    sms.password = "123456"
    sms.send('9995436867', 'Testing Ruby!!').should == {:success => false,:message => "Login failed"}
  end

  it "should give invalid login if u try to send sms with wrong credentials" do
    sms.password = "123456"
    sms.send_to_many('9995436867;9037864203;9037107542', 'Testing Ruby!!').should == {:success => false,:message => "Login failed"}
  end

  it "successfully logged out" do 
    sms.logout.should == {:success => true,:message => "Logout successfully"}
  end

#  it "should login successfully" do
#    sms.login.should == {:success => true,:message => "Login successfully"}
#  end
#
#  it "should send SMS to individual" do
#    sms.login
#    sms.send('9995436867', 'should send SMS to individual').should == {:success => true,:message => "Send successfully"}
#  end
#
#  it "send method should accept an array of msisdn" do
#    sms.send(["9995436867","9037864203","9037107542"],"Testing Ruby.......array").should == {"9995436867" => {:success => true,:message => "Send successfully"},
#      "9037864203" => {:success => true,:message => "Send successfully"},
#      "9037107542" => {:success => true,:message => "Send successfully"}}
#  end
#
#  it "send method should accept semicolon seperated msisdns" do
#    sms.send("9995436867;9037864203;9037107542","send method should accept semicolon seperated msisdns").should == {"9995436867" => {:success => true,:message => "Send successfully"},
#      "9037864203" => {:success => true,:message => "Send successfully"},
#      "9037107542" => {:success => true,:message => "Send successfully"}}
#  end
#
#  it "send method should accept an Hash of msisdn" do
#    msisdn = { 0 => "9995436867", 1 => "9037864203" , 2 => "9037107542"}
#    sms.send(msisdn,"send method should accept an Hash of msisdn").should == {"9995436867" => {:success => true,:message => "Send successfully"},
#      "9037864203" => {:success => true,:message => "Send successfully"},
#      "9037107542" => {:success => true,:message => "Send successfully"}}
#  end
#
#  it "should send SMS to group" do
#    sms.login
#    sms.send_to_many('9995436867;9037864203;9037107542', 'send to many method should accept semicolon seperated msisdns').should == {"9995436867" => {:success => true,:message => "Send successfully"},
#    "9037864203" => {:success => true,:message => "Send successfully"},
#    "9037107542" => {:success => true,:message => "Send successfully"}}
#  end

end
