require File.expand_path('../../test_helper', __FILE__)

class IssueTest < ActiveSupport::TestCase
  fixtures :users, :projects, :trackers, :issue_statuses, :projects_trackers, :enumerations, :issues

  def test_deleted_issue_should_only_hide
    issue = issues(:issues_001)

    assert_difference('Issue.only_deleted.count') do
      issue.delete
    end
    assert_not_equal nil, Issue.only_deleted.last.deleted_at
  end

end
