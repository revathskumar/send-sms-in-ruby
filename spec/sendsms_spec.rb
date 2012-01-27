require_relative 'spec_helper'
require 'sendsms'


describe SendSms, "send SMS via way2sms" do

  ####################################################################################
  #                         Substitute the VALID CREDENTIALS and                     #
  #                         uncomment the commented tests to run                     #
  #                         the whole tests                                          #
  ####################################################################################

  let(:sms) { SendSms.new '9995436867','123456'}

  it "should respond to login, set_header, send_sms" do
    sms.should respond_to :login
    sms.should respond_to :send_sms
    sms.should respond_to :set_header
    sms.should respond_to :send
    sms.should respond_to :send_to_many
  end

  it "should fail to login attempt" do
    sms.password = '123456'
    sms.login.should == {:success => false,:message => "Login failed"}
  end

  it "should set the headers" do
    sms.set_header.should == {"Cookie" => nil , "Referer" => nil ,"Content-Type" => "application/x-www-form-urlencoded",
      "User-Agent" => "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.3) Gecko/20091020 Ubuntu/9.10 (karmic) Firefox/3.5.3 GTB7.0" }
    sms.set_header("test_cookie",'test_referer').should ==  {"Cookie" => 'test_cookie' , "Referer" => 'test_referer' ,"Content-Type" => "application/x-www-form-urlencoded",
      "User-Agent" => "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.3) Gecko/20091020 Ubuntu/9.10 (karmic) Firefox/3.5.3 GTB7.0" }
  end

  it "should validate msisdn" do
    sms.validate("903786420").should == {:success => false,:message => "Invalid Msisdn"}
    sms.validate.should == {:success => false,:message => "Invalid Msisdn"}
    sms.validate("9037864203").should == {:success => true,:message => "Valid Msisdn",:msisdn => '9037864203'}
    sms.validate("+919037864203").should == {:success => true,:message => "Valid Msisdn",:msisdn => '9037864203'}
    sms.validate("919037864203").should == {:success => true,:message => "Valid Msisdn",:msisdn => '9037864203'}
    sms.validate("00919037864203").should == {:success => true,:message => "Valid Msisdn",:msisdn => '9037864203'}
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

  # it "should login successfully" do
  #   sms.login.should == {:success => true,:message => "Login successfully"}
  # end

  # it "should send SMS to individual" do
  #   sms.login
  #   sms.send('9995436867', 'Testing Ruby!!').should == {:success => true,:message => "Send successfully"}
  # end

  # it "should send SMS to group" do
  #   sms.login
  #   sms.send_to_many('9995436867;9037864203;9037107542', 'Testing Ruby!!').should == {"9995436867" => {:success => true,:message => "Send successfully"},
  #   "9037864203" => {:success => true,:message => "Send successfully"},
  #   "9037107542" => {:success => true,:message => "Send successfully"}}
  # end

end