require File.expand_path('../../test_helper', __FILE__)

class IssueTest < ActiveSupport::TestCase
  fixtures :issues

  def test_deleted_issue_should_hide
    issue = issues(:issues_001)
    issue.save

    assert_difference('Issue.only_deleted.count') do
      issue.destroy
    end
    assert_not_equal nil, Issue.only_deleted.last.deleted_at
  end

end
