#include <iostream>
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
  EVT_BUTTON(XRCID("run_button"), MainFrame::on_run)
  EVT_BUTTON(XRCID("connect_button"), MainFrame::on_connect)
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
MainFrame::set_schemas (std::vector<std::string> schemas) {
  db_tree_ctrl->DeleteAllItems();
  auto root = db_tree_ctrl->AddRoot("Schemas");
  for (string schema: schemas) {
    cout << "Appending schema: " << schema << endl;
    auto schema_node = db_tree_ctrl->AppendItem(root, schema);
    auto tables_node = db_tree_ctrl->AppendItem(schema_node, "Tables");
    auto views_node = db_tree_ctrl->AppendItem(schema_node, "Views");
    auto tables = core.get_tables(schema);
    cout << "Appending tables" << endl;
    for (auto table : tables) {
      db_tree_ctrl->AppendItem(tables_node, table);
    }
  }
};

void 
MainFrame::create_code_editor () {
  code_editor = new wxStyledTextCtrl(code_editor_panel, wxID_ANY);
  wxSizerFlags code_editor_flags;
  code_editor_flags.Expand();
  
  code_editor->StyleClearAll();
  code_editor->SetLexer(wxSTC_LEX_RUBY);
  code_editor->SetMarginType(0, wxSTC_MARGIN_NUMBER);
  code_editor->SetMarginWidth(0, 15);
  code_editor->SetTabWidth(2);
  code_editor->SetUseTabs(false);
  
  wxSizer* sizer = code_editor_panel->GetSizer();
  sizer->Add(code_editor, code_editor_flags);
}

void
MainFrame::on_run (wxCommandEvent& event) {
  update_core_settings();
  core.exec_script(code_editor->GetValue().c_str());
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
MainFrame::alert (std::string message) {
  wxMessageDialog dialog(this, message);
  dialog.ShowModal();
}

MainFrame::~MainFrame () {

}
