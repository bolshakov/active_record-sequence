[![Build Status](https://travis-ci.org/bolshakov/active_record-sequence.svg?branch=master)](https://travis-ci.org/bolshakov/active_record-sequence)
[![Gem Version](https://badge.fury.io/rb/active_record-sequence.svg)](https://badge.fury.io/rb/active_record-sequence)

# ActiveRecord::Sequence

Access to [PostgreSQL's Sequences](https://www.postgresql.org/docs/8.1/static/sql-createsequence.html)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record-sequence'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record-sequence

## Usage

By default new sequence starts from `1`:

```ruby
sequence = ActiveRecord::Sequence.create('numbers')
```

`#next` returns next value in the sequence:

```ruby
sequence.next #=> 1
sequence.next #=> 2
```

`#peek` returns current value:

```ruby
sequence.peek #=> 2
```

You can start a sequence with specific value:

```ruby
sequence = ActiveRecord::Sequence.create('numbers', start: 42)
sequence.next #=> 42
sequence.next #=> 43
```

Specify custom increment value:

```ruby
sequence = ActiveRecord::Sequence.create('numbers', increment: 3)
sequence.next #=> 1
sequence.next #=> 4
```

If you pass negative increment, a sequence will be decreasing:

```ruby
sequence = ActiveRecord::Sequence.create('numbers', increment: -3)
sequence.next #=> -1
sequence.next #=> -4
```

To limit number of elements in a sequence specify `max` value:  

```ruby
sequence = ActiveRecord::Sequence.create('numbers', max: 2)
sequence.next #=> 1
sequence.next #=> 2
sequence.next #=> fail with StopIteration
```

Decreasing sequence may be limited as well:

```ruby
sequence = ActiveRecord::Sequence.create('numbers', min: -2, increment: -1)
sequence.next #=> -1
sequence.next #=> -2
sequence.next #=> fail with StopIteration
```

To define infinite sequence, use `cycle` option:

```ruby
sequence = ActiveRecord::Sequence.create('numbers', max: 2, cycle: true)
sequence.next #=> 1
sequence.next #=> 2
sequence.next #=> 1
sequence.next #=> 2
# etc.
```

You con use previously created sequence by instantiating `Sequence` class:

```ruby
ActiveRecord::Sequence.create('numbers', max: 2, cycle: true)
sequence = ActiveRecord::Sequence.new('numbers')
sequence.next #=> 1
sequence.next #=> 2
sequence.next #=> 1
```

To destroy a sequence:

```ruby
ActiveRecord::Sequence.drop('numbers')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a
new version, update the version number in `version.rb`, and then run `bundle exec rake release`,
which will create a git tag for the version, push git commits and tags, and push the `.gem`
file to [rubygems.org](https://rubygems.org).


We test this gem against different versions of `ActiveRecord` using [appraisal](https://github.com/thoughtbot/appraisal) gem.
To regenerate gemfiles run:

    $ appraisal install

To run specs against all versions:

    $ appraisal rake spec

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bolshakov/active_record-sequence.

