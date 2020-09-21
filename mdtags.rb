#!/usr/bin/env ruby
# ---------------------------------------------------------------------------
# This script reads the 'tags' which are defined in the metadata section
# of a markdown file and writes them as finder tags using openmeta.
#
# The metadata section of a markdown file is set at the top of the file
# with key:value lines. So the tags must be set with a line like this:
#
# tags: #tag1 #tag2 #tag3 ...
#
# tags start with a '#' character. Multiple tags are separated by spaces.
# The metadata section ends with the first empty line.
#
# Mario Zimmermann <mail@zisoft.de>
# 2020-09-21
# ---------------------------------------------------------------------------


# Recursively check for files which were modified within the last 30 seconds
Dir.glob(["**/*.md","**/*.txt"]).select{|f| Time.now - File.mtime(f) < 30 }.each do |filename|
  tagline = ""

  File.open(filename, "r") do |file|
    while line = file.gets.to_s.chomp.strip
      # Search the meta section for the 'tags:' keyword
      # The markdown meta section ends on the first empty line
      tagline = line if line =~ /tags:/
      break if line.empty? || !tagline.empty?
    end
  end

  next if tagline.empty?  # no tags found

  # Extract the tags and remove the leading '#' character
  tags = tagline.split("tags:").last.split(" ").map{|t| t.strip.gsub("#","")}
  tags.reject!{|t| t.nil?}

  # read existing tags of the file
  output = `mdls -raw -name kMDItemUserTags "#{filename}"`
  output.gsub!("(","")
  output.gsub!(")","")
  output.gsub!(",","")
  current_tags = output.split("\n").select{|s| !s.empty?}.map{|s| s.strip}
  
  current_tags.sort!.uniq!
  tags.sort!.uniq!

  if current_tags.size != tags.size || current_tags & tags != current_tags 
    # differences found, write tags for the file

    # create plist
    plist = %Q{<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">}
  
    tags.map! {|tag|
      "<string>#{tag}</string>"
    }

    plist += %Q{<plist version="1.0"><array>#{tags.join()}</array></plist>}

    # Write tags to file
    %x{xattr -w com.apple.metadata:_kMDItemUserTags '#{plist}' '#{File.expand_path(filename)}'}
  end

end
