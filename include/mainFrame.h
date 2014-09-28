#ifndef MAINFRAME_H
#define MAINFRAME_H

#include "wx/wx.h"
#include "wx/frame.h"
#include "wx/grid.h"
#include "wx/stc/stc.h"
#include <wx/treectrl.h>
#include "sequelPadCore.h"
#include "sequelPadUi.h"

class MainFrame : public wxFrame, public SequelPadUi
{
public:
  ~MainFrame();
  void initialize();
  void ColouriseEditor(wxStyledTextEvent& event);
  void on_run(wxCommandEvent& event);
  void on_open(wxCommandEvent& event);
  void on_save(wxCommandEvent& event);
  void on_connect(wxCommandEvent& event);

  virtual void clear_results();
  virtual void set_columns(std::vector<std::string> column_labels);
  virtual void add_row(std::vector<std::string> row_values);
  virtual void refresh_results();
  virtual void auto_size_by_column_width(bool set_as_min);
  virtual void auto_size_by_label_width();
  virtual void alert(std::string message);

protected:
  DECLARE_EVENT_TABLE()
  
private:
  SequelPadCore core;
  bool connected;
  
  // Widgets
  wxTextCtrl* host_textctrl;
  wxTextCtrl* port_textctrl;
  wxTextCtrl* database_textctrl;
  wxTextCtrl* username_textctrl;
  wxTextCtrl* password_textctrl;
  wxPanel* code_editor_panel;
  wxStyledTextCtrl* code_editor;
  wxGrid* results_grid;
  wxButton* connect_button;
  wxListBox* table_listbox;
  wxTreeCtrl* db_tree_ctrl;
  
  void create_code_editor();
  void update_core_settings();
  std::vector<wxTextCtrl*> get_connection_text_controls();
  void populate_db_tree();
};

#endif // MAINFRAME_H
