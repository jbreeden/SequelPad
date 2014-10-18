module SequelPad
  class Table
    include Enumerable
    
    @subclasses = []
    
    class << self
      def inherited(subclass)
        @subclasses << subclass
      end
    
      def from(data)
        return data if data.kind_of? Table
        table_type = @subclasses.find { |subclass| subclass === data }
        table = table_type.new
        table.data = data
        table
      end
    end
    
    def initialize
      @user_defined_columns = false
      @columns = nil
      @data = nil
    end
    
    def columns
      @columns
    end
    
    def columns=(columns)
      @user_defined_columns = true
      @columns = columns
    end
    
    def data
      @data
    end
    
    def data=(new_data)
      @data = new_data
      # nil out columns so they're derived correctly
      # on next call to `self.columns` (unless the user
      # defined them... then they're on their own)
      @columns = nil unless @user_defined_columns
    end

    # Override each to yield arrays of values representing rows.
    # This allows you to convert other data structures into tables.
    # For example, if data is an array of hashes, you might try:
    # 
    #   results = [{one:1, two: 2}, {one: 'one', two: 'two'}]
    #   table = Table.new
    #   table.columns = results[0].keys
    #   table.data = results
    #   class << table
    #     def each(&block)
    #       data.each { |hash| yield hash.values }
    #     end
    #   end
    #
    # Of course, you could subclass instead of using the singleton class
    def each(&block)
      @data.each(&block)
    end
  end
end