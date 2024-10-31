#!/bin/bash

# Exit script on any error
set -e


# Add required gems to Gemfile
echo "Adding required gems to Gemfile..."
cat <<EOT >> Gemfile

# Authentication and Authorization gems
gem 'devise'
gem 'pundit'
gem 'rolify'

# OAuth gems
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'

# For JSON handling with PostgreSQL
gem 'jsonb_accessor'

# For file uploads
gem 'carrierwave', '~> 2.0'
gem 'mini_magick'

# For generating fake data
gem 'faker'
EOT

# Install added gems
bundle install

# Generate models with corrected decimal field syntax
echo "Generating models..."

rails generate model User \
  username:string \
  email:string \
  password_digest:string \
  first_name:string \
  last_name:string \
  phone_number:string \
  date_of_birth:date \
  location:string \
  profile_image:string \
  bio:text \
  oauth_provider:string \
  oauth_uid:string \
  social_links:jsonb \
  preferences:jsonb \
  followers_count:integer \
  following_count:integer \
  verified:boolean

rails generate model Role \
  name:string \
  resource:references{polymorphic}

rails generate model UsersRole \
  user:references \
  role:references

rails generate model Event \
  title:string \
  description:text \
  location:string \
  start_time:datetime \
  end_time:datetime \
  host_id:integer \
  ticket_price:decimal{8,2} \
  inventory:integer \
  tickets_sold:integer \
  event_image:string \
  category:string \
  tags:jsonb \
  status:string \
  venue_id:integer \
  visibility:string \
  age_restriction:integer

rails generate model Attendance \
  user:references \
  event:references \
  ticket_count:integer \
  total_price:decimal{8,2} \
  attendance_status:string \
  check_in_status:boolean \
  ticket_type:string

rails generate model Promotion \
  user:references \
  event:references \
  commission_rate:decimal{5,2} \
  tickets_sold:integer \
  promo_code:string \
  earnings:decimal{8,2}

rails generate model Connection \
  user:references \
  connected_user_id:integer \
  status:string

rails generate model Venue \
  name:string \
  address:string \
  city:string \
  state:string \
  zip_code:string \
  country:string \
  capacity:integer \
  description:text \
  latitude:decimal{10,6} \
  longitude:decimal{10,6} \
  image:string \
  contact_info:string \
  amenities:jsonb \
  website:string

rails generate model Artist \
  name:string \
  genre:string \
  bio:text \
  profile_image:string \
  social_links:jsonb \
  contact_info:string \
  verified:boolean \
  followers_count:integer

rails generate model Performance \
  artist:references \
  event:references \
  performance_time:datetime \
  duration:integer \
  stage:string

rails generate model Notification \
  user:references \
  content:string \
  read:boolean

rails generate model Comment \
  user:references \
  event:references \
  content:text

# Run migrations
echo "Running migrations..."
rails db:migrate

echo "Model generation complete."