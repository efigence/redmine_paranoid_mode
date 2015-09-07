require File.expand_path('../../test_helper', __FILE__)

class IssuesControllerTest < ActionController::TestCase
  fixtures :users, :projects, :trackers, :issue_statuses, :projects_trackers, :enumerations, :roles, :members, :member_roles, :issues

  def setup
    User.current = User.first
    session[:user_id] = User.first.id
    session[:ctime] = Time.now.utc.to_i
    session[:atime] = Time.now.utc.to_i

    @request.session[:user_id] = User.first.id
    @request.session[:ctime] = Time.now.utc.to_i
    @request.session[:atime] = Time.now.utc.to_i
  end

  # USER IS NOT LOGGED IN

  def test_only_admin_should_see_deleted_at_filter
    skip
    get :index
    assert_response :success
    assert_select 'select#add_filter_select' do
      assert_select 'option[value=deleted_at]'
    end
    assert_select 'table.issues'
    assert_select 'table.list tr', 4
  end

  def test_not_admin_should_not_see_deleted_at_filter
    skip
    session[:user_id] = 2
    get :index
    assert_response :success
    byebug
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
    get :show, :id => 1
    # byebug
    assert_response :success
  end

  def test_not_admin_should_not_see_deleted_issue
    skip
    session[:user_id] = 2
    issue = issues(:issues_001)
    issue.delete
    get :show, :id => 1
    assert_response :missing
  end
end
