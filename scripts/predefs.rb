module Predefs

  def self.get_tables_by_row_count(schema)
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

