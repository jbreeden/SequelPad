module SequelPad
  class DatasetTable < Table
    class << self
      def ===(object)
        object.kind_of?(Sequel::Dataset)
      end
    end
    
    def columns
      data.columns
    end
    
    def each
      data.each do |row|
        yield row.values
      end
    end
  end
end