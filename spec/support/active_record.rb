require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Migrator.up "db/migrate"

ActiveRecord::Migration.create_table :auctions do |t|
  t.string :name
  t.datetime :start_at
  t.datetime :start_at__observation_started_at
  t.datetime :start_at__observation_completed_at
  t.datetime :close_at

  t.timestamps null: false
end

ActiveRecord::Migration.create_table :puppies do |t|
  t.string :name
  t.datetime :play_at
  t.datetime :play_at__observation_started_at
  t.datetime :play_at__observation_completed_at
  t.timestamps null: false
end

class Auction < ActiveRecord::Base
  include Chron::Observable

  at_time :start_at do
    puppies!
  end
end

class Puppy < ActiveRecord::Base
  include Chron::Observable

  at_time :play_at do

  end
end
