require File.expand_path('../../test_helper', __FILE__)

class JournalTest < ActiveSupport::TestCase
  fixtures :journals

  def test_deleted_journal_should_be_available
    journal = journals(:journals_001)
    journal.save

    assert_difference('Journal.only_deleted.count') do
      journal.destroy
    end
    assert_not_equal nil, Journal.only_deleted.last.deleted_at
  end

end
