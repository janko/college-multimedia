helpers do
  def upload_image(hash)
    File.write(image_path(hash[:filename]), hash[:tempfile].read)
    system "convert #{image_path} -resize '600x400^' -gravity center -crop '600x400+0+0' #{image_path}"
    File.write(processed_image_path, File.read(image_path))
  end

  def image_path(filename = nil)
    if filename
      extension = File.extname(filename)
      File.join(settings.uploads_dir, "original#{extension}")
    else
      Dir[File.join(settings.uploads_dir, "original.*")].first
    end
  end

  def image_filename
    File.basename(image_path)
  end

  def partial(name, locals = {})
    haml :"_#{name}", locals: locals
  end

  def apply_effects(effects)
    effects.map! do |effect|
      case effect
      when "grayscale"  then "-colorspace gray"
      when "blur"       then "-blur 0x2"
      when "blue"       then "+level-colors NavyBlue,"
      when "pixelate"   then "-scale 10% -scale 1000%"
      when "binoculars" then "-background black -vignette 50x65000"
      when "paint"      then "-morphology CloseI Disk:2.5"
      when "stamp"      then "#{stamp_image_path} -geometry +250+150 -composite"
      when "circles"    then "#{circles_image_path} -compose multiply -composite"
      when "split"      then "-crop 40x40 -set page \'+%[fx:page.x+10*page.x/40]+%[fx:page.y+10*page.y/40]\' -background white -layers merge +repage"
      else
        raise "effect not recognized: #{effect}"
      end
    end

    system "convert #{image_path} #{effects.join(" ")} #{processed_image_path}"
  end

  def processed_image_path
    extension = File.extname(image_path)
    File.join(settings.uploads_dir, "processed#{extension}")
  end

  def processed_image_filename
    File.basename(processed_image_path)
  end

  def stamp_image_path
    File.join(settings.uploads_dir, "watermark.gif")
  end

  def circles_image_path
    File.join(settings.uploads_dir, "circles.png")
  end

  def delete_image
    File.delete(processed_image_path)
    File.delete(image_path)
  end
end
