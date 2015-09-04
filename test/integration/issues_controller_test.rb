require File.expand_path('../../test_helper', __FILE__)

class IssuesControllerTest < Redmine::IntegrationTest
  fixtures :users, :projects, :trackers, :issue_statuses, :projects_trackers, :enumerations, :roles, :members, :member_roles, :issues

  def test_only_admin_should_see_deleted_at_filter
    log_user("admin", "admin")
    get issues_path
    assert_response :success
    assert_select 'select#add_filter_select' do
      assert_select 'option[value=deleted_at]'
    end
    assert_select 'table.issues'
    assert_select 'table.list tr', 4
  end

  def test_not_admin_should_not_see_deleted_at_filter
    log_user("jsmith", "jsmith")
    get issues_path
    assert_response :success
    assert_select 'select#add_filter_select' do
      assert_select 'option[value=deleted_at]', false
    end
    assert_select 'table.issues'
    assert_select 'table.list tr', 4
  end

  def test_only_admin_should_see_deleted_issue
    issue = issues(:issues_001)
    # issue.delete
    log_user("admin", "admin")
    get issue_path(issue)
    # byebug
    assert_response :success
  end

  def test_not_admin_should_not_see_deleted_issue
    issue = issues(:issues_001)
    issue.delete
    log_user("jsmith", "jsmith")
    get issue_path(issue)
    assert_response :missing
  end
end
