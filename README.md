## Description

This is a template repository for Ruby and RSpec along with Autotest and RCov.

## Bootstrapping

    $ cp -r ruby-tdd-template new-repository
    $ rm -rf new-repository/.git/                 # Do not remove the .gitignore which has sensible defaults
    $ cd name-of-your-new-repository && git init
    $ echo "*~" >> .git/info/exclude              # Ignores temporary editor files from git ~ without polluting .gitignore

  Edit README:
    $ cp README.md.sample README.md

  Create code directories:
    $ mkdir spec	# tests
    $ mkdir lib	# classes or modules
    $ mkdir bin	# executables

  Install rvm with Ruby-1.9.2.
    $ rvm install 1.9.2
  
  Install bundler for managing your applications dependencies:
    
    $ gem install bundler
    $ bundle install --path vendor
    $ bundle package

## Platform-specific Gems

  If you're on a mac, you don't want linux gems:
    $ bundle install --path vendor --without linux
    
  And if you're on linux:
    $ bundle install --path vendor --without osx
  
## Testing

    $ bundle exec autotest

## Test Code Coverage

  Test coverage is generated in spec/coverage when you run this:
  
    $ COVERAGE=true bundle exec rake spec
    
  There's also flog that identifies badly written methods and gives them a high flog score:
  
    $ bundle exec rake flog
    
## Gem building and push to gems.mobme.in

  To build a gem and push to gems.mobme.in, create a .gemspec and then do:
  
    $ bundle exec rake gem:push
