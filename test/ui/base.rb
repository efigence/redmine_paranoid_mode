# Redmine - project management software
# Copyright (C) 2006-2015  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require File.expand_path('../../test_helper', __FILE__)
require 'capybara/rails'

Capybara.default_driver = :rack_test
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end

Capybara.run_server = true #Whether start server when testing
Capybara.server_port = 4444

# default: 2
Capybara.default_wait_time = 2

module Redmine
  module UiTest
    # Base class for UI tests
    class Base < ActionDispatch::IntegrationTest
      include Capybara::DSL

      # Stop ActiveRecord from wrapping tests in transactions
      # Transactional fixtures do not work with Selenium tests, because Capybara
      # uses a separate server thread, which the transactions would be hidden
      self.fixture_path = "#{::Rails.root}/plugins/redmine_paranoid_mode/test/fixtures"
      self.use_transactional_fixtures = false

      # Should not depend on locale since Redmine displays login page
      # using default browser locale which depend on system locale for "real" browsers drivers

      teardown do
        Capybara.reset_sessions!    # Forget the (simulated) browser state
        Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
      end
    end
  end
end
