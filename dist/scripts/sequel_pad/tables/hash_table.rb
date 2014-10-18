module SequelPad
  class HashTable < Table
    class << self
      def ===(object)
        object.kind_of? Hash
      end
    end
    
    def columns
      @columns ||= data.keys
    end
  
    def each(&block)
      yield columns.map { |col| data[col] }
    end
  end
end