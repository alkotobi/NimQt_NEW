#include <stdio.h>
#include "includes/MApplication.h"
#include "includes/MPushButton.h"
#include "includes/MWidget.h"
#include "includes/MAbstractButton.h"
#include "includes/MLibrary.h"

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
    mpush_button_on_clicked_connect(btn,onclicked);
    mwidget_show(btn);
    mapplication_exec(a);
  return 0;
}
