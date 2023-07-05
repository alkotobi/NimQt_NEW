import ../mvariant,../mlibrary

#***************************************
#************** MFieldmeta *************
#***************************************
type 
  MFieldMeta* = ref object of MVariantMeta
    caption:string
    width:int
    isPrimary:bool
    isAutoInc:bool
    isUnic:bool
    isCanNotEmpty:bool

  MMetaList* = seq[MFieldMeta]
proc `$`*(self:MFieldMeta):string=
  var l:seq[string]
  for fieldName, fieldValue in self[].fieldPairs:
    when fieldValue is string:
      l.add(fieldName & ":'" & fieldValue & "'")
    else: l.add(fieldName & ":" & $(fieldValue))
  result = l.join(";")

proc newMeta*(name:string,kind:string,isPrimary = false,isAutoInc = false,isUnic=false,isCanNotEmpty = false):MFieldMeta=
  new result
  result.MVariantMeta().init(name,kind)
  result.isAutoInc = isAutoInc
  result.isCanNotEmpty = isCanNotEmpty
  result.isCanNotEmpty = isCanNotEmpty
  result.isUnic = isUnic

proc newMfieldMeta*(name:string="",kind =Nil,caption=name):MFieldMeta=
  new result
  result.MVariantMeta().init(name,kind)
  result.caption = caption
proc newIdMeta*():MFieldMeta=
  new result
  result.kind = Int64
  result.name = "ID"
  result.isAutoInc = true
  result.isPrimary = true

proc getNames*(self:MMetaList):string=
  assert(self.len()>0)
  result = self[0].name
  for i in 1..self.len()-1:
    result = result & "," & self[i].name
proc getNamesList*(self:MMetaList):seq[string]=
  for meta in self:
    result.add(meta.name)
#***************************************
#**************** MField ***************
#***************************************    
type
  MField* = ref object of RootObj
    value:ref MVariant
proc `$`*(self:MField):string=
  $self.value
proc newMfield*[T:int|int64|string|float](val:T,meta:MFieldMeta):MField=
  when T is int: assert(meta.kind == Int)
  when T is int64: assert(meta.kind == Int64)
  when T is string: assert(meta.kind == String)
  when T is float: assert(meta.kind == Float)
  new result
  result.value = newVar(val,meta=meta)

proc newMfield*(val:ref MVariant):MField=
  new result
  result.value = val

  
proc newMfield*(meta:MFieldMeta):MField=
  case meta.kind:
    of Int:
      return newMfield(0,meta = meta)
    of Int64:
      if meta.isAutoInc:
        return newMfield(-1.int64,meta=meta)
      else:
        return newMfield(0.int64,meta = meta)
    of Float:
      return newMfield(0.float,meta=meta)
    of String:
      return newMfield("",meta = meta)
    else:
      assert(false)

proc newIDField*():MField=
  new result
  result.value = newVar(-1.int64,meta=newIdMeta())

proc meta*(self:MField):MFieldMeta=
  return self.value.meta.MFieldMeta()
proc kind*(self:MField):string=
  return self.meta.kind
proc name*(self:MField):string=
  self.meta().name
proc toMVariant*(self:MField):ref MVariant=
  return self.value
proc toMIntVar*(self:MField):MIntVarRef=
  assert(self.kind()==Int)
  self.toMVariant().MIntVarRef()
proc toMInt64Var*(self:MField):MInt64VarRef=
  assert(self.kind()==Int64)
  self.toMVariant().MInt64VarRef()
proc toMStrVar*(self:MField):MStrVarRef=
  assert(self.kind()==String)
  self.toMVariant().MStrVarRef()
proc toMFloatVar*(self:MField):MFloatVarRef=
  assert(self.kind()==Float)
  self.toMVariant().MFloatVarRef()
proc toInt*(self:MField):int=
  assert(self.kind() == Int)
  val(self.toMVariant().MIntVarRef())
proc toInt64*(self:MField):int64=
  assert(self.kind == Int64)
  val(self.toMVariant().MInt64VarRef())
proc toStr*(self:MField):string=
  assert(self.kind() == String)
  val(self.toMVariant().MStrVarRef())
proc toFloat*(self:MField):float=
  assert(self.kind() == Float)
  val(self.toMVariant().MFloatVarRef())
