module SequelPad
  class TreePrinter < Printer
    exports "Tree (*.html)|*.html"
    
    def print(table, file = nil)
      @file = file
      super
    end

    def set_columns(columns)
      @columns = columns
      
      required_columns_present = required_columns.all? do |required_column|
        columns.any? { |col| col.to_s == required_column }
      end
      
      unless required_columns_present
        raise "Tree export requires columns: #{required_columns.join ', '}"
      end
    end
    
    def required_columns
      [
        "name",
        "parent"
      ]
    end
    
    def add_row(row)
      @rows ||= []
      @rows << row
    end
    
    def finished
      columns = @columns
      rows = @rows
      File.open(@file, 'w') do |file|
        template.result(binding).each_line do |line|
          file.puts line
        end
      end
    end
    
    def template
      ERB.new template_string, nil, "-"
    end
    
    def template_string
      file = File.open(erb_file_name, 'r')
      result = file.read
      file.close
      result
    end
    
    def erb_file_name
      "#{File.dirname(__FILE__)}/tree_printer/tree.erb"
    end
  end
end