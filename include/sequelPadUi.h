#ifndef SEQUELPADUI_H
#define SEQUELPADUI_H

#include <string>
#include <vector>

class SequelPadUi {
public:
  virtual void clear_results() = 0;
  virtual void set_columns(std::vector<std::string> column_labels) = 0;
  virtual void add_row(std::vector<std::string> row_values) = 0;
  virtual void refresh_results() = 0;
  virtual void auto_size_by_column_width(bool set_as_min) = 0;
  virtual void auto_size_by_label_width() = 0;
  virtual void set_schemas(std::vector<std::string> schemas) = 0;
  virtual void alert(std::string message) = 0;
};

#endif