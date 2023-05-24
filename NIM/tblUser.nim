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

proc getFieldsSeq*(self:User):ref seq[MVariant]=
  new result
  result[].add self.id
  result[].add self.name
  result[].add self.login
  result[].add self.pass
  



var user = newUser(newMVariant(1,"id"),newMVariant("merhab","name"),newMVariant("merhab","login"),newMVariant("123","pass"))
echo user
