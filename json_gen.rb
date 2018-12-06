require 'json'

class Json_pipe_gen
  output = []
  output << {
      ahu_airflow_range_Literpers: [0, 1000],
      heat_valve_pipe_dia_inch: 1.0,
      cool_valve_pip_dia_inch: 1.25
  }
  output << {
      ahu_airflow_range_Literpers: [1000, 2500],
      heat_valve_pipe_dia_inch: 1.25,
      cool_valve_pip_dia_inch: 1.5
  }
  output << {
      ahu_airflow_range_Literpers: [2500, 4000],
      heat_valve_pipe_dia_inch: 1.5,
      cool_valve_pip_dia_inch: 2.0
  }
  output << {
      ahu_airflow_range_Literpers: [4000, 6000],
      heat_valve_pipe_dia_inch: 2.0,
      cool_valve_pip_dia_inch: 2.5
  }
  output << {
      ahu_airflow_range_Literpers: [6000, 8000],
      heat_valve_pipe_dia_inch: 2.0,
      cool_valve_pip_dia_inch: 2.5
  }
  output << {
      ahu_airflow_range_Literpers: [8000, 12000],
      heat_valve_pipe_dia_inch: 2.5,
      cool_valve_pip_dia_inch: 3.0
  }
  output << {
      ahu_airflow_range_Literpers: [12000, 15000],
      heat_valve_pipe_dia_inch: 3.0,
      cool_valve_pip_dia_inch: 4.0
  }
  File.open('./pipe_size.json', 'w') {|out| out.write(JSON.pretty_generate(output))}
end