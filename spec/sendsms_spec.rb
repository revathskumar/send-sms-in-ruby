$: << "."
require 'spec_helper'
require 'sendsms'


describe SendSms, "send SMS via way2sms" do

  subject { SendSms.new "9995012345", '123456' }

  let(:mock_headers) {
    {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'Cookie'=>'some cookie', 'Referer'=>'http://site6.way2sms.com', 'User-Agent'=>'"Mozilla/5.0 (Windows NT 6.1; Intel Mac OS X 10.6; rv:7.0.1) Gecko/20100101 Firefox/7.0.1"'}
  }

  let(:mock_headers_without_cookie) {
    {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'Referer'=>'http://site6.way2sms.com', 'User-Agent'=>'"Mozilla/5.0 (Windows NT 6.1; Intel Mac OS X 10.6; rv:7.0.1) Gecko/20100101 Firefox/7.0.1"'}
  }

  let(:mock_headers_with_encoding) {
    {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'Referer'=>'http://site6.way2sms.com', 'User-Agent'=>'"Mozilla/5.0 (Windows NT 6.1; Intel Mac OS X 10.6; rv:7.0.1) Gecko/20100101 Firefox/7.0.1"'}
  }



  before(:each) do
    stub_request(:post, "http://site6.way2sms.com/Login1.action")
    .with(
      body: {"password"=>"123456", "username"=>"9995012345"},
      headers: mock_headers_without_cookie)
    .to_return(
      body: {},
      headers: {location: ""},
      status: 302
    )

    stub_request(:post, "http://site6.way2sms.com/Login1.action")
    .with(
      body: {"password"=>"654321", "username"=>"9995012345"},
      headers: mock_headers_without_cookie)
    .to_return(
      :status => 302,
      :body => "",
      :headers => {location: "Main.action"}
    )

    stub_request(:get, "http://site6.way2sms.com/jsp/InstantSMS.jsp")
    .with(:headers => mock_headers_with_encoding)
    .to_return(:status => 200, :body => "<input type='hidden' id='Action' value='asdfgh'/>", :headers => {})


    stub_request(:post, "http://site6.way2sms.com/quicksms.action?custid=\"+custid+\"&sponserid=\"+sponserid+\"")
    .with(
      body: {"MobNo" => /^[0-9]{10}$/, "textArea"=> "Test Verbiage", "HiddenAction"=>"instantsms", "login"=> "", "pass"=> "", "Action"=>"abfghst5654g"},
      headers: mock_headers
    )
    .to_return(
      :status => 302,
      :body => "",
      :headers => {location: "http://site6.way2sms.com/generalconfirm.action?SentMessage=Message+has+been+submitted+successfully"}
    )

    stub_request(:get, "http://site6.way2sms.com/jsp/logout.jsp").
    to_return(:status => 200, :body => "", :headers => {})
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
        header = subject.__send__(:set_header)
        header["Cookie"].should eq nil
        header["Referer"].should eq nil
      end
    end

    context "if cookie and referer are passed" do
      it "should return a headers with cookie and referer as they passed" do
        header = subject.__send__(:set_header,"test_cookie",'test_referer')
        header["Cookie"].should eq 'test_cookie'
        header["Referer"].should eq 'test_referer'
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
    context "when the user is not logged in" do
      it "should try to login and on failer return message 'Login failed'" do
        subject.send("9995012345", 'Test Verbiage').should == {:success => false,:message => "Login failed"}
      end
    end

    context "when the user is logged in and a single msisdn is provided" do
      it "should try to send SMS and return message 'Send successfully'" do
        subject.instance_variable_set(:@cookie, "some cookie")
        subject.send("9995012345", 'Test Verbiage').should == {:success => true,:message => "Send successfully"}
      end
    end

    context "when msisdns given as semicolon seperated" do
      it "should try to send SMS and return message 'Send successfully'" do
        subject.instance_variable_set(:@cookie, "some cookie")
        subject.send("9995012345;9995678901", 'Test Verbiage').should == {
          "9995012345"=>{:success => true,:message => "Send successfully"},
          "9995678901"=>{:success => true,:message => "Send successfully"}
        }
      end
    end

    context "when msisdns given as an array" do
      it "should try to send SMS and return message 'Send successfully'" do
        subject.instance_variable_set(:@cookie, "some cookie")
        subject.send(["9995012345","9995678901"], 'Test Verbiage').should == {
          "9995012345"=>{:success => true,:message => "Send successfully"},
          "9995678901"=>{:success => true,:message => "Send successfully"}
        }
      end
    end

    context "when @auto_logout" do
      before :each do
        subject.instance_variable_set(:@cookie, "some cookie")
      end

      it "it should call logout method on if @auto_logout is true" do
        subject.instance_variable_set(:@auto_logout, true)
        subject.should_receive(:logout)
        subject.send("9995012345", 'Test Verbiage').should == {:success => true,:message => "Send successfully"}
      end

      it "should not logout when @auto_logout is false" do
        subject.instance_variable_set(:@auto_logout, false)
        subject.should_not_receive(:logout)
        subject.send("9995012345", 'Test Verbiage').should == {:success => true,:message => "Send successfully"}
      end
    end
  end

  describe "#send_to_many" do
    context "when the user is not logged in" do
      it "should try to login and on failer return message 'Login failed'" do
        subject.send_to_many("9995012345;9995678901", 'Test Verbiage').should == {:success => false,:message => "Login failed"}
      end
    end

    context "when msisdns given as semicolon seperated" do
      it "should try to send SMS and return message 'Send successfully'" do
        subject.instance_variable_set(:@cookie, "some cookie")
        subject.send_to_many("9995012345;9995678901", 'Test Verbiage').should == {
          "9995012345"=>{:success => true,:message => "Send successfully"},
          "9995678901"=>{:success => true,:message => "Send successfully"}
        }
      end
    end
  end

  describe "#logout" do
    context "on success" do
      it "return message 'Logout successfully'" do
        subject.logout.should == {:success => true,:message => "Logout successfully"}
      end
    end

    context "on failure" do
      before(:each) do
        stub_request(:get, "http://site6.way2sms.com/jsp/logout.jsp").
        to_return(:status => 500, :body => "", :headers => {})
      end

      it "return message 'Logout failed'" do
        subject.logout.should == {:success => false,:message => "Logout failed"}
      end
    end
  end
end
