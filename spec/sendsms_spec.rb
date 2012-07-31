$: << "."
require 'spec_helper'
require 'sendsms'


describe SendSms, "send SMS via way2sms" do

  subject { SendSms.new "9995012345", '123456' }

  before(:each) do
    stub_request(:post, "http://site6.way2sms.com/Login1.action")
    .with(
      body: {"password"=>"123456", "username"=>"9995012345"},
      headers: {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'Referer'=>'http://site6.way2sms.com', 'User-Agent'=>'Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.3) Gecko/20091020 Ubuntu/9.10 (karmic) Firefox/3.5.3 GTB7.0'})
    .to_return(
      body: {},
      headers: {location: ""},
      status: 302
    )

    stub_request(:post, "http://site6.way2sms.com/Login1.action")
    .with(
      body: {"password"=>"654321", "username"=>"9995012345"},
      headers: {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'Referer'=>'http://site6.way2sms.com', 'User-Agent'=>'Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.3) Gecko/20091020 Ubuntu/9.10 (karmic) Firefox/3.5.3 GTB7.0'})
    .to_return(
      :status => 302,
      :body => "",
      :headers => {location: "Main.action"}
    )

    stub_request(:get, "http://site6.way2sms.com/jsp/InstantSMS.jsp")
    .with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'Referer'=>'http://site6.way2sms.com', 'User-Agent'=>'Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.3) Gecko/20091020 Ubuntu/9.10 (karmic) Firefox/3.5.3 GTB7.0'})
    .to_return(:status => 200, :body => "<input type='hidden' id='Action' value='asdfgh'/>", :headers => {})

  end

  describe "#login" do

    context "using wrong credentials" do
      it "should fail with message 'Login failed'" do
        subject.username = "9995012345"
        subject.password = '123456'
        subject.login.should == {:success => false,:message => "Login failed"}
      end
    end

    context "using genuine credentials" do
      it "should successfully login and return the message 'Login successfully'" do
        subject.password = '654321'
        subject.login.should == {:success => true,:message => "Login successfully"}
      end
    end
  end

  describe "#set_header" do
    context "if cookie and referer are not passed" do
      it "should return a headers with cookie and referer as nil" do
        subject.__send__(:set_header).should == {
          "Cookie" => nil ,
          "Referer" => nil ,"Content-Type" => "application/x-www-form-urlencoded",
          "User-Agent" => "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.3) Gecko/20091020 Ubuntu/9.10 (karmic) Firefox/3.5.3 GTB7.0"
        }
      end
    end

    context "if cookie and referer are passed" do
      it "should return a headers with cookie and referer as they passed" do
        subject.__send__(:set_header,"test_cookie",'test_referer').should == {
          "Cookie" => 'test_cookie' ,
          "Referer" => 'test_referer',
          "Content-Type" => "application/x-www-form-urlencoded",
          "User-Agent" => "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.3) Gecko/20091020 Ubuntu/9.10 (karmic) Firefox/3.5.3 GTB7.0"
        }
      end
    end
  end

  describe "#validate" do
    context "Accept only Indian mobile numbers" do
      context "when a msisdn less than 10 digit is provided" do
        it "should return an error message 'Invalid Msisdn'" do
          subject.__send__(:validate,"99950123").should == {:success => false,:message => "Invalid Msisdn"}
        end
      end

      context "when a valid msisdn is missing" do
        it "should return an error message 'Invalid Msisdn'" do
          subject.__send__(:validate).should == {:success => false,:message => "Invalid Msisdn"}
        end
      end

      context "when a valid msisdn is provided" do
        it "should return a message 'Valid Msisdn' and the msisdn in local format" do
          subject.__send__(:validate,"9995012345").should == {:success => true,:message => "Valid Msisdn",:msisdn => '9995012345'}
        end
      end

      context "when a valid msisdn in +91xxxxxxx format is provided" do
        it "should return a message 'Valid Msisdn' and the msisdn in local 10 digit format by removing +91" do
          subject.__send__(:validate,"+919995012345").should == {:success => true,:message => "Valid Msisdn",:msisdn => '9995012345'}
        end
      end

      context "when a valid msisdn in 91xxxxxxx format is provided" do
        it "should return a message 'Valid Msisdn' and the msisdn in local 10 digit format by removing 91" do
          subject.__send__(:validate,"919995012345").should == {:success => true,:message => "Valid Msisdn",:msisdn => '9995012345'}
        end
      end

      context "when a valid msisdn in international(0091xxxxxxxx) format is provided" do
        it "should return a message 'Valid Msisdn' and the msisdn in local 10 digit format by removing 0091" do
          subject.__send__(:validate,"00919995012345").should == {:success => true,:message => "Valid Msisdn",:msisdn => '9995012345'}
        end
      end
    end
  end

  describe "#send" do
    #

    context "when the user is not logged in" do
      it "should try to login and on failer return message 'Login failed'" do
        subject.send("9995012345", 'Test Verbiage').should == {:success => false,:message => "Login failed"}
      end
    end

    context "when the user is logged in and a single msisdn is provided" do
      it "should try to send SMS and return return message 'Send successfully'" do
        subject.send("9995012345", 'Test Verbiage').should == {:success => true,:message => "Send successfully"}
      end
    end

  end

  describe "#send_to_many" do

  end

  describe "#logout" do

  end



  # it "should not send sms without logging in" do
  #   subject.password = "123456"
  #   subject.send('9995436867', 'Testing Ruby!!').should == {:success => false,:message => "Login failed"}
  # end

  # it "should give invalid login if u try to send sms with wrong credentials" do
  #   subject.password = "123456"
  #   subject.send_to_many('9995436867;9037864203;9037107542', 'Testing Ruby!!').should == {:success => false,:message => "Login failed"}
  # end

  # it "successfully logged out" do
  #   subject.logout.should == {:success => true,:message => "Logout successfully"}
  # end

