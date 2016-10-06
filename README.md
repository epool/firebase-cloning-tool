# Firebase::Cloning::Tool

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/firebase/cloning/tool`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'firebase-cloning-tool'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install firebase-cloning-tool

## Usage

Just run `firebase-cloning-tool` on a terminal and provide the required information.

    $ firebase-cloning-tool

You will be asked for:

    $ Email: [write your firebase console email]
    $ Password: [write your firebase console password]
    $ Source(Project Name, Case sensitive): [Project that will be cloned, this is case sensitive]
    $ Destination(New Project Name, Case sensitive, Only letters, numbers, spaces, and these characters: -!'") : [Name for the new firebase project]

### NOTE

This script doesn't save nor share any data or password, just use the data for accessing to [firebase console](https://console.firebase.google.com/).

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org/gems/firebase-cloning-tool).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/epool/firebase-cloning-tool.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

