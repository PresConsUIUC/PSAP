##
# Used by the psap:process_fidg rake task.
#
class FormatIdGuide

  FOLDER = 'db/seed_data/FormatIDGuide-HTML'
  PROFILES = [
      {
          quality: 50,
          size: 300
      },
      {
          quality: 75,
          size: 1000
      }
  ]
  IMAGE_EXTENSIONS = %w(jpg png tif tiff)

  def initialize
    @referenced_images = [] # images that are referenced in src attributes
    @missing_images = [] # referenced images that don't exist on disk
  end

  def process_images
    tmppath = '/tmp/fidg.tmp.html'
    Dir.glob(FOLDER + '/**/*.html').each do |htmlpath|
      changed = false
      File.open(htmlpath, 'r') { |html|
        puts "**** #{htmlpath} ****"
        doc = Nokogiri::HTML(html)
        doc.css('img').each do |img|
          unless File.basename(img['src'], '.*').end_with?('-300')
            if generate_images_for(File.basename(img['src']))
              newimgsrc = File.join('images',
                                    File.basename(img['src'], '.*') + '-300' + File.extname(img['src']))
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

    puts "Missing images:\n" + @missing_images.join("\n") + "\n"
    puts "Unused images:\n" + unused_images.join("\n")
  end

  def generate_images_for(image_filename)
    imgsrcpath = path_of_image(image_filename)
    if imgsrcpath
      puts imgsrcpath
      @referenced_images << imgsrcpath
      imgsrcdirname = File.dirname(imgsrcpath)
      imgsrcbasename = File.basename(imgsrcpath, '.*')
      imgsrcextname = File.extname(imgsrcpath)

      if File.exists?(File.join(imgsrcdirname, imgsrcbasename + '@2x' + imgsrcextname))
        imgsrcpath = File.join(imgsrcdirname, imgsrcbasename + '@2x' + imgsrcextname)
      end

      PROFILES.each do |profile|
        non_retina_pathname = File.join(
            imgsrcdirname, "#{imgsrcbasename}-#{profile[:size]}#{imgsrcextname}")
        retina_pathname = File.join(
            imgsrcdirname, "#{imgsrcbasename}-#{profile[:size]}@2x#{imgsrcextname}")

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
      Dir.glob(FOLDER + '/**/*.' + ext).each do |path|
        return path if File.basename(path) == filename
      end
    end
    nil
  end

  def unused_images
    images = @referenced_images.dup
    IMAGE_EXTENSIONS.each do |ext|
      Dir.glob(FOLDER + '/**/*.' + ext).each do |path|
        images.delete(path)
      end
    end
    images
  end

end
