#!/usr/bin/env ruby

require 'optimist'
require 'pathname'

PART_ID_REGEX = /(.*?)\s*pt\.?\s*(\d*)(\..*)/

opts = Optimist::options do
    opt :filename, "filename to base concat off of", type: :string
    opt :output_ext, "Output file extension", default: '.m4v'
    opt :crop, "crop to dimensions 'w:h:x:y'", type: :string
    opt :trim, "trim intro from 2nd, 3rd... in seconds", default: 0
end

filename  = Pathname.new(opts[:filename]).basename
directory = Pathname.new(opts[:filename]).cleanpath.parent.realpath

if !(match = PART_ID_REGEX.match(filename.to_s))
    STDERR.puts("Could not parse filename for part: '#{opts[:filename]}'")
    exit
end

final_filename = directory + 'converted/' + (match[1] + opts[:output_ext])

files = directory.glob(match[1].gsub('[', '\[').gsub(']', '\]') + '*')
                 .select { |x| x.file?  }
                 .sort_by { |x| PART_ID_REGEX.match(x.to_s)[2].to_i(base=10) }

final_command = ['ffmpeg ']

files.each { |x| final_command << "-i \"#{x.to_s.gsub('"', '\"')}\" "}

final_command << '-filter_complex "'

files.each_with_index do |_, i|
    trim = i == 0 ? 0 : opts[:trim]

    final_command << "[#{i}:v]"
    final_command << "setpts=PTS-STARTPTS"
    final_command << ",trim=start=#{trim}"
    final_command << ",crop=#{opts[:crop]}" if opts[:crop_given]
    final_command << "[v#{i}]; "

    final_command << "[#{i}:a]"
    final_command << "asetpts=PTS-STARTPTS"
    final_command << ",atrim=start=#{trim}" if 0 != trim
    final_command << "[a#{i}]; "
end

files.each_with_index { |_, i| final_command << "[v#{i}][a#{i}]" }
final_command << "concat=n=#{files.size}:v=1:a=1[out]\""

final_command << " -c:v libx264 -crf 15 -preset veryslow -map \"[out]\" \"#{final_filename.to_s.gsub('"', '\"')}\" "

puts final_command.join
