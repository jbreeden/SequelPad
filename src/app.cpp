#include <functional>
#include <iostream>
#include "wx/wx.h"
#include "wx/app.h"
#include "wx/xrc/xmlres.h"
#include "mainFrame.h"

#define RUBYDO_NO_CONFLICTS
#include "rubydo.h"
#undef RUBYDO_NO_CONFLICTS

using namespace std;

class App : public wxApp
{
  MainFrame *frame;

public:
  virtual bool OnInit() {
    wxApp::OnInit();
    wxXmlResource::Get()->InitAllHandlers();
    wxImage::AddHandler(new wxPNGHandler);
    wxXmlResource::Get()->Load("app.xrc");
    frame = new MainFrame();
    wxXmlResource::Get()->LoadFrame(frame, NULL, "main_frame");
    frame->initialize();
    frame->Show();
    return true;
  }
  
  virtual int FilterEvent(wxEvent& event) {
    if ((event.GetEventType() == wxEVT_KEY_DOWN) && 
        (((wxKeyEvent&)event).GetKeyCode() == WXK_F5))
    {
        frame->run();
        return true;
    }
 
    return -1;
  }
};

int main(int argc, char** argv) {
  rubydo::init(argc, argv);
  rubydo::use_ruby_standard_library();

  rubydo::without_gvl([&](){
    wxApp::SetInstance(new App);
    wxEntryStart(argc, argv);
    wxTheApp->OnInit();
    wxTheApp->OnRun();
    wxTheApp->OnExit();
    wxEntryCleanup();
  },[&](){
    cerr << "UBF callback hit (ruby execution has completed)" << endl;
  });

  return 0;
}
