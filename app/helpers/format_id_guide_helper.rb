module FormatIdGuideHelper

  ##
  # Converts raw Format ID Guide HTML fragments from the form they were
  # imported in to a form that is compatible with the application, fixing
  # image URLs and internal links.
  #
  def format_id_guide_html(raw_html)
    doc = Nokogiri::HTML.fragment(raw_html)

    doc.css('a').each do |anchor|
      # process internal links
      if anchor['href'] and anchor['href'][0..3] != 'http' and
          anchor['href'][0] != '#'
        anchor['href'] = format_id_guide_path + '/' +
            File.basename(anchor['href'], '.*')
      end
    end

    # process images
    doc.css('img').each do |image|
      new_image_filename = File.basename(image['src']).gsub(' ', '_').
          gsub('%20', '_')
      image['data-original'] = image_path(new_image_filename)
      image['src'] = nil
      image['data-lightbox-src'] = image_path(
          new_image_filename.gsub('-300', '-1000'))
    end

    # process videos
    doc.css('video source').each do |video|
      video['src'] = image_path(
          File.basename(video['src']).gsub(' ', '_').gsub('%20', '_'))
    end

    raw(doc.to_html)
  end

end
