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
      
      def exporter_for(file_type)
        @@exporters[file_type]
      end
      
      def exporters
        @@exporters
      end
    end

    # file argument not used here, but subclasses that
    # export files may want to access it
    def print(table, file = nil)
      set_columns table.columns
      table.each { |row| add_row row }
      finished
    end
  end
end