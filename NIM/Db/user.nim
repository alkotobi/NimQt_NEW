import ../mlibrary,strFormat,seqUtils,engine
echo engine.engine
when engine.engine == "SQLITE":
  import std/db_sqlite
type
  User* = ref object of RootObj
    id,name,login,pass : MVariant
proc newUser(id,name,login,pass:MVariant):User=
  new result
  result.id = id
  result.name = name
  result.pass = pass
  result.login =login

proc `$`(self:User):string = 
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

proc insert*(self:User,db:DbConn):int=
  var id= db.tryInsertID(sql"INSERT INTO user (name,login,pass) VALUES (?,?,?);",self.name.getStringValue(),self.login.getStringValue(),self.pass.getStringValue()).int()
  self.id.setVal(newMVariant(id))
  result = id
proc update*(self:User,db:DbConn):bool=
  var str = &"UPDATE user set name = ? , login = ? , pass = ? WHERE id =?"
  result = db.tryExec(str.sql,self.name.getStringValue(),self.login.getStringValue(),self.pass.getStringValue(),self.id.getIntValue())
  
var user = newUser(newMVariant(1,"id"),newMVariant("nour","name"),newMVariant("abi","login"),newMVariant("567","pass"))
var name = user.name.getStringValue()
echo name
var login = user.login.getStringValue()
echo login
var pass = user.pass.getStringValue()
echo pass
let db = open("mytest.db", "", "", "")
# echo db.tryInsertID(sql"INSERT INTO user (name,login,pass) VALUES (?,?,?);",name,login,pass)
let v=user.createTable(db)
let id = user.insert(db)



