require 'json'
require 'fileutils'

infile = "./simulations.json"
in_data = JSON.parse(File.read(infile))

out_file = "./out_sim_pretty.json"

File.write(out_file, JSON.pretty_generate(in_data))