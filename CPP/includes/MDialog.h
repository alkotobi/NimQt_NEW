#pragma once
typedef void MDialog;
typedef void MWidget;

MDialog *mdialog_new(MWidget *parent);
void mdialog_show(MDialog* self);
