module SequelPad
  class ValueTable < Table
    class << self
      def ===(object)
        true
      end
    end
    
    def columns
      @columns ||= ['Value']
    end
  
    def each
      yield [data]
    end
  end
end