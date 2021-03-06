require 'json'

class Convert_to_tables
  def convert_tables()
    necb_ver = '/2011'
    curr_dir = File.expand_path File.dirname(__FILE__)
    comm = curr_dir + necb_ver + "/*"
    files = Dir[comm]
    files.each do |json_file|
      data = JSON.parse(File.read(json_file))['tables']
      key_name = data.keys.first
      table_data = data[key_name]['table']
      ref_data = data[key_name]['refs']
      out_table_data = {key_name => table_data}
      ref_out_data = {key_name => ref_data}
      out_json = json_file[0..-6] + '_mod.json'
      # File.open(out_json,"w") {|each_file| each_file.write(JSON.pretty_generate(table_data))}
    end
    puts 'Hello?'
    puts 'Are you there?'
  end

  def extract_table()
    puts 'hello'
  end

  # Combine the data from the JSON files into a single hash
  # Load JSON files differently depending on whether loading from
  # the OpenStudio CLI embedded filesystem or from typical gem installation
  def load_standards_database_new()
    @standards_data = {}
    @standards_data["tables"] = {}

    if __dir__[0] == ':' # Running from OpenStudio CLI
      embedded_files_relative('../common', /.*\.json/).each do |file|
        data = JSON.parse(EmbeddedScripting.getFileAsString(file))
        if not data["tables"].nil? and data["tables"].first["data_type"] == "table"
          @standards_data["tables"] << data["tables"].first
        else
          @standards_data[data.keys.first] = data[data.keys.first]
        end
      end
    else
      path = "#{File.dirname(__FILE__)}/../common/"
      raise ('Could not find common folder') unless Dir.exist?(path)
      files = Dir.glob("#{path}/*.json").select {|e| File.file? e}
      files.each do |file|
        data = JSON.parse(File.read(file))
        if not data["tables"].nil?
          @standards_data["tables"] = [*@standards_data["tables"], *data["tables"]].to_h
        else
          @standards_data[data.keys.first] = data[data.keys.first]
        end
      end
    end


    if __dir__[0] == ':' # Running from OpenStudio CLI
      embedded_files_relative('data/', /.*\.json/).each do |file|
        data = JSON.parse(EmbeddedScripting.getFileAsString(file))
        if not data["tables"].nil? and data["tables"].first["data_type"] == "table"
          @standards_data["tables"] << data["tables"].first
        else
          @standards_data[data.keys.first] = data[data.keys.first]
        end
      end
    else
      files = Dir.glob("#{File.dirname(__FILE__)}/data/*.json").select {|e| File.file? e}
      files.each do |file|
        data = JSON.parse(File.read(file))
        if not data["tables"].nil?
          @standards_data["tables"] = [*@standards_data["tables"], *data["tables"]].to_h
        else
          @standards_data[data.keys.first] = data[data.keys.first]
        end
      end
    end
    # Write database to file.
    # File.open(File.join(File.dirname(__FILE__), '..', 'NECB2011.json'), 'w') {|f| f.write(JSON.pretty_generate(@standards_data))}

    return @standards_data
  end
end
Convert_to_tables.new.convert_tables()