import mlibrary , typeinfo

type Db* = object of RootObj
  id:int

proc getFieldsNames*(self :Db):seq[string]=
  for name , val in self.fieldPairs:
    result.add name

proc getFieldsCount*(self:auto):int=
  for name , val in self.fieldPairs:
    result+=1

var a :Db
a.id=0

echo a.getFieldsNames()
echo a.getFieldsCount
type User* = ref object of Db
  login:string
  pass:string

var b = new User
b.login ="a"
b.pass ="f"
echo "hi.:",getFieldsCount(b[])
