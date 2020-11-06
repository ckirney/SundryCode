require 'write_xlsx'
require 'roo'
require 'fileutils'
require 'json'

#in_file = './bps_2016_report_english.xlsx'
in_file = './2017_energy_consumption.xlsx'
out_file = './bps_2017.json'
xlsx = Roo::Spreadsheet.open(in_file)
sheet = xlsx.sheet(xlsx.sheets[0])
out_data = []
start_flag = false
for i in 1..sheet.last_row
  row_in = sheet.row(i)
  if row_in[0].to_s.include?("Sector")
    start_flag = true
    next
  end
  next if start_flag == false
  out_data << {
      sector: row_in[0],
      sub_sector: row_in[1],
      organization: row_in[2],
      operation: row_in[3],
      operation_type: row_in[4],
      address: row_in[5],
      city: row_in[6],
      postal_code: row_in[7],
      floorspace: row_in[8],
      floorspace_unit: row_in[9],
      weekly_avg_hours: row_in[10],
      annual_flow: row_in[11],
      num_portables: row_in[12],
      pool: row_in[13],
      elec: row_in[14],
      elec_unit: row_in[15],
      gas: row_in[16],
      gas_unit: row_in[17],
      oil12: row_in[18],
      oil12_unit: row_in[19],
      oil46: row_in[20],
      oil46_unit: row_in[21],
      propane: row_in[22],
      propane_unit: row_in[23],
      coal: row_in[24],
      coal_unit: row_in[25],
      wood: row_in[26],
      wood_unit: row_in[27],
      distheat: row_in[28],
      distheat_unit: row_in[29],
      distheat_renew: row_in[30],
      distheat_renew_emm_fac: row_in[31],
      distcool: row_in[32],
      distcool_unit: row_in[33],
      distcool_renew: row_in[34],
      distcool_renew_emm_fac: row_in[35],
      ghg_kg: row_in[36],
      eui_ekWh_per_sqft: row_in[37],
      eui_ekWh_per_ML: row_in[38],
      eui_GJ_per_m2: row_in[39],
      eui_GJ_per_ML: row_in[40]
  }
end

File.write(out_file, JSON.pretty_generate(out_data))