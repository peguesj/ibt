#!/bin/bash

# Exit script on any error
set -e

# Ensure we are in the application directory
cd EventPromoter

# Generate controllers
echo "Generating controllers..."

rails generate controller Users index show new edit
rails generate controller Events index show new edit
rails generate controller Attendances create destroy
rails generate controller Promotions create update destroy
rails generate controller Connections create destroy
rails generate controller Venues index show
rails generate controller Artists index show
rails generate controller Notifications index
rails generate controller Comments create destroy

# Install Bootstrap (already added in the app initialization)
echo "Installing Bootstrap..."
yarn add bootstrap@5.1.3

# Include Bootstrap in application.js
echo "Importing Bootstrap JavaScript..."
echo "import 'bootstrap/dist/js/bootstrap.bundle.min'" >> app/javascript/application.js

# Include Bootstrap in application.scss
echo "Importing Bootstrap CSS..."
mkdir -p app/assets/stylesheets
echo "@import 'bootstrap';" > app/assets/stylesheets/application.scss

# Create application layout with topbar and sidebar
echo "Creating application layout..."
# (The content of application.html.erb is as provided in the previous code snippet)

cat <<EOT > app/views/layouts/application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <title>EventPromoter</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag "application", media: "all", "data-turbo-track": "reload" %>
    <%= javascript_include_tag "application", "data-turbo-track": "reload", defer: true %>
  </head>

  <body>
    <!-- Topbar Menu -->
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
      <div class="container-fluid">
        <%= link_to 'EventPromoter', root_path, class: 'navbar-brand' %>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#topbarMenu" aria-controls="topbarMenu" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="topbarMenu">
          <ul class="navbar-nav me-auto mb-2 mb-lg-0">
            <!-- Add topbar menu items here -->
          </ul>
          <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
            <% if user_signed_in? %>
              <li class="nav-item">
                <%= link_to 'Profile', user_path(current_user), class: 'nav-link' %>
              </li>
              <li class="nav-item">
                <%= link_to 'Logout', destroy_user_session_path, method: :delete, class: 'nav-link' %>
              </li>
            <% else %>
              <li class="nav-item">
                <%= link_to 'Login', new_user_session_path, class: 'nav-link' %>
              </li>
              <li class="nav-item">
                <%= link_to 'Sign Up', new_user_registration_path, class: 'nav-link' %>
              </li>
            <% end %>
          </ul>
        </div>
      </div>
    </nav>

    <!-- Sidebar and Main Content -->
    <div class="container-fluid">
      <div class="row">
        <!-- Sidebar -->
        <nav id="sidebarMenu" class="col-md-3 col-lg-2 d-md-block bg-light sidebar collapse">
          <div class="position-sticky pt-3">
            <ul class="nav flex-column">
              <li class="nav-item">
                <%= link_to 'Dashboard', root_path, class: 'nav-link' %>
              </li>
              <!-- Collapsible Events Menu -->
              <li class="nav-item">
                <a class="nav-link collapsed" data-bs-toggle="collapse" href="#collapseEvents" role="button" aria-expanded="false" aria-controls="collapseEvents">
                  Events
                </a>
                <div class="collapse" id="collapseEvents">
                  <ul class="btn-toggle-nav list-unstyled fw-normal pb-1 small">
                    <li><%= link_to 'All Events', events_path, class: 'nav-link' %></li>
                    <% if user_signed_in? %>
                      <li><%= link_to 'My Events', user_events_path(current_user), class: 'nav-link' %></li>
                      <% if current_user.has_role?(:host) %>
                        <li><%= link_to 'Create Event', new_event_path, class: 'nav-link' %></li>
                      <% end %>
                    <% end %>
                  </ul>
                </div>
              </li>
              <!-- Additional sidebar items can be added here -->
            </ul>
          </div>
        </nav>

        <!-- Main Content -->
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
          <div class="container mt-4">
            <%= yield %>
          </div>
        </main>
      </div>
    </div>

    <!-- Bootstrap JS -->
    <%= javascript_include_tag "bootstrap.bundle.min", defer: true %>
  </body>
</html>
EOT

echo "Controller and view generation complete."