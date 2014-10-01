module SequelPad
  class MatrixTable < Table
    class << self
      def ===(object)
        object.kind_of?(Array) && 
          object.all? { |el| el.kind_of?(Array) }
      end
    end
    
    def columns
      @columns ||= (1..(data.max_by { |row| row.length }.length)).to_a
    end
    
    def each
      data.each do |row|
        yield row
      end
    end
  end
end