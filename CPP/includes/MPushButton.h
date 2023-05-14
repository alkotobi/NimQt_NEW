//
// Created by merhab on 2023/5/14.
//

#pragma once
typedef void MPushButton;
typedef void MWidget;
typedef void (*VMFnPtr)();
MPushButton *mpush_button_new(MWidget *parent);
void mpush_button_on_clicked_connect(MPushButton* self , VMFnPtr onclick);
