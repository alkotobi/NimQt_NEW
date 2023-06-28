# dbTable.nim
#
# Written on Saturday, 27 May 2023.
#
#By Merhab Noureddine

import ../mvariant,../mfilter,engine,tables,strFormat
export engine
when engine.engine == "SQLITE":
  import std/db_sqlite

type
  State* = enum
    Scroll
    Edited
    New
    Deleted

type
  DbTableMeta* = ref object of RootObj
    tableName*:string

proc newDbTableMeta*(tableName:string):DbTableMeta=
  new result
  result.tableName = tableName

type
  DbTable* = ref object of RootObj
    tableMeta*:DbTableMeta
    id*:ref MInt64Var
    state:State
    dicCols:ref Table[int,ref MVariant]
    dicNames:ref Table[string,ref MVariant]

const dbId* = "id"
const dbIdCol* = 0

proc setTableName*(self:DbTable,tableName:string)=
  self.tableMeta.tableName = tableName

proc getTableName*(self:DbTable):string = 
  return self.tableMeta.tableName

proc isDirty*(self:DbTable):bool=
  result = self.state == Edited or self.state == New
proc isDeleted*(self:DbTable):bool=
  return self.state == Deleted

proc init*(self:DbTable,id:ref MInt64Var=newVar(-1.int64,"id")
)=
    self.id = id
    self.state = New
    self.dicCols = newTable[int,ref MVariant]()
    self.dicNames = newTable[string,ref MVariant]()

proc newDbTable*():DbTable=
  new result
  init(result)

proc getFields*(self:DbTable):seq[ref MVariant]=
  result.add(self.id)


proc id*():MFilter=
  result.field_name = "id"

proc delete*(self:DbTable,db:DbConn):bool=
  var str = &"DELETE FROM {self.getTablename()} WHERE id=?"
  result = db.tryExec(str.sql,self.id.val())

#-------------------------------------
#TESTS
#-------------------------------------
when isMainModule:
  var t = new(DbTable)
  t.id = newVar(-1.int64,"id")
  # t.id.setVal 5
  echo t.id
