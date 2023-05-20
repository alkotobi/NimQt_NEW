#include <stdio.h>
#include "includes/MApplication.h"
#include "includes/MPushButton.h"
#include "includes/MWidget.h"
#include "includes/MAbstractButton.h"
#include "includes/MLibrary.h"
#include "includes/MFrame.h"
#include "includes/MVBoxLayout.h"
#include "includes/MDialog.h"

void onclicked(MPushButton* sender){
    if(sender) {
        char* str = mpush_button_get_text(sender);
        if (cstring_is_equal(str,"I am clicked"))
        mabstract_button_set_text(sender, "again");
        else mabstract_button_set_text(sender, "I am clicked");
        mnfree(str);
    }
}
int main(int argc, char *argv[])
{
  printf("hello world");
  MApplication * a = mapplication_new2();
  MPushButton* btn = mpush_button_new(0);
  MVBoxLayout* lay = mvbox_layout_new(0);
  MFrame* frm = mframe_new(0);
  MDialog* dlg = mdialog_new(0);
  mwidget_set_layout(dlg,lay);
//    mpush_button_on_clicked_connect(btn,onclicked);
    mvbox_layout_add_item(lay, btn);
//    mvbox_layout_add_item(lay, frm);
    mdialog_show(dlg);
    mapplication_exec(a);
  return 0;
}
