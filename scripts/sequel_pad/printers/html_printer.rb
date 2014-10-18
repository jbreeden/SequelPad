# Defines a printer for saving results as an HTML table

require 'erb'

module SequelPad
  class HtmlPrinter < Printer
    exports 'HTML Table (*.html)|*.html'
    
    def initialize
      @head_renderer = ERB.new thead_template, nil, "-"
      @row_renderer = ERB.new row_template, nil, "-"
    end
    
    def print(results, file = nil)
      @output_file = File.open(file, "w")
      @output_file.puts document_head
      super
    end
    
    def set_columns(columns)
      @output_file.puts @head_renderer.result(binding)
    end
    
    def add_row(row)
      @output_file.puts @row_renderer.result(binding)
    end
    
    def finished
      @output_file.puts document_tail
      @output_file.close
    end
    
    private
    
    def document_head
    <<EOF
<html>
<head>
<style>
table {
    border-collapse: collapse;
}

table, td, th {
    border: 1px solid black;
    padding: 4px;
}
</style>
</head>
<body>
<table>
EOF
    end
    
    def document_tail
    <<EOF
</table>
</body> 
</html>
EOF
    end
    
    def thead_template
    <<EOF
  <thead>
<% columns.each do |column| -%>
    <th><%= column -%></th>
<% end -%>
  </thead>  
EOF
    end
    
        def row_template
    <<EOF
  <tr>
<% row.each do |cell| -%>
    <td><%= cell %></td>
<% end -%>
  </tr>    
EOF
    end
  end
end
