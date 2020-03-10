require 'fileutils'
require 'json'
require 'csv'

testa = 66
testb = nil
testc = 983

CSV.open("./test_csv.csv", "w") do |csv|
  out_csv = [
      testa,
      testb,
      testc
  ]
  csv << out_csv
  csv << out_csv
end


=begin
post_vint_file = './btap_postvint_2.json'
post_vint = JSON.parse(File.read(post_vint_file))
sort_vint= post_vint.sort_by {|ind_rec| ind_rec["building"]["principal_heating_source"]}
testa = sort_vint[346]
testb = sort_vint[868]
check1 = sort_vint[346]["sql_data"][0]["table"][0]["natural_gas_GJ"]
check2 = sort_vint[346]["sql_data"][0]["table"][0]["electricity_GJ"]
File.write('./sample_postvint2_elec.json', JSON.pretty_generate(testa))
File.write('./sample_postvint2_natgas.json', JSON.pretty_generate(testb))
=end