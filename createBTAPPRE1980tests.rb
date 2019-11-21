require 'fileutils'
all_files = Dir[Dir.pwd.to_s + "/*"]
all_files.each do |each_file|
  puts 'hello'
  unless /NECB2011/.match(each_file.to_s).nil? || /expected/.match(each_file.to_s).nil?
    out_loc = /NECB2011/ =~ each_file.to_s
    out_file_name = each_file[0..out_loc-1] + "BTAPPRE1980" + each_file.to_s[out_loc+8..-1]
    in_data = File.read(each_file.to_s)
    out_file = File.open(out_file_name, 'w') { |file| file.write(in_data)}
  end
end
puts 'hello'