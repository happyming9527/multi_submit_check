# MultiSubmitCheck

use to validate form multiply submit

## Installation

Add this line to your application's Gemfile:

    gem 'multi_submit_check'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install multi_submit_check

## Usage

you can use method  'token_field' to add a hash token to you form ,or make a
configuration 'config.multi_submit_check = true' in application.rb file to 
automatically make token for every form made by 'form_for' and 'form_for'
methods.In default the configuration is false.

## Contributing

1. Fork it ( http://github.com/<my-github-username>/multi_submit_check/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
