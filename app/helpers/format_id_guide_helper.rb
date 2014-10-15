require 'nokogiri'

module FormatIdGuideHelper

  ##
  # Converts raw Format ID Guide HTML fragments from the form they were
  # imported in to a form that is compatible with the application, fixing
  # image URLs and internal links.
  #
  def format_id_guide_html(raw_html)
    doc = Nokogiri::HTML.fragment(raw_html)

    # process internal links
    doc.css('a').each do |anchor|
      if anchor['href'] and anchor['href'][0..3] != 'http' and
          anchor['href'][0] != '#'
        anchor['href'] = format_id_guide_path + '/' + File.basename(anchor['href'])
      end
    end

    # process images
    doc.css('img').each do |image|
      image['src'] = image_path(File.basename(image['src']))
    end

    raw(doc.to_html)
  end

  ##
  # Excerpts and highlights matches in a given HTML fragment. Ideally we would
  # have PostgreSQL doing this, but this will have to do in the meantime.
  #
  def highlight_matches(html, query)
    margin = 1000

    # strip headings, images, etc.
    doc = Nokogiri::HTML.fragment(html)
    %w(img a h1 h2 h3 h4 h5 h6 th figure dt ul).each do |tag|
      doc.search(tag).remove
    end

    text = strip_tags(doc.to_html)

    # find the position of the first occurrence of the query
    index = text.downcase.index(query.downcase)
    if index
      lower = index - margin > 0 ? index - margin : 0
      upper = index + margin > text.length ? text.length : index + margin
    else
      lower = 0
      upper = margin > text.length ? text.length : margin
    end

    chunk = highlight(text[lower..upper], query) + '...'
    if lower > 0
      chunk = '...' + chunk
    end

    chunk
  end

end
