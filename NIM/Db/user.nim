import ../mlibrary,strFormat,engine,dbTable

when engine.engine == "SQLITE":
  import std/db_sqlite

type
  User* = ref object of DbTable
    name,login,pass : MVariant

proc name*():MFilter=
  new result
  result.field_name = "name"

proc login*():MFilter=
  new result
  result.field_name = "login"

proc pass*():MFilter=
  new result
  result.field_name = "pass"

proc newUser():User=
  new result
  init(result.DbTable())
  result.name = newMVariant("","name")
  result.pass = newMVariant("","pass")
  result.login = newMVariant("","login")

proc newUser*(id,name,login,pass:MVariant):User=
  new result
  init(result.DbTable(),id)
  result.name = name
  result.pass = pass
  result.login =login

proc newUser*(name,login,pass:MVariant):User=
  new result
  init(result.DbTable())
  result.name = name
  result.pass = pass
  result.login =login

proc `$`*(self:User):string = 
  result = &"{self.id}\n{self.name}\n{self.login}\n{self.pass}\n"

proc getFields*(self:User):seq[MVariant]=
  result.add self.id
  result.add self.name
  result.add self.login
  result.add self.pass

proc getCaptions*(self:User):seq[string]=
  result = @["id","name","login","pass"]

proc getFieldsCount*(self:User):int=
  result = 4

proc getFieldsNames*(self:User):seq[string]=
  result = @["id","name","login","pass"]

proc newUser*(strs:seq[string]):User=
  result = newUser()
  assert(strs.len() == result.getFieldsCount())
  fieldsFromStrs(result.getFields(),strs)

proc createTable*(self:User,db:DbConn,engine = "SQLITE"):bool=
  var str = ""
  if engine == "SQLITE":
    str = "CREATE TABLE IF NOT EXISTS user(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,login TEXT,pass TEXT);"
  elif engine == "MYSQL":
    str = "CREATE TABLE IF NOT EXISTS user(id INTEGER PRIMARY KEY AUTO_INCREMENT,name TEXT,login TEXT,pass TEXT);"
  return db.tryExec(str.sql())

proc insert*(self:User,db:DbConn):bool=
  var id= db.tryInsertID(sql"INSERT INTO user (name,login,pass) VALUES (?,?,?);",self.name.getStringValue(),self.login.getStringValue(),self.pass.getStringValue())
  self.id.setVal(id)
  result = id > 0

proc update*(self:User,db:DbConn):bool=
  var str = &"UPDATE user set name = ? , login = ? , pass = ? WHERE id =?"
  result = db.tryExec(str.sql,self.name.getStringValue(),self.login.getStringValue(),self.pass.getStringValue(),self.id.getBigIntValue())

proc delete*(self:User,db:DbConn):bool=
  var str = "DELETE FROM user WHERE id=?"
  result = db.tryExec(str.sql,self.id.getBigIntValue())

proc userSelect*(filter:MFilter = nil):MFilter=
  new result
  if not filter.isNil():
    result.sql = "SELECT * FROM user WHERE " & filter.sql 
    result.vals = filter.vals
  else:
    result.sql="SELECT * FROM user"

proc all*(filter:MFilter,db:DbConn):seq[Row]=
  if filter.vals.len()==0:
    return db.getAllRows(filter.sql.sql())
  var selectStmt = db.prepare(filter.sql)
  var i = 0;
  for v in  filter.vals:
    i += 1
    case v.kind:
      of MInt:
        selectStmt.bindParam(i,v.getIntValue())
      of MBigInt:
        selectStmt.bindParam(i,v.getBigIntValue())
      of MString:
        selectStmt.bindParam(i,v.getStringValue())
      of MFloat:
        selectStmt.bindParam(i,v.getFloatValue())
      of MNil:
        selectStmt.bindNull(i)
  result = getAllRows(db,selectStmt)

##---------------------------------------
##TESTS
#----------------------------------------

var user = newUser(newMVariant("nour","name"),newMVariant("abi","login"),newMVariant("567","pass"))
let db = open("mytest.db", "", "", "")
# echo db.tryInsertID(sql"INSERT INTO user (name,login,pass) VALUES (?,?,?);",name,login,pass)
let v=user.createTable(db)
echo "table created:",v
echo "insert:",user.insert(db)
echo user.id
user.name.setVal("alola")
echo "update:",user.update(db)
var flds = user.getFields()
flds[1].setVal("amine")
echo "name after change in seq:",user.name
discard user.update(db)
user.getFields().fieldsFromStrs(@["1","moad","mohamed","123456"])
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
echo "after get from db:",newUser(t.getCurrent())
