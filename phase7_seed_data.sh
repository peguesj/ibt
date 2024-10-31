#!/bin/bash

# Exit script on any error
set -e

# Ensure we are in the application directory
cd EventPromoter

# Generate seed data
echo "Generating seed data..."

# Create db/seeds.rb with comprehensive and relational seed data
cat <<EOT > db/seeds.rb
require 'faker'

# Clear existing data
puts "Clearing existing data..."
Attendance.destroy_all
Promotion.destroy_all
Performance.destroy_all
Comment.destroy_all
Notification.destroy_all
Connection.destroy_all
Event.destroy_all
Venue.destroy_all
Artist.destroy_all
User.destroy_all
Role.destroy_all

# Reset primary keys
ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.reset_pk_sequence!(t)
end

# Create roles
puts "Creating roles..."
roles = ['admin', 'host', 'promoter', 'user', 'moderator']
roles.each do |role_name|
  Role.create!(name: role_name)
end

# Create admin user
puts "Creating admin user..."
admin = User.create!(
  email: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password',
  first_name: 'Admin',
  last_name: 'User',
  username: 'admin',
  verified: true
)
admin.add_role(:admin)

# Create hosts
puts "Creating hosts..."
hosts = []
5.times do
  user = User.create!(
    email: Faker::Internet.unique.email,
    password: 'password',
    password_confirmation: 'password',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    username: Faker::Internet.unique.username(specifier: 5..8),
    verified: true
  )
  user.add_role(:host)
  hosts << user
end

# Create promoters
puts "Creating promoters..."
promoters = []
5.times do
  user = User.create!(
    email: Faker::Internet.unique.email,
    password: 'password',
    password_confirmation: 'password',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    username: Faker::Internet.unique.username(specifier: 5..8)
  )
  user.add_role(:promoter)
  promoters << user
end

# Create regular users
puts "Creating regular users..."
users = []
20.times do
  user = User.create!(
    email: Faker::Internet.unique.email,
    password: 'password',
    password_confirmation: 'password',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    username: Faker::Internet.unique.username(specifier: 5..8)
  )
  user.add_role(:user)
  users << user
end

# Create venues
puts "Creating venues..."
venues = []
10.times do
  venue = Venue.create!(
    name: Faker::Company.unique.name,
    address: Faker::Address.street_address,
    city: Faker::Address.city,
    state: Faker::Address.state,
    zip_code: Faker::Address.zip_code,
    country: Faker::Address.country,
    capacity: rand(100..1000),
    description: Faker::Lorem.paragraph,
    latitude: Faker::Address.latitude,
    longitude: Faker::Address.longitude,
    contact_info: Faker::PhoneNumber.phone_number,
    website: Faker::Internet.url
  )
  venues << venue
end

# Create artists
puts "Creating artists..."
artists = []
10.times do
  artist = Artist.create!(
    name: Faker::Music.band,
    genre: Faker::Music.genre,
    bio: Faker::Lorem.paragraph,
    profile_image: Faker::Avatar.image,
    social_links: {
      instagram: Faker::Internet.url(host: 'instagram.com'),
      tiktok: Faker::Internet.url(host: 'tiktok.com'),
      facebook: Faker::Internet.url(host: 'facebook.com'),
      x: Faker::Internet.url(host: 'twitter.com')
    },
    contact_info: Faker::PhoneNumber.phone_number,
    verified: [true, false].sample,
    followers_count: rand(1000..100_000)
  )
  artists << artist
end

# Create events
puts "Creating events..."
events = []
20.times do
  host = hosts.sample
  venue = venues.sample
  event = Event.create!(
    title: Faker::Lorem.sentence(word_count: 3),
    description: Faker::Lorem.paragraph,
    location: venue.address,
    start_time: Faker::Time.forward(days: rand(1..30), period: :evening),
    end_time: Faker::Time.forward(days: rand(1..30), period: :night),
    host_id: host.id,
    ticket_price: rand(10.0..100.0).round(2),
    inventory: rand(50..500),
    tickets_sold: 0,
    category: ['Music', 'Art', 'Sports'].sample,
    tags: [Faker::Lorem.word, Faker::Lorem.word],
    status: 'published',
    venue_id: venue.id,
    visibility: 'public',
    age_restriction: [0, 18, 21].sample
  )
  events << event

  # Assign promoters to the event
  promoters.sample(rand(1..3)).each do |promoter|
    Promotion.create!(
      user_id: promoter.id,
      event_id: event.id,
      commission_rate: rand(5.0..20.0).round(2),
      tickets_sold: 0,
      promo_code: Faker::Alphanumeric.alphanumeric(number: 6).upcase,
      earnings: 0.0
    )
  end

  # Add performances to the event
  artists.sample(rand(1..3)).each do |artist|
    Performance.create!(
      artist_id: artist.id,
      event_id: event.id,
      performance_time: event.start_time + rand(1..3).hours,
      duration: rand(30..120),
      stage: ["Main Stage", "Side Stage", "VIP Lounge"].sample
    )
  end
end

# Create attendances
puts "Creating attendances..."
events.each do |event|
  # Random number of attendees per event
  attendees = users.sample(rand(5..15))
  attendees.each do |user|
    ticket_count = rand(1..5)
    Attendance.create!(
      user_id: user.id,
      event_id: event.id,
      ticket_count: ticket_count,
      total_price: (event.ticket_price * ticket_count).round(2),
      attendance_status: 'confirmed',
      check_in_status: [true, false].sample,
      ticket_type: ['General Admission', 'VIP'].sample
    )
    # Update event tickets_sold
    event.tickets_sold += ticket_count
    event.save!
  end
end

# Create connections between users
puts "Creating user connections..."
all_users = hosts + promoters + users
all_users.each do |user|
  connections = all_users.sample(rand(5..10)).reject { |u| u.id == user.id }
  connections.each do |connected_user|
    Connection.create!(
      user_id: user.id,
      connected_user_id: connected_user.id,
      status: ['accepted', 'pending'].sample
    )
  end
end

# Create comments on events
puts "Creating comments on events..."
events.each do |event|
  commenters = all_users.sample(rand(3..10))
  commenters.each do |user|
    Comment.create!(
      user_id: user.id,
      event_id: event.id,
      content: Faker::Lorem.sentence
    )
  end
end

# Create notifications
puts "Creating notifications..."
all_users.each do |user|
  rand(1..5).times do
    Notification.create!(
      user_id: user.id,
      content: Faker::Lorem.sentence,
      read: [true, false].sample
    )
  end
end

puts "Seed data generation complete."
EOT

# Install Faker gem if not already installed
if ! gem list faker -i > /dev/null 2>&1; then
  echo "Installing Faker gem..."
  bundle add faker
fi

# Run seed script
rails db:seed

echo "Seed data generation complete."