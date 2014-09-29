# Defines a printer for displaying results on the GUI

module SequelPad
  class GuiPrinter < SequelPad::Printer
    def print(results, file = nil)
      Grid.clear
      Grid.refresh
      super
    end
    
    def set_columns(columns)
      Grid.set_columns(columns)
    end
    
    def add_row(row)
      Grid.add_row(row)
    end
    
    def finished
      Grid.auto_size_by_column_width(true)
      Grid.auto_size_by_label_width
      Grid.refresh
    end
  end
end