proc setVal*[T:int|int64|string|float](self:MField,val:T,runBefor=false,runAfter = false)=
  when T is string:
    if self.kind() == Int:
      self.toMIntVar().setVal(val,runBefor,runAfter)
    elif self.kind() == Int64:
      self.toMInt64Var().setVal(val,runBefor,runAfter)
    elif self.kind() == String:
      self.toMStrVar().setVal(val,runBefor,runAfter)
    elif self.kind() == Float:
      self.toMFloatVar().setVal(val,runBefor,runAfter)
  when T is int:
    assert(self.kind() == Int or self.kind() == Int64)
    if self.kind == Int:
      self.toMIntVar().setVal(val,runBefor,runAfter)
  when T is int64:
    assert(self.kind() == Int64)
    self.toMInt64Var().setVal(val,runBefor,runAfter) 
  when T is float:
    assert(self.kind() == Float)
    self.toMFloatVar().setVal(val,runBefor,runAfter) 

#***************************************
#*************** MRecord ***************
#***************************************
type
  MRecord* = ref object of RootObj
    fields: seq[MField]
proc newMrecord*():MRecord=
  new result
  result.fields.add(newIDField())

proc add*(self:MRecord,fld:MField)=
  self.fields.add(fld)

proc fieldByName*(self:MRecord,name:string):MField=
  for fld in self.fields:
    if fld.name() == name:
      return fld
  assert(false)

proc fieldByIndex*(self:MRecord,index:int):MField=
  assert(index < self.fields.len())
  return self.fields[index]

proc getIndexOfField*(self:MRecord,name:string):int=
  for i in 0..self.fields.len()-1:
    if self.fields[i].name() == name:
      return i
  assert(false)

proc id*(self:MRecord):int64=
  result = self.fields[0].value.toInt64()

proc idVar*(self:MRecord):MInt64VarRef=
  result = self.fields[0].value.MInt64VarRef()

proc vals*(self:MRecord):seq[MVariant]=
  for fld in self.fields:
    result.add(fld.value)

proc newMrecord*(metas:seq[MFieldMeta]):MRecord=
  result = newMrecord()
  for meta in metas:
    result.fields.add(newMfield(meta))

proc add*(self:MRecord,field:MField)=
  self.fields.add(field)
proc `[]`*(self:MRecord,ind:int):MField=
  return self.fields[ind]
proc `[]`*(self:MRecord,name:string):MField=
  for field in self.fields:
    if field.name==name:
      return field
  assert(false)
proc len*(self:MRecord):int=
  self.fields.len()
proc strWithin(self:string,width:int):string=
  if self.len()>=width:
    var i=0
    while result.len()<width:
      result.add(self[i])
      i += 1
  else:
    result = self
    while result.len()<width:
      result.add(' ')
    
proc `$`*(self:MRecord):string=
  var str = "|"
  for field in self.fields:
    str = str & field.name().strWithin(10) & "|"
  echo str
  str = "|"
  for field in self.fields:
    str = str & strWithin($field.toMVariant(),10) & "|"
  echo str
proc setVals*(self:MRecord,vals:seq[string])=
  assert(self.len() == vals.len()+1)
  #we excluse the ID from being assigned
  for i in 1 .. vals.len()-1:
    self.fields[i].setVal(vals[i-1])

#***************************************
#****************** db ****************
#***************************************
const engine = "SQLITE"
when engine == "SQLITE":
  import std/db_sqlite
else:
  import std/db_mysql  

proc bindParam(self:SqlPrepared,val:ref MVariant,col:int)=
  case val.kind:
      of "int":
        self.bindParam(col,val.MIntVarRef().val())
      of "int64":
        self.bindParam(col,val.MInt64VarRef().val())
      of "string":
        self.bindParam(col,val.MStrVarRef().val())
      of "float":
        self.bindParam(col,val.MFloatVarRef().val())
      of "nil":
        self.bindNull(col)

#***************************************
#****************** sql ****************
#***************************************
type
  SqlStmt* = object
    vals*:seq[ref MVariant]
    stmt*:string
    names*:seq[string]

