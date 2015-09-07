require File.expand_path('../base', __FILE__)

class Redmine::UiTest::IssuesTest < Redmine::UiTest::Base
  fixtures :users, :projects, :trackers, :issue_statuses, :projects_trackers, :enumerations, :roles, :members, :member_roles, :issues

  def log_user(login, password)
    visit '/my/page'
    assert_equal '/login', current_path
    within('#login-form form') do
      fill_in 'username', :with => login
      fill_in 'password', :with => password
      find('input[name=login]').click
    end
    assert_equal '/my/page', current_path
  end

  def test_only_admin_should_see_deleted_at_filter
    log_user('admin', 'admin')
    visit '/issues'
    find_field('add_filter_select').click
    assert page.has_content?('Deleted at')
    find_field('add_filter_select').click
    page.assert_selector('table.list.issues tbody tr', :count => Issue.count)
  end

  def test_not_admin_should_not_see_deleted_at_filter
    log_user('jsmith', 'jsmith')
    visit '/issues'
    find_field('add_filter_select').click
    assert page.has_no_content?('Deleted at')
    find_field('add_filter_select').click
    page.assert_selector('table.list.issues tbody tr', :count => Issue.count)
  end

  def test_only_admin_should_see_deleted_issue
    issue = issues(:issues_001)
    issue.delete
    log_user("admin", "admin")
    visit "/issues/#{issue.id}"
    assert page.has_content?(issue.description)
  end

  def test_not_admin_should_not_see_deleted_issue
    issue = issues(:issues_001)
    issue.delete
    log_user("jsmith", "jsmith")
    visit "/issues/#{issue.id}"
    assert page.has_content?('404')
  end
end
