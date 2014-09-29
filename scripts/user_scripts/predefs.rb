# predefs.rb re-opens the ScriptContext class to add
# methods "pre-defined" by the user. By addings them
# to the ScriptContext class, they can be used without
# qualification withing SequelPad scripts.

module SequelPad
  class ScriptContext
    def get_tables_by_row_count(schema)
      tables = $db.tables schema: schema

      table_lengths = {}
      tables.each do |table|
        table_lengths[table] = $db["#{schema}__#{table}".to_sym].count
      end

      table_lengths.sort_by { |table, length| -length }.unshift ["Table", "Length"]
    end
    
    def make_aliases(dataset, &block)
      aliases = dataset.columns.zip(dataset.columns.map(&block)).map do |col, col_alias|
        Sequel.as(col, col_alias)
      end
    end
  end
end

