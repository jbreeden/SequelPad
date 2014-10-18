# Defines a printer for saving results as an HTML table

require 'json'

module SequelPad
  class JsonPrinter < Printer
    exports 'JSON (*.json)|*.json'
    
    def print(results, file = nil)
      File.open(file, "w") do |f|
        if results.kind_of?(Sequel::Dataset)
          f.puts JSON.pretty_generate(Array(results))
        else
          f.puts JSON.pretty_generate(results)
        end
      end
    end
  end
end
