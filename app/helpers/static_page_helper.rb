module StaticPageHelper

  ##
  # Converts raw static page HTML fragments from the form they were
  # imported in to a form that is compatible with the application, fixing
  # image URLs and internal links.
  #
  def static_page_html(raw_html)
    doc = Nokogiri::HTML.fragment(raw_html)

    doc.css('a').each do |anchor|
      # process internal links
      if anchor['href'] and !anchor['href'].start_with?('http') and
          !anchor['href'].start_with?('mailto:') and anchor['href'][0] != '#'
        pre_hash = anchor['href'].split('#')
        if pre_hash[0].present?
          if File.basename(pre_hash[0], '.*') == 'bibliography'
            anchor['href'] = bibliography_path
          elsif anchor['href'].start_with?('files/')
            anchor['href'] = root_path + 'files/' + File.basename(pre_hash[0])
          elsif pre_hash[0].start_with?(collection_id_guide_path)
            anchor['href'] = pre_hash[0]
          elsif !pre_hash[0].include?('/')
            anchor['href'] = File.basename(pre_hash[0], '.*')
          else
            anchor['href'] = root_path + File.basename(pre_hash[0])
          end
          anchor['href'] += '#' + pre_hash[1] if pre_hash.length > 1
        end
      end
    end

    # add rights hovertips
    doc.css('figure').each do |figure|
      caption = figure.css('figcaption')[0]   
      if caption
        button = Nokogiri::XML::Node.new('button', doc)
        button['type'] = 'button'
        button['class'] = 'btn btn-sm psap-rights'
        button['data-toggle'] = 'popover'
        button['data-placement'] = 'bottom'
        button['data-content'] = caption.inner_html     
        button.content = 'i'
        caption.after(button)
      end
    end

    # process images
    doc.css('img').each do |image|
      new_image_filename = File.basename(image['src']).gsub(' ', '_').
          gsub('%20', '_')
      image['data-original'] = image_path(new_image_filename)
      image['data-at2x'] = retina_image_path(new_image_filename)
      image['src'] = nil

      thumb_profile = StaticPageImporter::PROFILES.select{ |p| p[:type] == 'thumb' }.first
      full_profile = StaticPageImporter::PROFILES.select{ |p| p[:type] == 'full' }.first
      image['data-lightbox-src'] = image_path(
          new_image_filename.gsub("-#{thumb_profile[:width]}",
                                  "-#{full_profile[:width]}"))
      image['data-retina-lightbox-src'] = retina_image_path(
          new_image_filename.gsub("-#{thumb_profile[:width]}",
                                  "-#{full_profile[:width]}"))
    end

    # process videos
    doc.css('video source').each do |video|
      video['src'] = image_path(
          File.basename(video['src']).gsub(' ', '_').gsub('%20', '_'))
    end

    raw(doc.to_html)
  end

end