#  it "should login successfully" do
#    subject.login.should == {:success => true,:message => "Login successfully"}
#  end
#
#  it "should send SMS to individual" do
#    subject.login
#    subject.send('9995436867', 'should send SMS to individual').should == {:success => true,:message => "Send successfully"}
#  end
#
#  it "send method should accept an array of msisdn" do
#    subject.send(["9995436867","9037864203","9037107542"],"Testing Ruby.......array").should == {"9995436867" => {:success => true,:message => "Send successfully"},
#      "9037864203" => {:success => true,:message => "Send successfully"},
#      "9037107542" => {:success => true,:message => "Send successfully"}}
#  end
#
#  it "send method should accept semicolon seperated msisdns" do
#    subject.send("9995436867;9037864203;9037107542","send method should accept semicolon seperated msisdns").should == {"9995436867" => {:success => true,:message => "Send successfully"},
#      "9037864203" => {:success => true,:message => "Send successfully"},
#      "9037107542" => {:success => true,:message => "Send successfully"}}
#  end
#
#  it "send method should accept an Hash of msisdn" do
#    msisdn = { 0 => "9995436867", 1 => "9037864203" , 2 => "9037107542"}
#    subject.send(msisdn,"send method should accept an Hash of msisdn").should == {"9995436867" => {:success => true,:message => "Send successfully"},
#      "9037864203" => {:success => true,:message => "Send successfully"},
#      "9037107542" => {:success => true,:message => "Send successfully"}}
#  end
#
#  it "should send SMS to group" do
#    subject.login
#    subject.send_to_many('9995436867;9037864203;9037107542', 'send to many method should accept semicolon seperated msisdns').should == {"9995436867" => {:success => true,:message => "Send successfully"},
#    "9037864203" => {:success => true,:message => "Send successfully"},
#    "9037107542" => {:success => true,:message => "Send successfully"}}
#  end

end
