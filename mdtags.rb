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
# 2020-03-20
# ---------------------------------------------------------------------------


# Path to the openmeta binary
OPENMETA = "/usr/local/bin/openmeta"

# Check for files which were modified within the last 10 seconds
Dir.glob(["*.md","*.txt"]).select{|f| Time.now - File.mtime(f) < 1000 }.each do |filename|

  tagline = ""

  File.open(filename, "r") do |file|
    while line = file.gets.chomp.strip
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

  # read existing openmeta tags of the file
  output = `#{OPENMETA} -p "#{filename}"`
  exit if output.to_s.empty?

  current_tags = output.split("\n").select{|line| line =~ /^tags: /}.first
  current_tags = current_tags.gsub("tags: ","").split(" ")
  
  current_tags.sort!.uniq!
  tags.sort!.uniq!

  if current_tags.size != tags.size || current_tags & tags != current_tags 
    # differences found, write tags for the file
    result = `#{OPENMETA} -s #{tags.join(' ')} -p "#{filename}"`
  end

end
