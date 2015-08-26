require File.expand_path('../../test_helper', __FILE__)

class IssuesControllerTest < Redmine::IntegrationTest
  fixtures :users, :projects, :trackers, :issue_statuses, :projects_trackers, :enumerations, :roles, :member_roles, :members

  def setup
    issue = Issue.create(subject: 'Test subject',
      project: Project.first,
      tracker: Tracker.first,
      status: IssueStatus.first,
      author: User.first,
      assigned_to_id: 2,
      priority: IssuePriority.first)
  end

  def test_only_admin_should_see_deleted_at_filter
    log_user("admin", "admin")
    get '/issues/'
    assert_response :success
    assert_select 'select#add_filter_select' do
      assert_select 'option[value=deleted_at]'
    end
  end

  def test_not_admin_should_not_see_deleted_at_filter
    log_user("jsmith", "jsmith")
    get '/issues/'
    assert_response :success
    assert_select 'select#add_filter_select' do
      assert_select 'option[value=deleted_at]', false
    end
  end
end
