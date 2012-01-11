require_relative 'spec_helper'
require 'way2sms'


describe Way2sms, "send SMS via way2sms" do

  let(:sms) { Way2sms.new '9995436867','123456'}

  it "should respond to login, set_header, send_sms" do
    sms.should respond_to :login
    sms.should respond_to :send_sms
    sms.should respond_to :set_header
  end

  it "should fail to login attempt" do
    sms.password = '123456'
    sms.login.should == {:success => false,:message => "Login failed"}
  end

  # it "should login successfully" do
  #   sms.login.should == {:success => true,:message => "Login successfully"}
  # end

  it "should accept only two params" do 

  end

  it "should accept either a group of numbers or a single msisdn" do


  end


  it "should send SMS to individual" do
    sms.login
    sms.send_sms('9995436867', 'Testing Ruby!!').should == {:success => true,:message => "Send successfully"}
  end

  it "should accept send SMS to group" do
    sms.login
    sms.send_to_group('9995436867;9037864203;9037107542', 'Testing Ruby!!').should == {:success => true,:message => "Send successfully"}
  end

  it "successfully logged out" do 


  end

end