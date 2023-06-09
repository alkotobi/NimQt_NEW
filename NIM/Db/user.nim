import ../mvariant,../mfilter,../mtable,strFormat,engine,dbTable

when engine.engine == "SQLITE":
  import std/db_sqlite

type
  User* = ref object of DbTable
    name,login,pass : ref MStrVar

proc name*():MFilter=
  result.field_name = "name"

proc login*():MFilter=
  result.field_name = "login"

proc pass*():MFilter=
  result.field_name = "pass"

proc newUser():User=
  new result
  init(result.DbTable())
  result.name = newVar("","name")
  result.pass = newVar("","pass")
  result.login = newVar("","login")

proc newUser*(id:ref MInt64Var,name,login,pass:ref MStrVar):User=
  new result
  init(result.DbTable(),id)
  result.name = name
  result.pass = pass
  result.login =login

proc newUser*(name,login,pass:ref MStrVar):User=
  new result
  init(result.DbTable())
  result.name = name
  result.pass = pass
  result.login =login

proc `$`*(self:User):string = 
  result = &"{self.id}\n{self.name}\n{self.login}\n{self.pass}\n"

proc getFields*(self:User):seq[ref MVariant]=
  result.add(self.id)
  result.add(self.name)
  result.add(self.login)
  result.add (self.pass)

proc getCaptions*(self:User):seq[string]=
  result = @["id","name","login","pass"]

proc getFieldsCount*(self:User):int=
  result = 4

proc getFieldsNames*(self:User):seq[string]=
  result = @["id","name","login","pass"]
proc fieldsFromStrs*(self:User,strs:seq[string])=
  assert(strs.len() == self.getFieldsCount())
  echo strs[0]
  self.id.setVal(strs[0])
  self.name.setVal(strs[1])
  self.login.setVal(strs[2])
  self.pass.setVal(strs[3])
proc newUser*(strs:seq[string]):User=
  result = newUser()
  fieldsFromStrs(result,strs)
  # fieldsFromStrs(result.getFields(),strs)

proc createTable*(self:User,db:DbConn,engine = "SQLITE"):bool=
  var str = ""
  if engine == "SQLITE":
    str = "CREATE TABLE IF NOT EXISTS user(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,login TEXT,pass TEXT);"
  elif engine == "MYSQL":
    str = "CREATE TABLE IF NOT EXISTS user(id INTEGER PRIMARY KEY AUTO_INCREMENT,name TEXT,login TEXT,pass TEXT);"
  return db.tryExec(str.sql())

proc insert*(self:User,db:DbConn):bool=
  var id= db.tryInsertID(sql"INSERT INTO user (name,login,pass) VALUES (?,?,?);",self.name.val(),self.login.val(),self.pass.val())
  self.id.setVal(id)
  result = id > 0

proc update*(self:User,db:DbConn):bool=
  var str = &"UPDATE user set name = ? , login = ? , pass = ? WHERE id =?"
  result = db.tryExec(str.sql,self.name.val(),self.login.val(),self.pass.val(),self.id.val())

proc delete*(self:User,db:DbConn):bool=
  var str = "DELETE FROM user WHERE id=?"
  result = db.tryExec(str.sql,self.id.val())

proc userSelect*():MFilter=
  result.sql = "SELECT * FROM user"

proc userSelect*(filter:MFilter ):MFilter=
  if filter.sql != "":
    result.sql = userSelect().sql & " WHERE " & filter.sql 
    result.vals = filter.vals
  else:
    result=userSelect()

proc all*(filter:MFilter,db:DbConn):seq[Row]=
  if filter.vals.len()==0:
    return db.getAllRows(filter.sql.sql())
  var selectStmt = db.prepare(filter.sql)
  var i = 0;
  for v in  filter.vals:
    i += 1
    case v.kind:
      of "int":
        selectStmt.bindParam(i,v.MIntVarRef().val())
      of "int64":
        selectStmt.bindParam(i,v.MInt64VarRef().val())
      of "string":
        selectStmt.bindParam(i,v.MStrVarRef().val())
      of "float":
        selectStmt.bindParam(i,v.MFloatVarRef().val())
      of "nil":
        selectStmt.bindNull(i)
  result = getAllRows(db,selectStmt)

##---------------------------------------
##TESTS
#----------------------------------------

var user = newUser(newVar("nour","name"),newVar("abi","login"),newVar("567","pass"))
let db = open("mytest.db", "", "", "")
# echo db.tryInsertID(sql"INSERT INTO user (name,login,pass) VALUES (?,?,?);",name,login,pass)
let v=user.createTable(db)
echo "table created:",v
echo "insert:",user.insert(db)
echo user.id
user.name.setVal("alola")
echo "update:",user.update(db)
var flds = user.getFields()
flds[1].MStrVarRef().setVal("amine")
echo "name after change in seq:",user.name
discard user.update(db)
user.fieldsFromStrs(@["1","moad","mohamed","123456"])
echo user

var f = userSelect(id() > 0)
echo "filter:", f
var rows = f.all(db)
echo rows
var t = newMTable(rows)
t.first()
echo "first:",t.getCurrent()
t.prior()
echo "prior after first:",t.getCurrent()
t.next()
echo "next:",t.getCurrent()
t.last()
echo "last:",t.getCurrent()
t.next()
echo "next after last:",t.getCurrent()
var use = newUser(t.getCurrent())
echo "after get from db:",use
