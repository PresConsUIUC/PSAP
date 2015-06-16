class StaticPage < ActiveRecord::Base

  class Component
    HELP = 'help'
    FORMAT_ID_GUIDE = 'format_id_guide'
    USER_MANUAL = 'user_manual'
  end

  before_save :update_searchable_html

  def to_param
    uri_fragment
  end

  ##
  # Performs a PostgreSQL full-text search on the static_pages table.
  #
  # @param query [String] Query string
  # @param component [StaticPage::Component]
  # @param min_words [Integer]
  # @param max_words [Integer]
  # @return [PG::Result]
  #
  def self.full_text_search(query, component, min_words = 40, max_words = 41,
      max_fragments = 3)
    query = query.delete('\'":|!@#$%^*()') # strip certain characters
    query = query.gsub('&', ' ') # "B&W" won't return anything but "B W" will
    query = query.gsub(' ', ' & ') # replace spaces with boolean AND
    query = StaticPage.sanitize(query)

    # limit/offset are not configurable because there are not enough potential
    # results to warrant it. And there is no need to explicitly call ts_rank
    # because queries that use the GIN index will automatically order by
    # ts_rank desc.
    sql = "SELECT id, "\
      "ts_headline(searchable_html, keywords, "\
        "'MaxFragments=#{max_fragments},MaxWords=#{max_words},"\
        "MinWords=#{min_words},StartSel=<mark>,StopSel=</mark>') AS highlight "\
    "FROM static_pages, to_tsquery(#{query}) as keywords "\
    "WHERE searchable_html @@ keywords AND component = '#{component}' "\
    "LIMIT 50;"

    ActiveRecord::Base.connection.execute(sql)
  end

  ##
  # Copies the "html" property into the "searchable_html" property, stripping
  # headings, images, etc. before stripping tags.
  #
  def update_searchable_html
    doc = Nokogiri::HTML.fragment(html)
    %w(img a h1 h2 h3 h4 h5 h6 th dt).each do |tag|
      doc.search(tag).remove
    end
    self.searchable_html = ActionController::Base.helpers.
        strip_tags(doc.to_html).gsub(/\s+/, ' ').tr("\"\n", '').gsub('()', '')
  end

end
