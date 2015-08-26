require File.expand_path('../../test_helper', __FILE__)

class IssueTest < ActiveSupport::TestCase
  fixtures :users, :projects, :trackers, :issue_statuses, :projects_trackers, :enumerations

  def test_deleted_issue_should_only_hide
    issue = Issue.create(subject: 'Test subject',
      project: Project.first,
      tracker: Tracker.first,
      status: IssueStatus.first,
      author: User.first,
      priority: IssuePriority.first)

    assert_no_difference('Issue.count') do
      issue.destroy
    end
    assert_not_equal nil, Issue.last.deleted_at
  end

end
