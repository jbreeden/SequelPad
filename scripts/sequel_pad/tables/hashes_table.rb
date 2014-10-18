require 'set'

module SequelPad
  class HashesTable < Table
    class << self
      def ===(object)
        !object.kind_of?(::Sequel::Dataset) &&
          object.kind_of?(Enumerable) &&
          object.all? { |el| el.kind_of?(Hash) }
      end
    end
    
    def columns
      @columns ||= derive_columns
    end
  
    def each
      data.each do |datum|
        yield columns.map { |col| datum[col] }
      end
    end
    
    private
    
    def derive_columns
      columns = Set.new
      data.each do |datum|
        datum.keys.each do |key|
          columns << key
        end
      end
      columns.to_a
    end
  end
end