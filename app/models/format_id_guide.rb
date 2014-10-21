##
# Used by the psap:*_fidg rake tasks.
#
class FormatIdGuide

  FOLDER = 'db/seed_data/FormatIDGuide-HTML'
  # psap:process_fidg and psap:seed_fidg need to be re-run after changing this.
  PROFILES = [
      {
          quality: 60,
          size: 300
      },
      {
          quality: 75,
          size: 1000
      }
  ]
  IMAGE_EXTENSIONS = %w(jpg jpeg png tif tiff)
  VIDEO_EXTENSIONS = %w(mp4 webm)

  def initialize
    @referenced_images = [] # images that are referenced in src attributes
    @missing_images = [] # referenced images that don't exist on disk
  end

  def process_images
    # TODO: also process vp8 video derivatives, e.g.: ffmpeg -i Carbon_02.mp4 -acodec libvorbis -ab 64k -c:v vp8 -b:v 1500k Carbon_02.webm

    tmppath = '/tmp/fidg.tmp.html'
    Dir.glob(FOLDER + '/**/*.htm*', File::FNM_CASEFOLD).each do |htmlpath|
      changed = false
      File.open(htmlpath, 'r') { |html|
        puts "**** #{htmlpath}"
        doc = Nokogiri::HTML(html)
        doc.css('img').each do |img|
          img_path = path_of_image(File.basename(img['src']))
          @referenced_images << img_path if img_path
          unless File.basename(img['src'], '.*').end_with?('-300')
            if generate_images_for(File.basename(img['src']))
              newimgsrc = File.join('images',
                                    File.basename(img['src'], '.*') + '-300' +
                                        File.extname(img['src']).downcase)
              img['src'] = newimgsrc
              dimensions = `convert "#{path_of_image(File.basename(newimgsrc))}" -ping -format '%[fx:w]|%[fx:h]' info:`.strip.split('|')
              img['width'] = dimensions[0]
              img['height'] = dimensions[1]
              changed = true
            end
          end
        end
        if changed
          File.open(tmppath, 'w') { |tmpfile|
            tmpfile << doc.to_html
          }
        end
      }
      FileUtils.mv(tmppath, htmlpath) if changed and File.exists?(tmppath)
    end

    puts "Missing images:\n" + @missing_images.join("\n") + "\n\n"
    puts "Unused images:\n" + unused_images.join("\n")
  end

  ##
  # @param image_filename An image filename from an <img src> tag, like
  # image-300.jpg
  #
  def generate_images_for(image_filename)
    imgsrcpath = path_of_image(image_filename)
    if imgsrcpath
      puts File.basename(imgsrcpath)
      imgsrcdirname = File.dirname(imgsrcpath)
      imgsrcbasename = File.basename(imgsrcpath, '.*')
      imgsrcextname = File.extname(imgsrcpath)

      if File.exists?(File.join(imgsrcdirname, imgsrcbasename + '@2x' + imgsrcextname))
        imgsrcpath = File.join(imgsrcdirname, imgsrcbasename + '@2x' + imgsrcextname)
      end

      PROFILES.each do |profile|
        non_retina_pathname = File.join(
            imgsrcdirname, "#{imgsrcbasename}-#{profile[:size]}#{imgsrcextname.downcase}")
        retina_pathname = File.join(
            imgsrcdirname, "#{imgsrcbasename}-#{profile[:size]}@2x#{imgsrcextname.downcase}")

        unless File.exists?(non_retina_pathname)
          system "convert \"#{imgsrcpath}\" -quality #{profile[:quality]} "\
          "-colorspace RGB -resize #{profile[:size]}x#{profile[:size]} "\
          "\"#{non_retina_pathname}\""
        end
        unless File.exists?(retina_pathname)
          system "convert \"#{imgsrcpath}\" -quality #{profile[:quality]} "\
          "-colorspace RGB -resize #{profile[:size] * 2}x#{profile[:size] * 2} "\
          "\"#{retina_pathname}\""
        end
      end

      newimgsrcpath = imgsrcpath.gsub('@2x', '')
      FileUtils.mv(imgsrcpath, newimgsrcpath) if imgsrcpath != newimgsrcpath
      return true
    end
    @missing_images << image_filename if image_filename
    false
  end

  def path_of_image(filename)
    IMAGE_EXTENSIONS.each do |ext|
      Dir.glob(File.join(FOLDER, '**', '*.' + ext), File::FNM_CASEFOLD).each do |path|
        return path if File.basename(path).downcase == filename.downcase
      end
    end
    nil
  end

  def reseed
    StaticPage.destroy_all # TODO: destroy only FIDG pages
    fidg_images_path = File.join(Rails.root, 'app', 'assets', 'images',
                                 'format_id_guide')
    FileUtils.rm_rf(fidg_images_path)

    # HTML pages
    Dir.glob(File.join(Rails.root, 'db', 'seed_data', 'FormatIDGuide-HTML', '**', '*.htm*')).each do |file|
      File.open(file) do |contents|
        doc = Nokogiri::HTML(contents)
        html = doc.xpath('//body/*').to_html
        StaticPage.create!(name: doc.at_css('h1').text,
                           format_category: File.basename(file, '.*'),
                           format_class: File.basename(File.dirname(file)),
                           html: html)
      end
    end

    # Images/videos
    FileUtils.mkdir_p(fidg_images_path)
    (IMAGE_EXTENSIONS + VIDEO_EXTENSIONS).each do |ext|
      # File::FNM_CASEFOLD == case insensitive
      Dir.glob(File.join(Rails.root, 'db', 'seed_data', 'FormatIDGuide-HTML', '**', '*.' + ext),
               File::FNM_CASEFOLD).each do |file|
        dest_path = fidg_images_path + '/' +
            File.basename(file, '.*').gsub(' ', '_').gsub('%20', '_') +
            File.extname(file).downcase
        FileUtils.cp(file, dest_path)
        File.chmod(0644, dest_path)
      end
    end
  end

  private

  def master_filename(path)
    name = File.basename(path, '.*').gsub('@2x')
    PROFILES.each do |profile|
      name = name.gsub('-' + profile[:size])
    end
    name
  end

  def unused_images
    unused = []
    IMAGE_EXTENSIONS.each do |ext|
      Dir.glob(File.join(FOLDER, '**', '*.' + ext), File::FNM_CASEFOLD).each do |path|
        master_filename = master_filename(path)
        unused << path unless @referenced_images.map{ |r| master_filename(r) }.
            include?(master_filename)
      end
    end
    unused
  end

end
