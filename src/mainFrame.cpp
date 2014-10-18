#include <iostream>
#include <fstream>
#include "mainFrame.h"
#include "wx/wx.h"
#include "wx/utils.h"
#include "wx/xrc/xmlres.h"
#include "wx/stc/stc.h"
#include "sequelPadCore.h"
#include <vector>

#define RUBYDO_NO_CONFLICTS
#include "rubydo.h"
#undef RUBYDO_NO_CONFLICTS

using namespace std;

namespace {
  template <class WidgetType>
  void disable_all (vector<WidgetType*> widgets) {
    for (auto widget_ptr : widgets) {
      widget_ptr->Enable(false);
    }
  }
  
  template <class WidgetType>
  void enable_all (vector<WidgetType*> widgets) {
    for (auto widget_ptr : widgets) {
      widget_ptr->Enable(true);
    }
  }
}

BEGIN_EVENT_TABLE(MainFrame, wxFrame)
  EVT_TOOL(XRCID("run_tool"), MainFrame::on_run)
  EVT_TOOL(XRCID("write_tool"), MainFrame::on_write)
  EVT_TOOL(XRCID("open_tool"), MainFrame::on_open)
  EVT_TOOL(XRCID("save_tool"), MainFrame::on_save)
  EVT_BUTTON(XRCID("connect_button"), MainFrame::on_connect)
  // Can't seem to get lexing & syntax highlighting working yet...
  //EVT_STC_CHANGE(wxID_ANY, MainFrame::on_editor_change)
END_EVENT_TABLE()

void 
MainFrame::initialize () {
  core.initialize(this);
  
#define TEXT_CTRL(name, initial_value) name = XRCCTRL(*this, #name, wxTextCtrl); name->SetValue( initial_value );
  TEXT_CTRL(host_textctrl, core.getHost())
  TEXT_CTRL(port_textctrl, core.getPort())
  TEXT_CTRL(database_textctrl, core.getDatabase())
  TEXT_CTRL(username_textctrl, core.getUsername())
  TEXT_CTRL(password_textctrl, core.getPassword())
#undef TEXT_CTRL

  status_bar = XRCCTRL(*this, "status_bar", wxStatusBar);
  db_tree_ctrl = XRCCTRL(*this, "db_tree_ctrl", wxTreeCtrl);
  db_tree_ctrl->AddRoot("Not Connected");
  connect_button = XRCCTRL(*this, "connect_button", wxButton);
  results_grid = XRCCTRL(*this, "results_grid", wxGrid);
  results_grid->CreateGrid(0,0);
  results_grid->SetColLabelAlignment(wxALIGN_LEFT, wxALIGN_CENTRE);
  code_editor_panel = XRCCTRL(*this, "code_editor_panel", wxPanel);
  create_code_editor();
}

void
MainFrame::clear_results () {
  int current_col_count = results_grid->GetNumberCols();
  int current_row_count = results_grid->GetNumberRows();
  if (current_col_count) {
    results_grid->DeleteCols(0, current_col_count);
  }
  if (current_row_count) {
    results_grid->DeleteRows(0, current_row_count);
  }
};

void
MainFrame::set_columns (std::vector<std::string> column_labels) {
  results_grid->AppendCols(column_labels.size());
  for (int i = 0; i < column_labels.size(); ++i) {
    results_grid->SetColLabelValue(i, column_labels[i]);
  }
};

void
MainFrame::add_row (std::vector<std::string> row_values) {
  results_grid->AppendRows(1);
  int row_index = results_grid->GetNumberRows() - 1;
  
  int num_values = row_values.size();
  int num_cols = results_grid->GetNumberCols();
  for (int col_index = 0; col_index < num_values && col_index < num_cols; ++col_index) {
    results_grid->SetCellValue(row_index, col_index, row_values[col_index]);
  }
};

void
MainFrame::refresh_results () {
  results_grid->Refresh();
};

void
MainFrame::auto_size_by_column_width (bool set_as_min) {
  results_grid->AutoSizeColumns(set_as_min);
};

void
MainFrame::auto_size_by_label_width () {
  for (int i = 0; i < results_grid->GetNumberCols(); ++i) {
    results_grid->AutoSizeColLabelSize(i);
  }
};

void 
MainFrame::create_code_editor () {
  code_editor = new wxStyledTextCtrl(code_editor_panel, wxID_ANY);
  wxSizerFlags code_editor_flags;
  code_editor_flags.Expand();
  
  code_editor->StyleClearAll();
  code_editor->SetStyleBits(8);
  code_editor->SetLexer(wxSTC_LEX_RUBY);
  code_editor->SetLexerLanguage("Ruby");
  code_editor->SetMarginType(0, wxSTC_MARGIN_NUMBER);
  code_editor->SetMarginWidth(0, 30);
  code_editor->SetTabWidth(2);
  code_editor->SetUseTabs(false);
  style_code_editor();
  
  wxSizer* sizer = code_editor_panel->GetSizer();
  sizer->Add(code_editor, code_editor_flags);
  sizer->Layout();
}

