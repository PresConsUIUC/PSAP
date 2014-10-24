##
# Used by several "psap:" rake tasks to process and ingest Format ID Guide
# content from the HTML files in db/seed_data/FormatIDGuide-HTML.
#
class FormatIdGuide

  SOURCE_PATH = File.join(Rails.root, 'db', 'seed_data', 'FormatIDGuide-HTML')
  ASSET_PATH = File.join(Rails.root, 'app', 'assets', 'format_id_guide')
  DEST_PATH = ASSET_PATH
  PROFILES = [
      {
          quality: 70,
          width: 320, # max
          height: 320, # max
          type: 'thumb'
      },
      {
          quality: 80,
          width: 1500, # max
          height: 1000, # max
          type: 'full'
      }
  ]
  IMAGE_EXTENSIONS = %w(jpg jpeg png tif tiff)
  VIDEO_EXTENSIONS = %w(mp4 webm)

  def initialize
    @referenced_images = [] # images that are referenced in src attributes
    @missing_images = [] # referenced images that don't exist on disk
  end

  ##
  # Iterates through all of the HTML files in search of <img> tags, and
  # generates derivative images based on their "src" attributes.
  #
  def generate_derivatives
    FileUtils.rm_rf(ASSET_PATH) if File.exists?(ASSET_PATH)
    FileUtils.mkdir_p(ASSET_PATH)

    Dir.glob(File.join(SOURCE_PATH, '**', '*.htm*'), File::FNM_CASEFOLD).each do |htmlpath|
      File.open(htmlpath, 'r') { |content|
        doc = Nokogiri::HTML(content)
        # images
        doc.css('img').each do |img|
          source_img_path = source_path_of_file(File.basename(img['src']))
          @referenced_images << source_img_path if source_img_path
          generate_images_for(File.basename(img['src']))
        end
        # videos
        doc.css('video source').each do |video|
          if video['type'] == 'video/mp4'
            source_video_path = source_path_of_file(File.basename(video['src']))
            @referenced_images << source_video_path if source_video_path
            generate_images_for(File.basename(video['src']))
          end
        end
      }
    end
    puts "Missing images:\n" + @missing_images.join("\n") + "\n\n"
    puts "Unused images:\n" + unused_images.join("\n")
  end

  ##
  # Generates derivative images for a given image, saving them in the assets
  # folder.
  #
  # @param image_filename An image filename from an <img src> tag
  # @return Boolean True if the image was generated; false if the image in the
  # src tag is missing on disk
  #
  def generate_images_for(image_filename)
    source_image_path = source_path_of_file(image_filename)
    if source_image_path
      imgsrcbasename = File.basename(source_image_path, '.*')
      imgsrcextname = File.extname(source_image_path)
      FileUtils.mkdir_p(ASSET_PATH)

      PROFILES.each do |profile|
        non_retina_dest_pathname = File.join(
            ASSET_PATH, "#{imgsrcbasename}-#{profile[:width]}#{imgsrcextname.downcase}")
        retina_dest_pathname = File.join(
            ASSET_PATH, "#{imgsrcbasename}-#{profile[:width]}@2x#{imgsrcextname.downcase}")

        unless File.exists?(non_retina_dest_pathname)
          # \> will resize only larger-to-smaller
          system "convert \"#{source_image_path}\" -quality #{profile[:quality]} "\
          "-strip -resize #{profile[:width]}x#{profile[:height]}\\> "\
          "\"#{non_retina_dest_pathname}\""
        end
        unless File.exists?(retina_dest_pathname)
          system "convert \"#{source_image_path}\" -quality #{profile[:quality]} "\
          "-strip -resize #{profile[:width] * 2}x#{profile[:height] * 2}\\> "\
          "\"#{retina_dest_pathname}\""
        end
      end
      return true
    end
    @missing_images << image_filename if image_filename
    false
  end

  ##
  # @param video_filename A video filename from a <source src> tag
  # @return Boolean True if the video was generated; false if the video in the
  # src tag is missing on disk
  #
  def generate_videos_for(video_filename)
    videosrcpath = source_path_of_file(video_filename)
    if videosrcpath
      videosrcbasename = File.basename(videosrcpath, '.*')
      videodestpath = File.join(ASSET_PATH, "#{videosrcbasename}.webm")

      # WebM/VP8
      unless File.exists?(videodestpath)
        `ffmpeg -i #{videosrcpath} -loglevel panic -acodec libvorbis -ab 64k -c:v vp8 -b:v 1500k #{videodestpath}`
      end
      return true
    end
    @missing_images << video_filename if video_filename
    false
  end

  def source_path_of_file(filename)
    (IMAGE_EXTENSIONS + VIDEO_EXTENSIONS).each do |ext|
      Dir.glob(File.join(SOURCE_PATH, '**', '*.' + ext), File::FNM_CASEFOLD).each do |path|
        return path if File.basename(path).downcase == filename.downcase
      end
    end
    nil
  end

  def reseed
    StaticPage.where('format_class IS NOT NULL').destroy_all

    # HTML pages
    Dir.glob(File.join(SOURCE_PATH, '**', '*.htm*'), File::FNM_CASEFOLD).each do |file| # File::FNM_CASEFOLD == case insensitive
      File.open(file) do |contents|
        doc = Nokogiri::HTML(contents)
        # inject image widths & heights
        doc.css('img').each do |img|
          thumb_width = PROFILES.select{ |p| p[:type] == 'thumb' }[0][:width]
          img['src'] = "#{File.basename(img['src'], '.*')}-#{thumb_width}#{File.extname(img['src']).downcase}"
          dimensions = `convert "#{ASSET_PATH}/#{File.basename(img['src'])}" -ping -format '%[fx:w]|%[fx:h]' info:`.strip.split('|')
          img['width'] = dimensions[0]
          img['height'] = dimensions[1]
        end

        # add other video formats
        doc.css('video').each do |video|
          source = Nokogiri::XML::Node.new('source', doc)
          source['src'] = "#{File.basename(video.children[0]['src'], '.*')}.webm"
          source['type'] = 'video/webm'
          video.add_child(source)
        end

        html = doc.xpath('//body/*').to_html
        StaticPage.create!(name: doc.at_css('h1').text,
                           uri_fragment: File.basename(file, '.*'),
                           format_class: File.basename(File.dirname(file)),
                           html: html)
      end
    end

    # Copy source videos
    # File::FNM_CASEFOLD == case insensitive
    Dir.glob(File.join(SOURCE_PATH, '**', '*.mp4'),
             File::FNM_CASEFOLD).each do |file|
      dest_path = ASSET_PATH + '/' + File.basename(file)
      FileUtils.cp(file, dest_path)
      File.chmod(0644, dest_path)
    end
  end

  private

  ##
  # Takes a pathname like /path/to/image-300.jpg or /path/to/image-300@2x.jpg
  # and returns the master filename: image.jpg.
  #
  def master_filename(path)
    name = File.basename(path, '.*').gsub('@2x', '')
    PROFILES.each do |profile|
      name = name.gsub("-#{profile[:width]}", '')
    end
    name
  end

  def unused_images
    unused = []
    IMAGE_EXTENSIONS.each do |ext|
      # File::FNM_CASEFOLD == case insensitive
      Dir.glob(File.join(SOURCE_PATH, '**', '*.' + ext), File::FNM_CASEFOLD).each do |path|
        unused << path unless @referenced_images.map{ |r| master_filename(r) }.
            include?(master_filename(path))
      end
    end
    unused
  end

end