proc `$`*(self:SqlStmt):string=
  var str =""
  str = "Names:" & "\n"
  for fld in self.names:
    str = str & "  " & fld & "\n"
  str = str & "Vals:"  & "\n"
  for v in self.vals:
    str = str & " " & $v & "\n"
  str = str & "Stmt:"  & "\n"
  str = str & " " & self.stmt & "\n"
  return str

type
  SqlKind* = enum
    SqlSelect
    SqlInsert
    SqlUpdate
    SqlCreateTable
    SqlDelete
    SqlNone
  SqlTable* = ref object
    sqlKind*:SqlKind
    tableName*:string
    meta*:seq[MFieldMeta]
    selectSql*:SqlStmt
    whereSql*:SqlStmt
    whereSqlTmp:SqlStmt
    orderBySql*:SqlStmt
    updateSQl*:SqlStmt
    inserSQl*:SqlStmt
    deleteTableSql*:SqlStmt
    createTableSql*:string
    limit*:int
    offset*:int
    engine:string

proc createTableFieldsSql(metas:seq[MFieldMeta],engine="SQLITE"):seq[string]=
  var kind = ""
  for meta in metas:
    var str = ""
    case meta.kind:
      of Int: kind = "INTEGER"
      of Int64: kind = "INTEGER"
      of String: kind = "TEXT"
      of Float: kind = "REAL"
      else:assert(false)
    str = "`" & meta.name & "` " & kind
    if meta.isPrimary: str = str & " PRIMARY KEY"
    if meta.isAutoInc:
      if engine == "SQLITE":
        str = str & " AUTOINCREMENT"
      elif engine == "MYSQL":
        str = str & " AUTO_INCREMENT"
    elif meta.isUnic: str = str & " UNIQUE"
    elif meta.isCanNotEmpty: str = str & " NOT NULL"
    result.add(str)
proc createTableSql(tableName:string,metas:seq[MFieldMeta],engine = "SQLITE"):string=
  result = "CREATE TABLE IF NOT EXISTS `" & tableName & "`(" & createTableFieldsSql(metas,engine).join(",") & ")"

proc newSqlTable*(tableName:string,metas:seq[MFieldMeta],engine = "SQLITE"):SqlTable=
  new result
  result.engine = engine
  result.meta.add(newIdMeta())
  result.meta.add(metas)
  result.tableName = tableName
  var names = metas.getNames()
  result.createTableSql = createTableSql(tableName,result.meta,engine)
  result.selectSql.names = metas.getNamesList()
  result.selectSql.stmt = "SELECT " & names & " FROM " & tableName
  var str ="?"
  for i in 1..metas.len()-1:
    str = str & "," & "?"
  result.inserSQl.stmt =  "INSERT INTO " & tableName & " (" & names & ") VALUES (" & str & ");"
#******** General Api ********

#******** Filter ********
proc comp[T:int|int64|float|string](self:SqlStmt,val:T,op:string):SqlStmt=
  result = self
  result.vals.add(newVar(val))
  result.stmt = self.names[0] & " " & op & " " & '?'

proc `==`*[T:int|int64|float|string](self:SqlStmt,val:T):SqlStmt=
  return comp(self,val,"=")

proc `>`*[T:int|int64|float|string](self:SqlStmt,val:T):SqlStmt=
  return comp(self,val,">")

proc `<`*[T:int|int64|float|string](self:SqlStmt,val:T):SqlStmt=
  return comp(self,val,"<")

proc `>=`*[T:int|int64|float|string](self:SqlStmt,val:T):SqlStmt=
  return comp(self,val,">=")

proc `<=`*[T:int|int64|float|string](self:SqlStmt,val:T):SqlStmt=
  return comp(self,val,"<=")

proc `!=`*[T:int|int64|float|string](self:SqlStmt,val:T):SqlStmt=
  return comp(self,val,"!=")

proc like*[T:int|int64|float|string](self:SqlStmt,val:T):SqlStmt=
  return comp(self,val,"like")

proc logic(sqlStmt1:SqlStmt,sqlStmt2:SqlStmt,op:string):SqlStmt=
  result = sqlStmt1
  result.vals.add(sqlStmt2.vals)
  result.stmt = result.stmt & " " & op & " " & sqlStmt2.stmt

