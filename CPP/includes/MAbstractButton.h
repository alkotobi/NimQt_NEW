//
// Created by merhab on 2023/5/14.
//
#pragma once
typedef void MAbstractButton;
typedef void (*VMFn)();
void mabstract_button_on_clicked(MAbstractButton *self, void *ctx, VMFn on_clicked);
void mabstract_button_set_text(MAbstractButton *self, const char *text);