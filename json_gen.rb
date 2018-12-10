require 'json'

class Json_pipe_gen
  piping = []
  piping << {
      ahu_airflow_range_Literpers: [0, 1000],
      heat_valve_pipe_dia_inch: 1.0,
      cool_valve_pipe_dia_inch: 1.25
  }
  piping << {
      ahu_airflow_range_Literpers: [1000, 2500],
      heat_valve_pipe_dia_inch: 1.25,
      cool_valve_pipe_dia_inch: 1.5
  }
  piping << {
      ahu_airflow_range_Literpers: [2500, 4000],
      heat_valve_pipe_dia_inch: 1.5,
      cool_valve_pipe_dia_inch: 2.0
  }
  piping << {
      ahu_airflow_range_Literpers: [4000, 6000],
      heat_valve_pipe_dia_inch: 2.0,
      cool_valve_pipe_dia_inch: 2.5
  }
  piping << {
      ahu_airflow_range_Literpers: [6000, 8000],
      heat_valve_pipe_dia_inch: 2.0,
      cool_valve_piep_dia_inch: 2.5
  }
  piping << {
      ahu_airflow_range_Literpers: [8000, 12000],
      heat_valve_pipe_dia_inch: 2.5,
      cool_valve_pipe_dia_inch: 3.0
  }
  piping << {
      ahu_airflow_range_Literpers: [12000, 15000],
      heat_valve_pipe_dia_inch: 3.0,
      cool_valve_pipe_dia_inch: 4.0
  }
  duct = []
  duct << {
      max_flow_range_m3pers: [0, 0.35],
      duct_dia_inch: 8
  }
  duct << {
      max_flow_range_m3pers: [0.35, 0.59],
      duct_dia_inch: 10
  }
  duct << {
      max_flow_range_m3pers: [0.59, 0.94],
      duct_dia_inch: 12
  }
  duct << {
      max_flow_range_m3pers: [0.94, 1.39],
      duct_dia_inch: 14
  }
  duct << {
      max_flow_range_m3pers: [1.39, 1.95],
      duct_dia_inch: 16
  }
  duct << {
      max_flow_range_m3pers: [1.95, 2.75],
      duct_dia_inch: 18
  }
  duct << {
      max_flow_range_m3pers: [2.75, 3.8],
      duct_dia_inch: 20
  }
  duct << {
      max_flow_range_m3pers: [3.8, 4.7],
      duct_dia_inch: 22
  }
  duct << {
      max_flow_range_m3pers: [4.7, 5.9],
      duct_dia_inch: 24
  }
  duct << {
      max_flow_range_m3pers: [5.9, 9.5],
      duct_dia_inch: 30
  }
  duct << {
      max_flow_range_m3pers: [9.5, 9999],
      duct_dia_inch: 36
  }
  duct_cost = []
  duct_cost << {
      max_flow_range_m3pers: [0, 0.094],
      diff_num: 2,
      duct_weight_lbs: 55,
      duct_ins_ft2: 40,
      flex_duct_LinFt: 16
  }
  duct_cost << {
      max_flow_range_m3pers: [0.094, 0.188],
      diff_num: 3,
      duct_weight_lbs: 125,
      duct_ins_ft2: 96,
      flex_duct_LinFt: 24
  }
  duct_cost << {
      max_flow_range_m3pers: [0.188, 0.283],
      diff_num: 4,
      duct_weight_lbs: 190,
      duct_ins_ft2: 144,
      flex_duct_LinFt: 32
  }
  duct_cost << {
      max_flow_range_m3pers: [0.283, 0.377],
      diff_num: 4,
      duct_weight_lbs: 225,
      duct_ins_ft2: 196,
      flex_duct_LinFt: 32
  }
  duct_cost << {
      max_flow_range_m3pers: [0.377, 0.472],
      diff_num: 5,
      duct_weight_lbs: 290,
      duct_ins_ft2: 224,
      flex_duct_LinFt: 40
  }
  duct_cost << {
      max_flow_range_m3pers: [0.472, 0.59],
      diff_num: 6,
      duct_weight_lbs: 395,
      duct_ins_ft2: 306,
      flex_duct_LinFt: 48
  }
  duct_cost << {
      max_flow_range_m3pers: [0.59, 0.707],
      diff_num: 6,
      duct_weight_lbs: 495,
      duct_ins_ft2: 380,
      flex_duct_LinFt: 48
  }
  duct_cost << {
      max_flow_range_m3pers: [0.707, 0.944],
      diff_num: 8,
      duct_weight_lbs: 795,
      duct_ins_ft2: 528,
      flex_duct_LinFt: 64
  }
  duct_cost << {
      max_flow_range_m3pers: [0.944, 999],
      diff_num: 0.12,
      duct_weight_lbs: 40,
      duct_ins_ft2: 25,
      flex_duct_LinFt: 10
  }
  output = []
  output << {
      component: 'piping',
      table: piping
  }
  output << {
      component: 'trunk',
      table: duct
  }
  output << {
      component: 'diff_duct',
      table: duct_cost
  }
  File.open('./mech_sizing.json', 'w') {|out| out.write(JSON.pretty_generate(output))}
end