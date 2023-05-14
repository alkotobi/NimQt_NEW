//
// Created by merhab on 2023/5/14.
//
#pragma once
typedef void MApplication;
MApplication *mapplication_new2();
int mapplication_exec(MApplication *self);
MApplication *mapplication_new(int argc, char **argv);
void mapplication_quit(MApplication *self);
