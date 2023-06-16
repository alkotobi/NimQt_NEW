# dbTable.nim
#
# Written on Saturday, 27 May 2023.
#
#By Merhab Noureddine

import ../mvariant,../mfilter

type
  State* = enum
    Scroll
    Edited
    New
    Deleted
  DbTable* = ref object of RootObj
    id*:ref MInt64Var
    state:State

proc isDirty*(self:DbTable):bool=
  result = self.state == Edited or self.state == New
proc isDeleted*(self:DbTable):bool=
  return self.state == Deleted
proc newDbTable*():DbTable=
  new result
  result.id = newVar(-1.int64,"id")
  result.state = New

proc init*(self:DbTable,id:ref MInt64Var)=
    self.id = id
proc init*(self:DbTable)=
    self.id = newVar(-1.int64,"id")

proc getFields*(self:DbTable):seq[ref MVariant]=
  result.add(self.id)


proc id*():MFilter=
  result.field_name = "id"

#-------------------------------------
#TESTS
#-------------------------------------
when isMainModule:
  var t = new(DbTable)
  t.id = newVar(-1.int64,"id")
  # t.id.setVal 5
  echo t.id