proc `and`*(sqlStmt1:SqlStmt,sqlStmt2:SqlStmt):SqlStmt=
  return logic(sqlStmt1,sqlStmt2,"AND")

proc `or`*(sqlStmt1:SqlStmt,sqlStmt2:SqlStmt):SqlStmt=
  return logic(sqlStmt1,sqlStmt2,"OR")

proc `not`*(self:SqlStmt):SqlStmt=
  result = self
  result.stmt = "NOT (" & result.stmt & ")"

#******** SqlTable ********
proc fields*(flds:varargs[string]):SqlStmt=
  for arg in flds:
    result.names.add(arg)

proc select*(self:SqlTable,names:seq[string] = @[]):SqlTable=
  result = self
  result.sqlKind = SqlSelect
  result.selectSql.names = names
  var str = ""
  if names.len() == 0 :
    str = "*"
  else:
    str = names.join(",")
  result.selectSql.stmt = "SELECT " & str & " FROM " & result.tableName

proc select*(self:SqlTable,names =SqlStmt()):SqlTable=
  return select(self,names.names)

proc filter*(self:SqlTable,whereSql:SqlStmt):SqlTable=
  if self.sqlKind == SqlSelect:
    self.whereSql = whereSql
  else:
    self.whereSqlTmp = whereSql
  return self
proc field*(fieldName:string):SqlStmt=
  result.names.add(fieldName)
proc filter*(self:SqlTable,whereSql:SqlStmt,logic:string):SqlTable=
  assert(whereSql.stmt != "")
  if self.sqlKind == SqlSelect:
    assert(self.whereSql.stmt != "")
    self.whereSql.vals.add(whereSql.vals)
    self.whereSql.stmt = "(" & self.whereSql.stmt & ")" & logic & "(" & whereSql.stmt & ")"
  else:
    assert(self.whereSqlTmp.stmt != "")
    self.whereSqlTmp.vals.add(whereSql.vals)
    self.whereSqlTmp.stmt = "(" & self.whereSqlTmp.stmt & ")" & logic & "(" & whereSql.stmt & ")"
    
  return self

proc andFilter*(self:SqlTable,whereSql:SqlStmt):SqlTable=
  return filter(self,whereSql," AND ")
  
proc orFilter*(self:SqlTable,whereSql:SqlStmt):SqlTable=
  return filter(self,whereSql," OR ")

proc notFilter*(self:SqlTable):SqlTable=
  if self.sqlKind == SqlSelect:
    assert(self.whereSql.stmt != "")
    self.whereSql = not self.whereSql
  else:
    assert(self.whereSqlTmp.stmt != "")
    self.whereSqlTmp = not self.whereSqlTmp
  return self

proc sort*(self:SqlTable,orderBySql:SqlStmt):SqlTable=
  # vals: 1 asc , 0 desc , every field from names has asc or desc from vals
  self.orderBySql.names.add(orderBySql.names)
  self.orderBySql.vals.add(orderBySql.vals)
  var str = self.orderBySql.names[0]
  if self.orderBySql.vals[0].toInt() != 1:
    str = str & " DESC"
  for i in 1..self.orderBySql.names.len()-1:
    str = str & "," & self.orderBySql.names[i]
    if self.orderBySql.vals[i].toInt() != 1:
      str = str & " DESC"
  self.orderBySql.stmt = str
  return self

proc sort*(self:SqlTable,fieldName:string,asc:bool=true):SqlTable=
  # vals: 1 asc , 0 desc , every field from names has asc or desc from vals
  self.orderBySql.names.add(fieldName)
  if asc:
    self.orderBySql.vals.add(newVar(1))
  else:
    self.orderBySql.vals.add(newVar(0))
  return self

proc limit*(self:SqlTable,limit,offset:int):SqlTable=
  self.limit = limit
  self.offset = offset
  return self

proc getSelectSql*(self:SqlTable):string=
  if self.whereSql.stmt != "":
     self.selectSql.stmt = self.selectSql.stmt & " WHERE " & self.whereSql.stmt
  if self.orderBySql.stmt != "" :
    self.selectSql.stmt = self.selectSql.stmt & " ORDERBY " & self.orderBySql.stmt
  if self.limit != 0:
    self.selectSql.stmt = self.selectSql.stmt & " LIMIT " & $self.limit
    if self.offset != 0:
      self.selectSql.stmt = self.selectSql.stmt & " OFFSET " & $self.offset
  return self.selectSql.stmt

