require 'test_helper'

class StaticPageTest < ActiveSupport::TestCase

  def setup
    @page = static_pages(:help_page)
  end

  ######################### class method tests ##############################

  test 'full_text_search should work' do
    skip # TODO: write this
  end

  ############################ object tests #################################

  test 'valid static page saves' do
    assert @page.save
  end

  test 'searchable_html is updated before save' do
    @page.searchable_html = 'dfasdfsdf'
    old = @page.searchable_html
    @page.save
    assert_not_equal old, @page.searchable_html
  end

  ########################### property tests ################################

  # none

  ############################# method tests #################################

  test 'update_searchable_html should work' do
    @page.update_searchable_html
    assert_equal 'cats', @page.searchable_html
  end

  ########################### association tests ##############################

  # none

end
