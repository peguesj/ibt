#!/bin/bash

# Exit script on any error
set -e

# Ensure we are in the application directory
cd EventPromoter

# Install Devise for authentication (already added to Gemfile and installed)
echo "Installing Devise..."
rails generate devise:install

# Generate Devise User model (skip if already generated)
if ! grep -q "devise" app/models/user.rb; then
  rails generate devise User
fi

# Install Pundit for authorization (already added to Gemfile and installed)
echo "Installing Pundit..."
rails generate pundit:install

# Install Rolify for role management (already added to Gemfile and installed)
echo "Installing Rolify..."
rails generate rolify Role User

# Migrate the database
rails db:migrate

# Update User model to include roles
echo "Updating User model..."
if ! grep -q "rolify" app/models/user.rb; then
  sed -i "/class User < ApplicationRecord/a \  rolify" app/models/user.rb
fi

# Ensure default role assignment
if ! grep -q "assign_default_role" app/models/user.rb; then
  cat <<EOT >> app/models/user.rb

  after_create :assign_default_role

  def assign_default_role
    self.add_role(:user) if self.roles.blank?
  end
EOT
fi

echo "Role management and authentication setup complete."