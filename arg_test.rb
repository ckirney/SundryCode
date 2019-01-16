class ArgTest
  input_args = ARGV
  puts input_args
  puts input_args.length
  unless input_args.empty?
    if ((input_args.length/3).to_i)*3 < input_args.length
      puts "Incorrect number of arguments, running default buildings."
      puts input_args.length
    else
      (0..(input_args.length-1)).step(3) do |index|
        puts index
      end
      puts ' '
      puts 'End of loop'
    end
  end
end