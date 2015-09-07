require File.expand_path('../../test_helper', __FILE__)

class IssuesControllerTest < Redmine::IntegrationTest
  fixtures :users, :projects, :trackers, :issue_statuses, :projects_trackers, :enumerations, :roles, :members, :member_roles, :issues

  def setup
    User.current = nil
  end

  # USER IS NOT LOGGING IN

  def test_only_admin_should_see_deleted_at_filter
    skip
    log_user("admin", "admin")
    User.current = User.first
    session[:user_id] = User.first.id
    session[:ctime] = Time.now.utc.to_i
    session[:atime] = Time.now.utc.to_i
    get issues_path
    byebug
    assert_response :success
    byebug
    assert_select 'select#add_filter_select' do
      assert_select 'option[value=deleted_at]'
    end
    assert_select 'table.issues'
    assert_select 'table.list tr', 4
  end

  def test_not_admin_should_not_see_deleted_at_filter
    skip
    log_user("jsmith", "jsmith")
    get issues_path
    assert_response :success
    # byebug
    assert_select 'select#add_filter_select' do
      assert_select 'option[value=deleted_at]', false
    end
    assert_select 'table.issues'
    assert_select 'table.list tr', 4
  end

  def test_only_admin_should_see_deleted_issue
    skip
    issue = issues(:issues_001)
    # issue.delete
    log_user("admin", "admin")
    get issue_path(issue)
    # byebug
    assert_response :success
  end

  def test_not_admin_should_not_see_deleted_issue
    skip
    issue = issues(:issues_001)
    issue.delete
    log_user("jsmith", "jsmith")
    get issue_path(issue)
    assert_response :missing
  end
end
