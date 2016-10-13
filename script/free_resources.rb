#!/usr/local/rvm/rubies/ruby-2.3.1/bin/ruby
#  0         1       2       3         4          5        6       7             8          9
#["total", "used", "free", "shared", "buffers", "cached", "Mem:", "65966140", "10143560", "55822580", "636", "132904", "631216", "-/+", "buffers/cache:", "9379440", "56586700", "Swap:", "0", "0", "0"]
output = %x(free)
parts = output.split(" ")
total_memory = parts[7].to_i
used_memory = parts[8].to_i
free_memory = parts[9].to_i
puts  "Total Memory: #{total_memory} (#{total_memory/1024 / 1024} gb) / Used Memory: #{used_memory} (#{used_memory/1024 / 1024} gb) / Free Memory: #{free_memory} (#{free_memory/1024 / 1024} gb)"