//
// Created by merhab on 2023/5/14.
//
#pragma once
typedef void MWidget;
typedef void MLayout;
void mwidget_set_parent(MWidget *self, MWidget *parent);
MWidget *mwidget_new(MWidget *parent);
void mwidget_show(MWidget *self);
void mwidget_set_layout(MWidget *self, MLayout *layout);
