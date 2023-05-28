import ../mlibrary,strFormat,engine,dbTable
echo engine.engine
when engine.engine == "SQLITE":
  import std/db_sqlite
type
  User* = ref object of DbTable
    name,login,pass : MVariant

proc `@User`*():MFilter=
  result.sql = "SELECT * FROM user WHERE "

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
  

##---------------------------------------
##TESTS
#----------------------------------------
 
var user = newUser(newMVariant("nour","name"),newMVariant("abi","login"),newMVariant("567","pass"))
var name = user.name.getStringValue()
echo name
assert(name == name)
var login = user.login.getStringValue()
echo login
assert(login == "abi")
var pass = user.pass.getStringValue()
assert(pass == "567")
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
