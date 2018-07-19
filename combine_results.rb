require 'json'
require 'csv'

class Combine_results
  csv_in = Array.new(3)
  csv_in[0] = "./simulations_20180703_out_ag.csv"
  csv_in[1] = "./simulations_20180628_out_ag.csv"
  csv_in[2] = "./simulations_20180623_scale1_noa_mout_ag.csv"
  csv_out = csv_in[0][0, (csv_in[0].length - 4)] + "_comb.csv"
  csv_infoa = CSV.read(csv_in[0])
  csv_infob = CSV.read(csv_in[1])
  csv_infoc = CSV.read(csv_in[2])
  csv_comb = []
  indexc = 0
  for i in 0..15
    for b in 0..66
      indexa = b + (i*2)*67
      indexb = indexa + 67
      csv_comb << [csv_infoa[indexa][0], csv_infoa[indexa][1], csv_infob[indexa][0], csv_infob[indexa][1], csv_infoc[indexc][0], csv_infoc[indexc][1], csv_infob[indexb][0], csv_infob[indexb][1], csv_infoa[indexb][0], csv_infoa[indexb][1]]
      indexc += 1
    end
	csv_comb << " "
  end
  CSV.open(csv_out, "w") do |csv_line|
    csv_comb.each do |out|
      csv_line << [out[0], out[1], out[2], out[3], out[4], out[5], out[6], out[7], out[8], out[9]]
      test = 1
    end
  end
end