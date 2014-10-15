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

end
