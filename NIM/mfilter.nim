import ./mvariant,strFormat
type
  MFilter* = object
    sql*:string
    field_name*:string
    vals*:seq[ref MVariant]

proc `$`*(self:MFilter):string=
  if self.vals.len() == 0:
    result = self.sql & "\n" & "vals: empty"
  else:
    result = self.sql & "\n" & "vals:" & $(self.vals)
 



proc `==`*(filter1: MFilter,val:ref MVariant):MFilter=
  result = filter1
  result.sql = &"{filter1.sql}{val.name} = ?" 
  result.vals.add(val)

proc `==`*[T:int|int64|string|float](filter1:MFilter,val:T):MFilter=
  assert(filter1.field_name != "")
  result = filter1
  result.vals.add(newVar(val,filter1.field_name))  
  result.sql = filter1.field_name & " = ? "
  

proc `>`*(filter1: MFilter,val:ref MVariant):MFilter=
  result = filter1
  result.sql = &"{filter1.sql}{val.name} > ?"
  result.vals.add val

proc `>`*[T:int|int64|string|float](filter1:MFilter,val:T):MFilter=
  assert(filter1.field_name != "")
  result = filter1
  result.vals.add(newVar(val,filter1.field_name))  
  result.sql = filter1.field_name & " > ? "

proc `>=`*(filter1: MFilter,val:ref MVariant):MFilter=
  result = filter1
  result.sql = &"{filter1.sql}{val.name} >= ?"
  result.vals.add val

proc `>=`*[T:int|int64|string|float](filter1:MFilter,val:T):MFilter=
  assert(filter1.field_name != "")
  result = filter1
  result.vals.add(newVar(val,filter1.field_name))  
  result.sql = filter1.field_name & " >= ? "

proc `<`*(filter1:  MFilter,val:ref MVariant):MFilter=
  result = filter1
  result.sql = &"{filter1.sql}{val.name} < ?" 
  result.vals.add val

proc `<`*[T:int|int64|string|float](filter1:MFilter,val:T):MFilter=
  assert(filter1.field_name != "")
  result = filter1
  result.vals.add(newVar(val,filter1.field_name))  
  result.sql = filter1.field_name & " < ? "

proc `<=`*(filter1: MFilter,val:ref MVariant):MFilter=
  result = filter1
  result.sql = &"{filter1.sql}{val.name} <= ?"
  result.vals.add val

proc `<=`*[T:int|int64|string|float](filter1:MFilter,val:T):MFilter=
  assert(filter1.field_name != "")
  result = filter1
  result.vals.add(newVar(val,filter1.field_name))  
  result.sql = filter1.field_name & " <= ? "

proc like*(filter1: MFilter,val:ref MVariant):MFilter=
  result = filter1
  result.sql = &"{filter1.sql} {val.name} like ?" 
  result.vals.add val

proc `and`*(filter1:MFilter,filter2:MFilter):MFilter=
  result = filter1
  result.sql = &"{filter1.sql} and {filter2.sql}"
  for val in filter2.vals:
    result.vals.add(val)

proc `or`*(filter1: MFilter,filter2:MFilter):MFilter=
  result = filter1
  result.sql = &"{filter1.sql} or {filter2.sql}"
  for val in filter2.vals:
    result.vals.add(val)

when isMainModule:
  var v1 = Var(-10,"mimi")
  var v2 = Var("10","nono")
  var v3 = Var(-10.int64(),"big")
  #v.init(5,"ana")
  echo "v1:",v1
  echo "v2:",v2
  echo "v3:",v3
  v1.setVal("-565")
  echo "setVal from str:",v1
  
  var filter = MFilter()
  filter.sql = "select * from user "
  var filter2 = MFilter()
  echo ",,,,,,"
  filter = filter == Var(5,"id").MVariant() and filter2 > Var(10,"id").MVariant()
  echo filter
