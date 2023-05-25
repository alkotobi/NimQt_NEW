import mlibrary,strFormat,seqUtils

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
proc getFieldsNames(self:User):seq[string]=
  result = @["id","name","login","pass"]

proc sqlCreateTable(self:User,engine = "SQLITE"):string=
  if engine == "SQLITE":
    result = "CREATE TABLE IF NOT EXISTS user(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,login TEXT,pass TEXT);"
  elif engine == "MYSQL":
    result = "CREATE TABLE IF NOT EXISTS user(id INTEGER PRIMARY KEY AUTO_INCREMENT,name TEXT,login TEXT,pass TEXT);"
    



var user = newUser(newMVariant(1,"id"),newMVariant("merhab","name"),newMVariant("merhab","login"),newMVariant("123","pass"))
echo user

