# Chron

Allows one to declaratively supply a block of code to be fired for a resource at a given point in time.

```ruby
class Course < ActiveRecord::Base
  include Chron::Observable

  at_time :close_at do
    Rails.logger.info "performing task for a given record when its start_at value passes"
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

#### Declaring As Observable

Mix `Chron::Observable` into `ActiveRecord::Base` children that you want to declare observations against.

```ruby
class Course < ActiveRecord::Base
  include Chron::Observable
end
```

#### Supplying Observations

You can provide an arbitrary block of code to be fired against a given record at the time stored as the value in that column.

```ruby
at_time :close_at do
  do_anything_for_this_resource
  # self == self.class.find(id)
  # self is an instance whose :close_at is now
  # this block gets fired at the :close_at time
end
```

#### Setting Up The Poller

`Chron::Job` will poll observable records and trigger matching observation blocks.
We recommend using the tomykaira/clockwork gem.

`Clockwork.every(Chron::POLLING_WINDOW) { Chron::Job.perform_later }`

Feel free to set your own value (in seconds) for Chron::POLLING_WINDOW if you'd prefer something larger/smaller.

```ruby
# in config/initializers/chron.rb
Chron::POLLING_WINDOW = 60 # seconds

# in Clockfile
require 'config/initializers/chron'

Clockwork.every(Chron::POLLING_WINDOW) { Chron::Job.perform_later }
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/chron/fork )
2. Create your feature branch (`git checkout -b feature/my-stuff`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin HEAD`)
5. Create a new Pull Request
