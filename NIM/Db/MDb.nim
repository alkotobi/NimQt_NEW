import ../mvariant

#***************************************
#************** MFieldmeta *************
#***************************************
type 
  MFieldMeta* = ref object of MVariantMeta
    caption:string
    width:int
proc newMfieldMeta*(name:string="",kind =Nil,caption=name):MFieldMeta=
  new result
  result.MVariantMeta().init(name,kind)
  result.caption = caption
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
  result.value = newVar(val,meta)

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
    assert(self.kind() == Int)
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
  result.fields = newSeq[MField]()
proc newMrecord*(metas:seq[MFieldMeta]):MRecord=
  result = newMrecord()
  for meta in metas:
    case meta.kind:
      of Int:
        result.fields.add(newMfield(0,meta))

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
  assert(self.len() == vals.len())
  for i in 0 .. vals.len()-1:
    self.fields[i].setVal(vals[i])

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
        selectStmt.bindParam(col,val.MIntVarRef().val())
      of "int64":
        selectStmt.bindParam(col,val.MInt64VarRef().val())
      of "string":
        selectStmt.bindParam(col,val.MStrVarRef().val())
      of "float":
        selectStmt.bindParam(col,val.MFloatVarRef().val())
      of "nil":
        selectStmt.bindNull(col)

#***************************************
#****************** sql ****************
#***************************************
type
  SqlStmt* = object
    vals*:seq[ref MVariant]
    stmt*:string
    fields*:seq[string]

proc `$`*(self:SqlStmt):string=
  var str =""
  str = "Fields:" & "\n"
  for fld in self.fields:
    str = str & "  " & fld & "\n"
  str = str & "Vals:"  & "\n"
  for v in self.vals:
    str = str & " " & $v & "\n"
  str = str & "Stmt:"  & "\n"
  str = str & " " & self.stmt & "\n"
  return str

type
  SelectSql* = ref object
    tableName*:string
    fields*:seq[string]
    whereSql*:SqlStmt
    orderBySql*:SqlStmt
    updateSQl*:SqlStmt
    inserSQl*:SqlStmt
    deleteSql*:SqlStmt
    limit*:int
    offset*:int
    sql*:string

#******** Filter ********
proc comp[T:int|int64|float|string](self:var SqlStmt,val:T,op:string):SqlStmt=
  result = self
  result.vals.add(newVar(val))
  result.stmt = self.fields[0] & " " & op & " " & '?'

proc `==`*[T:int|int64|float|string](self:var SqlStmt,val:T):SqlStmt=
  return comp(self,val,"=")

proc `>`*[T:int|int64|float|string](self:var SqlStmt,val:T):SqlStmt=
  return comp(self,val,">")

proc `<`*[T:int|int64|float|string](self:var SqlStmt,val:T):SqlStmt=
  return comp(self,val,"<")

proc `>=`*[T:int|int64|float|string](self:var SqlStmt,val:T):SqlStmt=
  return comp(self,val,">=")

proc `<=`*[T:int|int64|float|string](self:var SqlStmt,val:T):SqlStmt=
  return comp(self,val,"<=")

proc `!=`*[T:int|int64|float|string](self:var SqlStmt,val:T):SqlStmt=
  return comp(self,val,"!=")

proc like*[T:int|int64|float|string](self:var SqlStmt,val:T):SqlStmt=
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

#******** SelectSql ********
proc select*(tableName:string,fields:seq[string] = @[]):SelectSql=
  new result
  result.tableName = tableName
  result.fields = fields
  var str = ""
  if fields.len() == 0 :
    str = "*"
  else:
    str = fields.join(",")
  result.sql = "SELECT" & str & "FROM " & tableName

proc filter*(self:SelectSql,whereSql:SqlStmt):SelectSql=
  self.whereSql = whereSql
  return self

proc filter*(self:SelectSql,whereSql:SqlStmt,logic:string):SelectSql=
  assert(self.whereSql.stmt != "")
  assert(whereSql.stmt != "")
  self.whereSql.vals.add(whereSql.vals)
  self.whereSql.stmt = "(" & self.whereSql.stmt & ")" & logic & "(" & whereSql.stmt & ")"
  return self

