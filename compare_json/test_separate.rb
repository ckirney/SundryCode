require 'json'
require 'fileutils'

infile = "./simulations_old.json"
in_data = JSON.parse(File.read(infile))

out_file = "./out_single_old_pretty_1978.json"

File.write(out_file, JSON.pretty_generate(in_data[1978]))