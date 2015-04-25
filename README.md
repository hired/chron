# Chron

Allows one to declaratively supply a block of code to be fired for a resource at a given point in time.

```ruby
class Course < ActiveRecord::Base
  include Chron::Observable

  at_time :close_at do
    Rails.logger.info "performing task for #{[self.class.to_s, id]}."
    Rails.logger.info "self.start_at (#{start_at}) == Time.current (#{Time.current})"

    update_column :state, 'closed' # set any state you want for this record
    ## bake in any conditional business logic required here
  end
end
```

This gem encapsulates the ActiveJob classes required to trigger the above block in the background.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chron'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chron

## Usage

#### Generators

To add a new observation, one can simply run

```
rails g chron:observation Course close_at
```

which just automates the following boilerplate.

#### Declaring Observations

In order to play well with rails autoload, you must tell the poller
about your observable resources and their columns by creating a `config/initializers/chron.rb` file.

```ruby
Chron.configure do
  # model name provided as a string to avoid an autoload hit on boot
  observe 'Course' do
    at :close_at
  end
end

```

#### Supplying Observation Logic

Mix `Chron::Observable` into `ActiveRecord::Base` children that you want to declare observations against.
You can provide an arbitrary block of code to be fired against a given record at the time stored as the value in that column.


```ruby
class Course < ActiveRecord::Base
  include Chron::Observable

  at_time :close_at do
    do_anything_for_this_resource
    # self == self.class.find(id)
    # self is an instance whose :close_at is now
    # this block gets fired at the :close_at time
  end
end
```

##### Testing Observations

An rspec helper is provided to help you avoid reaching into the internals to test your block. Just provide your block expectations to this matcher.

```ruby
require 'chron/testing/matchers' # usually goes in `spec_helper.rb`

# in model_spec.rb
describe 'chron blocks' do
  it { is_expected.to at_time(:close_at, -> { change(Course.closed, :count).by(1) }) }
end
```

#### Setting Up The Poller

`Chron::Job` will poll observable records and trigger matching observation blocks.
We recommend using the tomykaira/clockwork gem to run the poller.

`Clockwork.every(2.minutes, 'chron polling job') { Chron::Job.perform_later }`

#### What the poller does

Continuing the case above, the poller effectively does the following:

* find every record `where(close_at: Time.at(0)...Time.current, close_at__observation_started_at: nil)`
* schedule a background job for each record to run provided block on the record

#### No magic here.

So, of course the actual poller implementation just does this for all of the `at_time` declarations that you provide it.

## Contributing

### With Feedback

1. Open an issue
2. Say what's on your mind
3. Discuss!

This whole section is here just to invite you to talk.

### With Code

1. Fork it ( https://github.com/[my-github-username]/chron/fork )
2. Create your feature branch (`git checkout -b feature/my-stuff`)
3. Test your stuff with `rspec spec`
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin HEAD`)
6. Create a new Pull Request

