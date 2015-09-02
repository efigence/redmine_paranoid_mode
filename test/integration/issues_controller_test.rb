require File.expand_path('../../test_helper', __FILE__)

class IssuesControllerTest < Redmine::IntegrationTest
  fixtures :users, :projects, :trackers, :issue_statuses, :projects_trackers, :enumerations, :roles, :member_roles, :members

  def setup
    @issue1 = Issue.create(subject: 'Test issue',
      project: Project.first,
      tracker: Tracker.first,
      status: IssueStatus.first,
      author: User.first,
      assigned_to_id: 2,
      priority: IssuePriority.first)

    @issue2 = Issue.create(subject: 'Test deleted issue',
      project: Project.first,
      tracker: Tracker.first,
      status: IssueStatus.first,
      author: User.first,
      assigned_to_id: 2,
      priority: IssuePriority.first)

    @issue2.delete
  end

  def test_only_admin_should_see_deleted_at_filter
    log_user("admin", "admin")
    get issues_path
    assert_response :success
    assert_select 'select#add_filter_select' do
      assert_select 'option[value=deleted_at]'
    end
  end

  def test_not_admin_should_not_see_deleted_at_filter
    log_user("jsmith", "jsmith")
    get issues_path

    assert_response :success
    assert_select 'select#add_filter_select' do
      assert_select 'option[value=deleted_at]', false
    end
  end

  def test_only_admin_should_see_deleted_issue
    log_user("admin", "admin")
    get issue_path(@issue2)
    # byebug
    assert_response :success
  end

  def test_not_admin_should_not_see_deleted_issue
    log_user("jsmith", "jsmith")
    get issue_path(@issue2)
    assert_response :missing
  end
end