proc all*(self:SqlTable,db:DbConn):seq[Row]=
  var sql = self.getSelectSql()
  var vals = self.whereSql.vals
  if self.whereSql.vals.len()==0:
    return db.getAllRows(sql(sql))
  var selectStmt = db.prepare(sql)
  var i = 0;
  for v in  vals:
    i += 1
    selectStmt.bindParam(v,i)
  result = getAllRows(db,selectStmt)

proc getInsertSql(self:SqlTable):string=
  assert(self.inserSQl.vals.len()!=0)
  var str ="?"
  for i in 1..self.inserSQl.vals.len()-1:
    str = str & "," & "?"
  result =  "INSERT INTO " & self.tableName & " (" & self.inserSQl.vals.getNames() & ") VALUES (" & str & ");"

proc insert*(self:SqlTable,vals:seq[ref MVariant]):SqlTable=
  self.sqlKind = SqlInsert
  self.inserSQl.vals = vals
  self.inserSQl.stmt = self.getInsertSql()
  return self

proc insert*(self:SqlTable,record:MRecord):SqlTable=
  return self.insert(record.vals())

proc delete*(self:SqlTable):SqlTable=
  self.sqlKind = SqlDelete
  self.whereSqlTmp.names.setLen(0)
  self.whereSqlTmp.stmt = ""
  self.whereSqlTmp.vals.setLen(0)
  return self

proc delete*(self:SqlTable,record:MRecord):bool=
  self.whereSqlTmp.stmt = " ID = ?"
  self.whereSqlTmp.vals.add(record.idVar())

proc exec*(self:SqlTable,db:DbConn):bool=
  if self.sqlKind == SqlInsert:
    var sql = self.getInsertSql()
    var insterStmt = db.prepare(sql)
    var i = 0;
    for v in  self.inserSQl.vals:
      i += 1
      insterStmt.bindParam(v,i)
    return db.tryExec(insterStmt)
  elif self.sqlKind == SqlDelete:
    var sql = "DELETE from " & self.tableName
    var vals = self.whereSqlTmp.vals
    if self.whereSqlTmp.vals.len()==0:
      return db.tryExec(sql(sql))
    var selectStmt = db.prepare(sql)
    var i = 0;
    for v in  vals:
      i += 1
      selectStmt.bindParam(v,i)
    return db.tryExec(selectStmt)
  elif self.sqlKind == SqlUpdate:
    discard
 

proc createTable*(self:SqlTable,db:DbConn):bool=
  return db.tryExec(sql(self.createTableSql))
    
  

  
#***************************************
#**************** tests ****************
#***************************************
when isMainModule:
  import sugar
  echo """***************************************
**************** tests ****************
***************************************"""
  echo """************
****Db******
************
""" 
  var db = open("test.db","","","")
  echo """
**********
MFieldmeta
**********
"""
  var metaList:MMetaList
  metaList.add(@[newMeta(name="age",kind=Int)
,newMeta(name="name",kind=String)])
  dump metaList
  echo """
********
SqlTable
********
"""
  var table = newSqlTable("user",metaList)
  var ff = field("age")
  dump table.filter(field("age") > 15 and field("name") == "marwa").whereSql
  dump table.createTableSql
  dump table.inserSQl.stmt
  dump table.selectSql.stmt
  dump table.select(fields("name","age")).filter(field("ID") == 1).getSelectSql()
  if table.createTable(db):
    echo "table created"
  else: echo "we did not create the table"
  var rec = newMrecord(table.meta)
  echo """
************
END SqlTable
************
"""  
  var b:bool 
  echo "b:", b 
  var mint = newIdMeta()
  var mstr = newMfieldMeta("name",String)
  var f = newMfield(1.int64,mint)
  f.setVal(10)
  echo f,"-->",f.meta()
  f.setVal("15")
  echo f,"-->",f.meta()
  var rec = newMrecord()
  rec.add(newMfield(1.int64,mint))
  rec.add(newMfield("nour",mstr))
  echo rec
  rec.setVals(@["10","sofia"])
  echo rec

  #echo f,"-->",f.meta()