void
MainFrame::style_code_editor () {
  #define COLOR(num, background, foreground) \
    code_editor->StyleSetForeground(style_number, foreground); \
    code_editor->StyleSetBackground (style_number, background);
    
  auto background_color = 0x293134;

  // default fonts for all styles
  int style_number;
  
  for (style_number = 0; style_number < wxSTC_STYLE_LASTPREDEFINED; style_number++) {
      wxFont font (10, wxMODERN, wxNORMAL, wxNORMAL);
      code_editor->StyleSetFont (style_number, font);
      //COLOR(style_number, background_color, 0xE0E2E4);
  }
  
  /* Can't seem to get lexing & syntax highlighting working yet...
  COLOR(wxSTC_RB_DEFAULT, background_color, 0xE0E2E4)
  COLOR(wxSTC_RB_ERROR, background_color, 0x804000)
  COLOR(wxSTC_RB_COMMENTLINE, background_color, 0x7D8C93)
  // What is POD? COLOR(wxSTC_RB_POD, background_color, 0x)
  COLOR(wxSTC_RB_NUMBER, background_color, 0xFFCD22)
  COLOR(wxSTC_RB_WORD, background_color, 0xEC7600)
  COLOR(wxSTC_RB_STRING, background_color, 0xEC7600)
  COLOR(wxSTC_RB_CHARACTER, background_color, 0xEC7600)
  COLOR(wxSTC_RB_CLASSNAME, background_color, 0x678CB1)
  COLOR(wxSTC_RB_DEFNAME, background_color, 0x93C763)
  COLOR(wxSTC_RB_OPERATOR, background_color, 0xE8E2B7)
  COLOR(wxSTC_RB_IDENTIFIER, background_color, 0xE0E2E4)
  COLOR(wxSTC_RB_REGEX, background_color, 0xA082BD)
  COLOR(wxSTC_RB_GLOBAL, background_color, 0x678CB1)
  COLOR(wxSTC_RB_SYMBOL, background_color, 0xEC7600)
  COLOR(wxSTC_RB_MODULE_NAME, background_color, 0x678CB1)
  COLOR(wxSTC_RB_INSTANCE_VAR, background_color, 0x678CB1)
  COLOR(wxSTC_RB_CLASS_VAR, background_color, 0x678CB1)
  COLOR(wxSTC_RB_BACKTICKS, background_color, 0xEC7600)
  COLOR(wxSTC_RB_DATASECTION, background_color, 0xEC7600)
  COLOR(wxSTC_RB_HERE_DELIM, background_color, 0xEC7600)
  COLOR(wxSTC_RB_HERE_Q, background_color, 0xEC7600)
  COLOR(wxSTC_RB_HERE_QQ, background_color, 0xEC7600)
  COLOR(wxSTC_RB_HERE_QX, background_color, 0xEC7600)
  COLOR(wxSTC_RB_STRING_Q, background_color, 0xEC7600)
  COLOR(wxSTC_RB_STRING_QQ, background_color, 0xEC7600)
  COLOR(wxSTC_RB_STRING_QX, background_color, 0xEC7600)
  COLOR(wxSTC_RB_STRING_QR, background_color, 0xEC7600)
  COLOR(wxSTC_RB_STRING_QW, background_color, 0xEC7600)
  COLOR(wxSTC_RB_WORD_DEMOTED, background_color, 0xEC7600)
  COLOR(wxSTC_RB_STDIN, background_color, 0x678CB1)
  COLOR(wxSTC_RB_STDOUT, background_color, 0x678CB1)
  COLOR(wxSTC_RB_STDERR, background_color, 0x678CB1)
  COLOR(wxSTC_RB_UPPER_BOUND, background_color, 0x678CB1)
  */
  #undef COLOR
}

void 
MainFrame::on_editor_change(wxStyledTextEvent& event){
  /* Can't seem to get lexing & syntax highlighting working yet...
  code_editor->Colourise(0, length);
  */
}

void
MainFrame::on_run (wxCommandEvent& event) {
  run();
}

void
MainFrame::run () {
  update_core_settings();
  
  auto selected_text = code_editor->GetSelectedText().ToStdString();
  
  if (selected_text.size() != 0) {
    core.exec_script(selected_text.c_str());
  } else {
    core.exec_script(code_editor->GetValue().c_str());
  }
}

