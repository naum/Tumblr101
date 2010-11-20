#!/usr/bin/env ruby
# This script will download all images referenced in URL (URLs ending in
# jpg/gif/png), stick them in an images/ directory if they're not already there,
# and make a new file referencing the local directory.
#
# The script depends on the http://github.com/nahi/httpclient library.
# 
# USAGE
# localiseImages.rb index.html
# ... will create images/ containing images and local.index.html pointing to them.
#
# The point is to cache images so your HTML works offline. See also spa.py
# http://mini.softwareas.com/using-fnds-excellent-spapy-to-make-a-single-p

require 'rubygems'
require 'httpclient'

### UTILITIES
IMAGES_DIR = 'images'
Dir.mkdir(IMAGES_DIR) unless File.directory?(IMAGES_DIR)
def filenameize(url)
  IMAGES_DIR + '/' + url.sub('http://','').gsub('/','__')
end

def save(filename,contents)
  file = File.new(filename, "w")
  file.write(contents)
  file.close
end

### CORE
def saveImage(url)
  save(filenameize(url), HTTPClient.new().get_content(url))
end

def extractImages(filename)
  contents = File.open(filename, "rb").read
  localContents = String.new(contents)
  contents.scan(/http:\/\/\S+?\.(?:jpg|gif|png)/im) { |url|
    puts url
    saveImage(url) unless File.file?(filenameize(url))
    localContents.gsub!(url, filenameize(url))
  }
  save("local."+filename, localContents)
end

### COMMAND-LINE
extractImages(ARGV[0])
