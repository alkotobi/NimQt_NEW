#pragma once
#include "MWidget.h"
typedef void MVBoxLayout;
typedef void MLayoutItem;

MVBoxLayout *mvbox_layout_new(MWidget *parent);
void mvbox_layout_add_item(MVBoxLayout*self, MLayoutItem *item);
