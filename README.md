# [ Deprecated ]
> This project is deprecated.
> Way2sms has changed its UI after this and this project won't work anymore. 

Sendsms Gem [![Build Status](https://secure.travis-ci.org/revathskumar/send-sms-in-ruby.png)](http://travis-ci.org/revathskumar/send-sms-in-ruby?branch=master) [![Dependency Status](https://gemnasium.com/revathskumar/send-sms-in-ruby.png)](https://gemnasium.com/revathskumar/send-sms-in-ruby) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/revathskumar/send-sms-in-ruby)
------------------------


Sendsms gem helps you to send SMS via way2sms from ruby.

[yard Documentation](http://rubydoc.info/gems/sendsms/frames)

## Usage

### Individual SMS

    require "sendsms"
    w2s = SendSms.new "username","password"
    w2s.send "9995436867", "sending via sendsms gem!!!"

### Group SMS

#### Msisdns as array

    require "sendsms"
    w2s = SendSms.new "username","password"
    msisdn = ["9995436867","9037864203","9037107542"]
    w2s.send msisdns, "sending via sendsms gem!!!"

#### Msisdns as Hash

    require "sendsms"
    w2s = SendSms.new "username","password"
    msisdn = { 0 => "9995436867", 1 => "9037864203" , 2 => "9037107542"}
    w2s.send msisdns, "sending via sendsms gem!!!"

#### Msisdns as semicolon seperated values

    require "sendsms"
    w2s = SendSms.new "username","password"
    msisdn = "9995436867;9037864203;9037107542"
    w2s.send msisdns, "sending via sendsms gem!!!"


## License
Please see [licence](http://github.com/revathskumar/send-sms-in-ruby/blob/master/LICENSE)