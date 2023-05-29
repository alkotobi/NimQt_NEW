# dbTable.nim
#
# Written on Saturday, 27 May 2023.
#
#By Merhab Noureddine


import ../mlibrary
type
  DbTable* = ref object of RootObj
    id*:MVariant

proc newDbTable*():DbTable=
  new result
  result.id = newMVariant(-1.int64,"id")

proc init*(self:DbTable,id:MVariant = nil)=
  if id.isNil():
    self.id = newMVariant(-1.int64,"id")
  else:
    self.id = id

proc getFields*(self:DbTable):seq[MVariant]=
  result.add self.id

proc fieldsFromStrs*(flds:seq[MVariant],strs:seq[string])=
  assert(flds.len() == strs.len())
  var i =0;
  for fld in flds:
    fld.setVal(strs[i]) 
    i.inc


proc id*():MFilter=
  new result
  result.vals = newSeq[MVariant]()
  result.field_name = "id"
#-------------------------------------
#TESTS
#-------------------------------------
when isMainModule:
  var t = new(DbTable)
  t.id = newMVariant(-1,"id")
  # t.id.setVal 5
  echo t.id

