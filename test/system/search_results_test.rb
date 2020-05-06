require "application_system_test_case"

class SearchResultsPageTest < ApplicationSystemTestCase
  def setup
  end

  def test_footer_nav
    visit '/?q=water'
    within("section#footer-app") do
      # Bad Link - Should Fail
      assert page.has_no_link?("Google")

      # Header Link - Should Fail
      assert page.has_no_link?("History")

      # Good Links - Should Pass
      assert page.has_link?("News & Updates")
      assert page.has_link?("About Us")
      assert page.has_link?("Contact Project Team")
      assert page.has_link?("Big Ten Academic Alliance Homepage")
    end
  end

  def test_search
    visit '/?q=water'
    assert page.has_content?("Search Results")

  end

  def test_map_clustering
    # Map centered on USA. B1G records have cluster centroid values.
    visit '/?utf8=✓&view=mapview&q=&search_field=all_fields&bbox=-177.129822%20-36.81918%20-28.067322%2074.70319'
    assert page.has_selector?("div.marker-cluster")
  end

  def test_empty_search
    visit '/?utf8=✓&q=&search_field=all_fields'
    assert page.assert_selector('article.document', :count => 20)
  end

  def test_facets
    visit '/?utf8=✓&q=&search_field=all_fields'
    assert page.has_selector?("#facets")
    within("#facets") do
      assert page.has_content?("Place")
      assert page.has_content?("Genre")
      assert page.has_content?("Year")
      assert page.has_content?("Subject")
      assert page.has_content?("Time Period")
      assert page.has_no_content?("Collection")
      assert page.has_content?("Publisher")
      assert page.has_content?("Creator")
      assert page.has_content?("Institution")
      assert page.has_content?("Type")
    end
  end

  # Fixtures with date ranges
  # [1874 TO 1912] - VAC9619-001727
  # [1905 TO 1907] - VAC9619-001735
  # [2019 TO 2019] - d6efb1e4d0ca491db8c79e5b18c4dee9_3

  def test_date_range_outside_values
    # Returns zero results outside of range
    # Search 1865 - 1872
    # Expect 0 results
    visit '/?utf8=%E2%9C%93&search_field=all_fields&q=&range%5Bsolr_year_i%5D%5Bbegin%5D=1865&range%5Bsolr_year_i%5D%5Bend%5D=1872&commit=Limit'
    assert page.has_content?("No entries found")
  end

  def test_date_range_first_values
    # Returns search for first year
    # Search 1874 - 1874
    # Expect 1 result
    visit '/?utf8=%E2%9C%93&search_field=all_fields&q=&range%5Bsolr_year_i%5D%5Bbegin%5D=1874&range%5Bsolr_year_i%5D%5Bend%5D=1874&commit=Limit'
    assert page.assert_selector('article.document', :count => 1)
    assert page.assert_selector('div[data-layer-id="VAC9619-001727"]')
  end

  def test_date_range_last_values
    # Returns results for last year
    # Search 1912 - 1912
    # Expect 1 result
    visit '/?utf8=%E2%9C%93&search_field=all_fields&q=&range%5Bsolr_year_i%5D%5Bbegin%5D=1912&range%5Bsolr_year_i%5D%5Bend%5D=1912&commit=Limit'
    assert page.assert_selector('article.document', :count => 1)
    assert page.assert_selector('div[data-layer-id="VAC9619-001727"]')
  end

  def test_date_range_bookend_values
    # Returns results at bookends
    # Search 1874 - 1912
    # Expect 2 results
    visit '/?utf8=✓&search_field=all_fields&q=&range%5Bsolr_year_i%5D%5Bbegin%5D=1874&range%5Bsolr_year_i%5D%5Bend%5D=1912&commit=Limit'
    assert page.assert_selector('article.document', :count => 2)
    assert page.assert_selector('div[data-layer-id="VAC9619-001735"]')
    assert page.assert_selector('div[data-layer-id="VAC9619-001727"]')
  end

  def test_date_range_overlapping_values
    # Returns overlapping results
    # Search 1904 - 1908
    # Expect to include two docs
    visit '/?utf8=%E2%9C%93&search_field=all_fields&q=&range%5Bsolr_year_i%5D%5Bbegin%5D=1904&range%5Bsolr_year_i%5D%5Bend%5D=1908&commit=Limit'
    assert page.assert_selector('article.document', :count => 2)
    assert page.assert_selector('div[data-layer-id="VAC9619-001735"]')
    assert page.assert_selector('div[data-layer-id="VAC9619-001727"]')
  end

  def test_date_range_empty_start_value
    # Returns overlapping results
    # Search  - 1900
    # Expect 1 result
    visit '/?utf8=✓&q=&search_field=all_fields&range%5Bsolr_year_i%5D%5Bbegin%5D=&range%5Bsolr_year_i%5D%5Bend%5D=1875&commit=Limit'
    assert page.assert_selector('article.document', :count => 1)
    assert page.assert_selector('div[data-layer-id="VAC9619-001727"]')
  end

  def test_date_range_empty_end_values
    # Returns overlapping results
    # Search 1874 -
    # Expect 3 results
    visit '/?utf8=✓&q=&search_field=all_fields&range%5Bsolr_year_i%5D%5Bbegin%5D=1874&range%5Bsolr_year_i%5D%5Bend%5D=&commit=Limit'
    assert page.assert_selector('article.document', :count => 3)
    assert page.assert_selector('div[data-layer-id="VAC9619-001735"]')
    assert page.assert_selector('div[data-layer-id="VAC9619-001727"]')
    assert page.assert_selector('div[data-layer-id="d6efb1e4d0ca491db8c79e5b18c4dee9_3"]')
  end
end
