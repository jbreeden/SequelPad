module SequelPad
  class FlatArrayTable < Table
    class << self
      def ===(object)
        object.kind_of?(Array)
      end
    end
    
    def columns
      @columns ||= ['Values']
    end
  
    def each
      data.each do |value|
        yield [value]
      end
    end
  end
end