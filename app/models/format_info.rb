class FormatInfo < ActiveRecord::Base

  def to_param
    format_category
  end

  ##
  # Requires PostgreSQL
  #
  def self.full_text_search(query, min_words = 50, max_words = 51, max_fragments = 3)
    # There is no limit/offset because there are not enough potential results
    # to warrant it.
    sql = "SELECT id, "\
      "ts_headline(searchable_html, keywords, "\
        "'MaxFragments=#{max_fragments},MaxWords=#{max_words},"\
        "MinWords=#{min_words},StartSel=<mark>,StopSel=</mark>') as highlight "\
    "FROM format_infos, to_tsquery(#{FormatInfo.sanitize(query)}) as keywords "\
    "WHERE searchable_html @@ keywords;"

    ActiveRecord::Base.connection.execute(sql)
  end

  ##
  # Strips headings, images, etc. before stripping tags.
  #
  def self.searchable_html(html)
    doc = Nokogiri::HTML.fragment(html)
    %w(img a h1 h2 h3 h4 h5 h6 th figure dt ul).each do |tag|
      doc.search(tag).remove
    end
    ActionController::Base.helpers.strip_tags(doc.to_html)
  end

end
