require 'fileutils'
require 'json'

in_file = './datapoint_ids_301.json'
out_file_temp = './out_test_301'
out_json_temp = {
    osa_id: "af5703da-c61c-42bc-856c-911876982ce3",
    bucket_name: "nrcanbtapresults",
    cycle_count: 0,
    region: "ca-central-1",
    object_keys: [],
    analysis_json: {
        analysis_id: "af5703da-c61c-42bc-856c-911876982ce3",
        analysis_name: "btap_test_301"
    }
}

bite_size = 500.0
in_json = JSON.parse(File.read(in_file))

tot_size = in_json.size
num_files = (tot_size/bite_size).to_i
num_files += 1 if tot_size > num_files.to_f
for i in 0..num_files-1
  bottom_num = (i*bite_size.to_i)
  i == num_files-1 ? top_num = (bottom_num + ((in_json.size % bite_size)*bite_size).round(0)).to_i : top_num = (bottom_num + bite_size -1 ).to_i
  out_json = out_json_temp
  out_json[:object_keys] = in_json[bottom_num..top_num]
  out_json[:cycle_count] = i
  out_file = out_file_temp + "_" + (i+1).to_s + ".json"
  File.write(out_file, JSON.pretty_generate(out_json))
end