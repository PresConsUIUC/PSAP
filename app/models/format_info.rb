class FormatInfo < ActiveRecord::Base

  before_save :update_searchable_html

  def to_param
    format_category
  end

  ##
  # Requires PostgreSQL
  #
  def self.full_text_search(query, min_words = 40, max_words = 41, max_fragments = 3)
    query = query.delete('\'":|!@#$%^*()') # strip certain characters
    query = query.gsub('&', ' ') # "B&W" won't return anything but "B W" will
    query = query.gsub(' ', ' & ') # replace spaces with boolean AND
    query = FormatInfo.sanitize(query)

    # limit/offset are not configurable because there are not enough potential
    # results to warrant it. And there is no need to explicitly call ts_rank
    # because queries that use the GIN index will automatically order by
    # ts_rank desc.
    sql = "SELECT id, "\
      "ts_headline(searchable_html, keywords, "\
        "'MaxFragments=#{max_fragments},MaxWords=#{max_words},"\
        "MinWords=#{min_words},StartSel=<mark>,StopSel=</mark>') AS highlight "\
    "FROM format_infos, to_tsquery(#{query}) as keywords "\
    "WHERE searchable_html @@ keywords "\
    "LIMIT 50;"

    ActiveRecord::Base.connection.execute(sql)
  end

  private

  ##
  # Copies the "html" property into the "searchable_html" property, stripping
  # headings, images, etc. before stripping tags.
  #
  def update_searchable_html
    doc = Nokogiri::HTML.fragment(html)
    %w(img a h1 h2 h3 h4 h5 h6 th dt).each do |tag|
      doc.search(tag).remove
    end
    self.searchable_html = ActionController::Base.
        helpers.strip_tags(doc.to_html).gsub('  ', ' ').tr("\"\n", '')
  end

end
