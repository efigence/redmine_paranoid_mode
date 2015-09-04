# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

class ActionController::TestCase

  fx = [:users, :projects, :trackers, :issue_statuses, :projects_trackers, :enumerations, :roles, :members, :member_roles, :issues]
  ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/', fx)

end
