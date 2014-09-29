# Printer is an "abstract" class for printing the results of a SequelPad script.
# Subclass should override, at a minimum, the `set_columns` & `add_row` methods.
# Printer, as a base class, handles converting the results into a printable form,
# then delegating the actual display of this information to the subclasses.

module SequelPad
  class Printer
    @@exporters = {}
    
    class << self
      
      # A subclass should call `exports` to declare that
      # it can handle the given file_type (Where file_type adheres
      # to conventions for wildcards as defined by wxWidgets:
      # http://docs.wxwidgets.org/trunk/classwx_file_dialog.html)
      #
      # Example file_type: "CSV Files (*.csv)|*.csv"
      def exports(file_type)
        @@exporters[file_type] = self # self will be the runtime class invoking `handle`
      end
      
      def exporters
        @@exporters
      end
    end

    def print(results, file = nil)
      @file = file
      if results.kind_of? Sequel::Dataset
        print_dataset(results)
      elsif results.kind_of?(Hash)
        print_hash(results)
      elsif (results.kind_of?(Array) && results.all? { |r| r.kind_of?(Array) })
        print_matrix(results)
      elsif results.kind_of?(Enumerable)
        print_list(results)
      else
        print_value(results)
      end
      finished
    end
  
    def print_dataset(results)
      return if results.count == 0
      columns = nil
      results.each do |result|
        unless columns
          columns = result.keys
          self.set_columns columns.map { |col| col.to_s}
        end
        
        self.add_row result.values
      end
    end
    
    def print_hash(results)
      self.set_columns ["Key", "Value"]
      results.each do |e|
        self.add_row e
      end
    end
    
    def print_matrix(results)
      return if results.length == 0
      col_count = results.max_by { |result| result.count }.count
      self.set_columns((1..(col_count)).map { |i| i.to_s })
      results.each do |row|
        self.add_row row
      end
    end
    
    def print_list(results)
      self.set_columns ['Value']
      results.each do |result|
        self.add_row [result]
      end
    end
    
    def print_value(value)
      self.set_columns ['Value']
      self.add_row([value])
    end
  end
end