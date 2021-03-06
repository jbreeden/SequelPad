#ifndef SEQUELPADCORE_H
#define SEQUELPADCORE_H 

#include <memory>
#include <vector>
#include <string>
#include <functional>
#include "sequelPadUi.h"

class SequelPadCore {
public:
  // Functions to be defined by the UI to allow the core to update the results
  SequelPadUi* ui;

  void initialize(SequelPadUi* ui);
  bool connect();
  void disconnect();
  void exec_script(const char * code);
  void exec_to_file(const char * code, std::string file, int exporter_index);
  void define_sequel_pad_modules();
  
  std::vector<std::string> get_export_file_types();
  std::vector<std::string> get_schemas();
  std::vector<std::string> get_tables(std::string schema = "");
  std::vector<std::string> get_views(std::string schema = "");
  
  void setSchema(std::string value);
  std::string getSchema();
  void setHost(std::string value);
  std::string getHost();
  void setPort(std::string value);
  std::string getPort();
  void setDatabase(std::string value);
  std::string getDatabase();
  void setUsername(std::string value);
  std::string getUsername();
  void setPassword(std::string value);
  std::string getPassword();
  void setScript(std::string value);
  std::string getScript();
};

#endif