proc andFilter*(self:SelectSql,whereSql:SqlStmt):SelectSql=
  return filter(self,whereSql," AND ")
  
proc orFilter*(self:SelectSql,whereSql:SqlStmt):SelectSql=
  return filter(self,whereSql," OR ")

proc notFilter*(self:SelectSql):SelectSql=
  self.whereSql = not self.whereSql
  return self

proc sort*(self:SelectSql,orderBySql:SqlStmt):SelectSql=
  # vals: 1 asc , 0 desc , every field from fields has asc or desc from vals
  self.orderBySql.fields.add(orderBySql.fields)
  self.orderBySql.vals.add(orderBySql.vals)
  var str =""
  for i in 0..self.orderBySql.fields.len()-1:
    str = str & "," & self.orderBySql.fields[i]
    if self.orderBySql.vals[i].val != 1:
      str = str & " DESC"
  str[0]=" "
  self.orderBySql.stmt = str
  return self

proc sort*(self:SelectSql,fieldName:string,asc:bool=true):SelectSql=
  # vals: 1 asc , 0 desc , every field from fields has asc or desc from vals
  self.orderBySql.fields.add(fieldName)
  if asc:
    self.orderBySql.vals.add(newVar(1))
  else:
    self.orderBySql.vals.add(newVar(0))
  return self

proc limit*(self:SelectSql,limit,offset:int):SelectSql=
  self.limit = limit
  self.offset = offset
  return self

proc getSelectSql*(self:SelectSql):string=
  var whereSql =""
  var orderBySql =""
  var limitSql = ""
  if self.whereSql.stmt != ""
     self.sql = self.sql & " WHERE " & self.whereSql.stmt
  if self.orderBySql.stmt != "" :
    self.sql = self.sql & " ORDERBY " & self.orderBySql.stmt
  if self.limit != 0:
    self.sql = self.sql & " LIMIT " & $self.limit
    if self.offset != 0:
      self.sql = self.sql & " OFFSET " & &self.offset
  return self.sql

proc all*(self:SelectSql,db:DbConn):seq[Row]=
  var sql = self.getSelectSql()
  var vals = self.whereSql.vals
  if self.whereSql.vals.len()==0:
    return db.getAllRows(sql)
  var selectStmt = db.prepare(sql)
  var i = 0;
  for v in  vals:
    i += 1
    selectStmt.bindParam(v,i)
  result = getAllRows(db,selectStmt)

proc getInsertSql(self:SelectSql):string=
  assert(self.inserSQl.fields.len()!=0)
  var str ="?"
  for i in 1..self.inserSQl.fields.len()-1:
    str = str & "," & "?"
  result =  "INSERT INTO " & self.tableName & " (" & fields.getNames() & ") VALUES (" & str & ");"

proc insert*(self:SelectSql,vals:seq[ref MVariant]):SelectSql=
  self.inserSQl.vals = vals
  return self

proc execInsert(self:SelectSql,db:DbConn):bool=
  var sql = self.getInsertSql()
  var insterStmt = db.prepare(sql)
  var i = 0;
  for v in  self.inserSQl.vals:
    i += 1
    insterStmt.bindParam(v,i)
  return db.tryExec(insterStmt)
  

  


    
  


    
proc createTable() = 
  discard
  
#***************************************
#**************** tests ****************
#***************************************
when isMainModule:
  #import sugar
  echo "Test"
  var mint = newMfieldMeta("id",Int)
  var mstr = newMfieldMeta("name",String)
  var f = newMfield(1,mint)
  f.setVal(10)
  echo f,"-->",f.meta()
  f.setVal("15")
  echo f,"-->",f.meta()
  var rec = newMrecord()
  rec.add(newMfield(1,mint))
  rec.add(newMfield("nour",mstr))
  echo rec
  rec.setVals(@["10","sofia"])
  echo rec

  #echo f,"-->",f.meta()
