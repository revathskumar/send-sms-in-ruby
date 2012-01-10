require_relative 'spec_helper'
require 'way2sms'


describe Way2sms, "send SMS via way2sms" do

  let(:sms) { way2sms.new }

  it "should fail to login attempt" do
    sms.username = '9995436867'
    sms.password = '123456'
    sms.login
  end

  it "should login successfully" do


  end

  it "should accept only two params" do 

  end

  it "should accept either a group of numbers or a single msisdn" do 


  end


  it "should send SMS to individual" do

  end

  it "should accept send SMS to group" do


  end

  it "successfully logged out" do 


  end

end