void 
MainFrame::on_write (wxCommandEvent& event) {
  auto export_file_types = core.get_export_file_types();
  string file_types;
  
  for (auto file_type : export_file_types) {
    if (file_types != ""){
      file_types += "|";
    }
    file_types += file_type;
  }
  
  wxFileDialog dialog(
    this, 
    "Save Script", 
    "", // default dir
    "", // default file
    file_types,
    wxFD_SAVE|wxFD_OVERWRITE_PROMPT);
  try {
    if (wxID_OK == dialog.ShowModal()) {
      auto file_name = (dialog.GetDirectory() + "/" + dialog.GetFilename()).ToStdString();
      core.exec_to_file(code_editor->GetValue().c_str(), file_name, dialog.GetFilterIndex());
    }
  } catch (...) {
    alert("Could not write output file.");
  }
}

void 
MainFrame::on_open (wxCommandEvent& event) {
  wxFileDialog dialog(
    this, 
    "Open Script", 
    "", // default dir
    "", // default file
    "Ruby Files (*.rb)|*.rb|All Files (*.*)|*.*",
    wxFD_OPEN|wxFD_FILE_MUST_EXIST);
  try {
    if (wxID_OK == dialog.ShowModal()) {
      current_file = (dialog.GetDirectory() + "\\" + dialog.GetFilename()).ToStdString();
      ifstream in;
      in.open(current_file);
      string script((istreambuf_iterator<char>(in)), istreambuf_iterator<char>());
      code_editor->SetValue(script);
      status_bar->SetStatusText("File: " + current_file);
      in.close();
    }
  } catch (...) {
    alert("Could not read input file.");
  }
}

void 
MainFrame::on_save (wxCommandEvent& event) {
  wxFileDialog dialog(
    this, 
    "Save Script", 
    "", // default dir
    "", // default file
    "Ruby Files (*.rb)|*.rb|All Files (*.*)|*.*",
    wxFD_SAVE|wxFD_OVERWRITE_PROMPT);
  try {
    if (current_file.size() != 0) {
      dialog.SetPath(current_file);
    }
    if (wxID_OK == dialog.ShowModal()) {
      current_file = (dialog.GetDirectory() + "\\" + dialog.GetFilename()).ToStdString();
      status_bar->SetStatusText("File: " + current_file);
      ofstream out;
      out.open(current_file);
      string contents = code_editor->GetValue().ToStdString();
      for (int i = 0; i < contents.size(); ++i) {
        if (contents[i] == '\r') continue;
        out << contents[i];
      }
      out.close();
    }
  } catch (...) {
    alert("Could not write output file.");
  }
}

void
MainFrame::update_core_settings() {
  core.setHost(host_textctrl->GetValue().ToStdString());
  core.setPort(port_textctrl->GetValue().ToStdString());
  core.setDatabase(database_textctrl->GetValue().ToStdString());
  core.setUsername(username_textctrl->GetValue().ToStdString());
  core.setPassword(password_textctrl->GetValue().ToStdString());
}

void
MainFrame::on_connect (wxCommandEvent& event) {
  if (connected) {
    core.disconnect();
    db_tree_ctrl->DeleteAllItems();
    db_tree_ctrl->AddRoot("Not Connected");
    enable_all(get_connection_text_controls());
    connect_button->SetLabel("Connect");
    connected = false;
  } else {
    disable_all(get_connection_text_controls());
    update_core_settings();
    connected = core.connect();
    if (connected) {
      connect_button->SetLabel("Disconnect");
      populate_db_tree();
    } else {
      enable_all(get_connection_text_controls());
    }
  }
}

vector<wxTextCtrl*> 
MainFrame::get_connection_text_controls() {
  return {host_textctrl, port_textctrl, database_textctrl, username_textctrl, password_textctrl};
}

void
MainFrame::populate_db_tree () {
  db_tree_ctrl->DeleteAllItems();
  auto root = db_tree_ctrl->AddRoot("Schemas");
  auto schemas = core.get_schemas();
  for (string schema: schemas) {
    auto schema_node = db_tree_ctrl->AppendItem(root, schema);
    auto tables_node = db_tree_ctrl->AppendItem(schema_node, "Tables");
    auto views_node = db_tree_ctrl->AppendItem(schema_node, "Views");
    auto tables = core.get_tables(schema);
    auto views = core.get_views(schema);
    for (auto table : tables) {
      db_tree_ctrl->AppendItem(tables_node, table);
    }
    for (auto view: views) {
      db_tree_ctrl->AppendItem(views_node, view);
    }
  }
}

void
MainFrame::alert (std::string message) {
  wxMessageDialog dialog(this, message);
  dialog.ShowModal();
}

MainFrame::~MainFrame () {

}
