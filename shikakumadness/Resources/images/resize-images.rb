#!/usr/bin/env ruby

# Get all images in current directory + subdirectories
images = Dir['**/*.png']

# Parameters for ImageMagick
filter = 'Catrom'
radius = '1'
sigma = '0.0'

# Convert -hd-ipad (4x) images down to -hd (2x)
images.each { |filename|
    # Only process "-hd-ipad" images
    next if !filename.index('-hd-ipad.png')
    
    # Determine base filename/extension
    filename_base, filename_extension = filename.split('.')
    
    # Strip out the '-hd' bit in the filename, in order to create the SD file
    filename_base.sub!('-hd-ipad', '-hd')
    
    # Run ImageMagick shell command to sharpen image, then halve its' size before saving w/o the "-hd" extension
    `convert #{filename} -sharpen #{radius}x#{sigma} -filter #{filter} -resize 50% #{filename_base}.#{filename_extension}`
	
	# Just for sanity, print out what is being done here
	puts "Downsampling #{filename} to #{filename_base}.#{filename_extension}"
}

# Get the newly created -hd images
images = Dir['**/*.png']

# Convert -hd (2x) down to 1x
images.each { |filename|
  # Only process "hd" images
  next if !filename.index('-hd.png')

  # Determine base filename/extension
  filename_base, filename_extension = filename.split('.')

  # Strip out the '-hd' bit in the filename, in order to create the SD file
  filename_base.sub!('-hd', '')

  # Run ImageMagick shell command to sharpen image, then halve its' size before saving w/o the "-hd" extension
  `convert #{filename} -sharpen #{radius}x#{sigma} -filter #{filter} -resize 50% #{filename_base}.#{filename_extension}`
	
	# Just for sanity, print out what is being done here
	puts "Downsampling #{filename} to #{filename_base}.#{filename_extension}"
}