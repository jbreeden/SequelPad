#include "ruby.h"
#include <iostream>
#include <memory>
#include <vector>
#include <exception>
#include "rubydo.h"
#include "sequelPadCore.h"

using namespace std;
using namespace rubydo;

namespace {
  void run_init_scripts() {
    rb_require("./scripts/settings");
    rb_require("./scripts/sequel_pad");
  }
  
  vector<string> ruby_array_to_string_vector(VALUE array){
    VALUE item_count = rb_funcall(array, rb_intern("length"), 0);
    int item_count_int = NUM2INT(item_count);
    
    vector<string> strings;
    for (int i = 0; i < item_count_int; ++i) {
      VALUE item = rb_funcall(array, rb_intern("[]"), 1, INT2NUM(i));
      VALUE item_as_string = rb_funcall(item, rb_intern("to_s"), 0);
      char* item_c_str = StringValuePtr(item_as_string);
      strings.push_back(item_c_str);
    }
    return strings;
  }
}

void 
SequelPadCore::initialize (SequelPadUi* ui) {
  this->ui = ui;
  
  rubydo::with_gvl DO [&](){
    run_init_scripts();
    define_sequel_pad_modules();
  } END;
}

bool
SequelPadCore::connect () {
  bool result;
  rubydo::with_gvl DO [&](){
    result = RTEST(
      rb_funcall(RubyModule::define("SequelPad").self, rb_intern("connect"), 0)
    );
  } END;
  return result;
}

void
SequelPadCore::disconnect () {
  rubydo::with_gvl DO [&](){
    rb_funcall(RubyModule::define("SequelPad").self, rb_intern("disconnect"), 0);
  } END;
}

void
SequelPadCore::exec_script(const char * code) {
  VALUE rb_script = rb_str_new2(code);
  rubydo::with_gvl DO [&](){
    VALUE sequel_pad_module = RubyModule::define("SequelPad").self;
    rb_funcall(sequel_pad_module, rb_intern("save_settings"), 0);
    rb_funcall(sequel_pad_module, rb_intern("run_script"), 1, rb_script);
  } END;
}

void
SequelPadCore::exec_to_file(const char * code, string file, int exporter_index) {
  VALUE rb_script = rb_str_new2(code);
  rubydo::with_gvl DO [&](){
    VALUE sequel_pad_module = RubyModule::define("SequelPad").self;
    rb_funcall(sequel_pad_module, rb_intern("save_settings"), 0);
    rb_funcall(
      sequel_pad_module, 
      rb_intern("exec_to_file"), 
      3, 
      rb_script,
      rb_str_new_cstr(file.c_str()),
      INT2NUM(exporter_index));
  } END;
}

std::vector<std::string> 
SequelPadCore::get_export_file_types () {
  VALUE result;
  
  rubydo::with_gvl DO [&](){
    result = rb_funcall(RubyModule::define("SequelPad").self, rb_intern("export_file_types"), 0);
  } END;
  
  return ruby_array_to_string_vector(result);
}

std::vector<std::string>
SequelPadCore::get_schemas () {
  VALUE result;
  
  rubydo::with_gvl DO [&](){
    result = rb_funcall(RubyModule::define("SequelPad").self, rb_intern("get_schemas"), 0);
  } END;
  
  return ruby_array_to_string_vector(result);
}

std::vector<std::string> 
SequelPadCore::get_tables (string schema) {
  VALUE result;
  
  if (schema == "") {
    rubydo::with_gvl DO [&](){
      result = rb_funcall(RubyModule::define("SequelPad").self, rb_intern("get_tables"), 0);
    } END;
  } else {
    rubydo::with_gvl DO [&](){
      result = rb_funcall(RubyModule::define("SequelPad").self, rb_intern("get_tables"), 1, rb_str_new2(schema.c_str()));
    } END;
  }
  
  return ruby_array_to_string_vector(result);
}

std::vector<std::string> 
SequelPadCore::get_views (string schema) {
  VALUE result;
  
  if (schema == "") {
    rubydo::with_gvl DO [&](){
      result = rb_funcall(RubyModule::define("SequelPad").self, rb_intern("get_views"), 0);
    } END;
  } else {
    rubydo::with_gvl DO [&](){
      result = rb_funcall(RubyModule::define("SequelPad").self, rb_intern("get_views"), 1, rb_str_new2(schema.c_str()));
    } END;
  }
  
  return ruby_array_to_string_vector(result);
}

void
SequelPadCore::define_sequel_pad_modules () {
  RubyModule sequel_pad_module = RubyModule::define("SequelPad");
  RubyModule grid_module = sequel_pad_module.define_module("Grid");
  
  // SequelPad::Grid.clear
  grid_module.define_singleton_method("clear", [&](VALUE self, int argc, VALUE* argv){
    ui->clear_results();
    return Qnil;
  });
  
  // SequelPad::Grid.set_columns(column_labels)
  grid_module.define_singleton_method("set_columns", [&](VALUE self, int argc, VALUE* argv){
    ui->set_columns(ruby_array_to_string_vector(argv[0]));
    return Qnil;
  });
  
  // SequelPad::Grid.add_row(row_values)
  grid_module.define_singleton_method("add_row", [&](VALUE self, int argc, VALUE* argv){
    ui->add_row(ruby_array_to_string_vector(argv[0]));
    return Qnil;
  });
  
  // SequelPad::Grid.refresh
  grid_module.define_singleton_method("refresh", [&](VALUE self, int argc, VALUE* argv){
    ui->refresh_results();
    return Qnil;
  });
  
  // SequelPad::Grid.auto_size_by_column_width(set_as_min)
  grid_module.define_singleton_method("auto_size_by_column_width", [&](VALUE self, int argc, VALUE* argv){
    if (argc == 0) {
      ui->auto_size_by_column_width(false);
    } else {
      ui->auto_size_by_column_width(RTEST(argv[0]));
    }
    return Qnil;
  });
  
  // SequelPad::Grid.auto_size_by_label_width
  grid_module.define_singleton_method("auto_size_by_label_width", [&](VALUE self, int argc, VALUE* argv){
    ui->auto_size_by_label_width();
    return Qnil;
  });
  
  // SequelPad.alert(message)
  sequel_pad_module.define_singleton_method("alert", [&](VALUE self, int argc, VALUE* argv){
    VALUE message = argv[0];
    VALUE message_as_string = rb_funcall(message, rb_intern("to_s"), 0);
    char* message_c_str = StringValuePtr(message_as_string);
    ui->alert(message_c_str);
    return Qnil;
  });
}

#define SETTING(getter, setter, rb_name) \
void \
SequelPadCore::setter (string value) { \
  const char * value_cstr = value.c_str(); \
  rubydo::with_gvl DO [&](){ \
    rb_funcall(rb_gv_get("$settings"), rb_intern("[]="), 2, ID2SYM(rb_intern(#rb_name)), rb_str_new2(value_cstr) ); \
  } END; \
} \
\
string \
SequelPadCore::getter () { \
  string value; \
  rubydo::with_gvl DO [&](){ \
    VALUE rb_string = rb_funcall(rb_gv_get("$settings"), rb_intern("[]"), 1, ID2SYM(rb_intern(#rb_name))); \
    value = StringValueCStr(rb_string); \
  } END; \
  return value; \
}

SETTING(getScript, setScript, script)
SETTING(getSchema, setSchema, schema)
SETTING(getHost, setHost, host)
SETTING(getPort, setPort, port)
SETTING(getDatabase, setDatabase, database)
SETTING(getUsername, setUsername, username)
SETTING(getPassword, setPassword, password)
