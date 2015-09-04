# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

class ActionController::TestCase

  fx = [:issues, :members, :member_roles]
  ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/', fx)

end
