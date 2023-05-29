# mlibrary.nim
#
# By Merhab Noureddine
# On Saturday, 27 May 2023.
#
#------------------------------------------------------
import strFormat,strUtils

#--------------------------------
#int64
#--------------------------------
type
  MTable[T] = ref object of RootObj
    data:seq[T]
    index:int64
proc newMTable*[T](data:seq[T]):MTable[T]=
  new result
  result.data =data
  if data.len>0:
    result.index = 0
  else:
    result.index = -1

proc eof*[T](self:MTable[T]):bool=
  return self.index == self.data.len()-1

proc bof*[T](self:MTable[T]):bool=
  return self.index == 0;

proc getCurrent*[T](self:MTable[T]):T=
  if self.index >= 0:
    return self.data[self.index]
  else:
    assert(false)

proc goTo*[T](self:MTable[T],ind:int64)=
  assert(ind<self.data.len)
  assert(ind >= 0)
  self.index = ind

proc first*[T](self:MTable[T])=
  if not self.bof:
    self.goTo(0)

proc next*[T](self:MTable[T])=
  if not self.eof:
    self.goTo(self.index+1)

proc prior*[T](self:MTable[T])=
  if not self.bof:
    self.goTo(self.index-1)

proc last*[T](self:MTable[T])=
  if not self.eof:
    self.goTo(self.data.len()-1)

proc `[]`*[T](self:MTable[T],index:int64):T=
  return self.data[index]

proc `[]=`*[T](self:MTable[T],index:int64,val:T)=
    self.data[index] = val

proc add*[T](self:MTable[T],val:T)=
  self.data.add(val)
#--------------------------------

#MStack
type
  MStack*[T] = object
    data: seq[T]

proc newMStack*[T](): MStack[T] =
  result.data = newSeq[T]()  # initialize an empty sequence

proc push*[T](s: var MStack[T], value: T) =
  s.data.add(value)

# proc pop*[T](s: var Stack[T]) =
#     if s.data.len > 0:
#         s.data.delete(0)

proc pop*[T](s: var MStack[T]):T =
    if s.data.len > 0:
        result = s.data[s.data.len-1]
        s.data.delete(s.data.len-1)

proc getCurrent*[T](s: var MStack[T]):T=
    if s.data.len() > 0:
        result = s.data[s.data.len-1]
    else: result = nil

proc isEmpty*[T](s: var MStack[T]):bool=
  result = s.data.len == 0

proc join*(str:string,strings:seq[string]):string=
  var s = strings[0]
  var last = strings.len-1
  for i in 1..last:
    s = s & str & strings[i]
  return s


#_____________________________
#MVariant
#-----------------------------
type
  Kind* = enum
    MInt
    MString
    MFloat
    MNil
    MBigInt
  MVariant* = ref object of RootObj
    name:string
    case kind*: Kind
    of MInt:
      valInt: int
    of MString:
      valString: string
    of MFloat:
      valFloat: float
    of MBigInt:
      valBigInt:int64
    of MNil:
      valNil:string
proc newMVariant*():MVariant=
  new result
  result.kind = MNil
  result.valNil = "nil"
proc newMVariant*(val:int,name=""):MVariant=
  result = MVariant(name:name,kind:MInt,valInt:val)
proc newMVariant*(val:float,name=""):MVariant=
  result = MVariant(name:name,kind:MFloat,valFloat:val)
proc newMVariant*(val:string,name=""):MVariant=
  result = MVariant(name:name,kind:MString,valString:val)
proc newMVariant*(val:int64,name=""):MVariant=
  result = MVariant(name:name,kind:MBigInt,valBigInt:val)
proc getIntValue*(self:MVariant):int=
  assert self.kind == MInt
  result = self.valInt
proc getBigIntValue*(self:MVariant):int64=
  assert self.kind == MBigInt
  result = self.valBigInt
proc getStringValue*(self:MVariant):string=
  assert self.kind == MString
  result = self.valString
proc getFloatValue*(self:MVariant):float=
  assert self.kind == MFloat
  result = self.valFloat
proc setVal*(self:MVariant,val:MVariant)=
  assert(self.kind == val.kind)
  case self.kind:
    of MInt:
      self.valInt = val.valInt
    of MFloat:
      self.valFloat = val.valFloat
    of MString:
      self.valString = val.valString
    of MBigInt:
      self.valBigInt = val.valBigInt
    of MNil:
      assert(false)
proc setVal*(self:MVariant,d:int)=
  assert(self.kind == MInt)
  self.valInt = d
proc setVal*(self:MVariant,d:int64)=
  assert(self.kind == MBigInt)
  self.valBigInt = d
proc setVal*(self:MVariant,str:string)=
  case self.kind:
    of MInt:
      self.valInt = str.parseInt
    of MFloat:
      self.valFloat = str.parseFloat
    of MString:
      self.valString = str
    of MBigInt:
      self.valBigInt = str.parseBiggestInt
    of MNil:
      assert(false)
proc setVal*(self:MVariant,f:float)=
  assert(self.kind == MFloat)
  self.valFloat = f

proc `$`*(self:MVariant):string=  
  case self.kind:
    of MInt:
      result = $ self.valint
    of MFloat:
      result = $ self.valfloat
    of MString:
      result =self.valstring
    of MBigInt:
      result = $ self.valBigint
    of MNil:
      assert(false)

proc `==`*(v1:MVariant,v2:MVariant):bool=
  if v1.kind == MInt and v2.kind == MBigInt:
     return v1.valInt == v2.valBigInt
  if v2.kind == MInt and v1.kind == MBigInt:
     return v2.valInt == v1.valBigInt
  if v1.kind != v2.kind:
    return false
  case v1.kind:
    of MInt:
      return v1.valInt == v2.valInt
    of MFloat:
      return v1.valFloat == v2.valFloat
    of MString:
      return v1.valString == v2.valString
    of MBigInt:
      return v1.valBigInt == v2.valBigInt
    of MNil:
      assert(false)
type
  MVariantSeq* = seq[MVariant]
type
  MFNBeforSetVal* = proc(oldVar:MVariant,newVar:MVariant):bool
  MFNAfterSetVal* = proc(self:MVariant)
  MVariantEvent* = ref object of MVariant
    beforeSetValFuncs : seq[MFNBeforSetVal]
    afterSetValFuncs : seq[MFNAfterSetVal]
proc addBeforSetValFunc*(self:MVariantEvent,beforeFunc:MFNBeforSetVal)=
  if beforeFunc notin self.beforeSetValfuncs:
    self.beforeSetValFuncs.add(beforeFunc)
proc addAfterSetValFunc*(self:MVariantEvent,afterFunc:MFNAfterSetVal)=
  if afterFunc notin self.afterSetValfuncs:
    self.afterSetValFuncs.add(afterFunc)
proc execBforeSetValFuncs(self:MVariantEvent,newVal:MVariantEvent):bool=
  for fn in self.beforeSetValFuncs:
    if not fn(self,newVal):
      return false
  return true
proc execAfterSetValFuncs(self:MVariantEvent)=
  for fn in self.afterSetValFuncs:
    fn(self)
proc setVal*(self:MVariantEvent,newVal:MVariantEvent):bool=
  if self.execBforeSetValFuncs(newVal):
    self.MVariant().setVal(newVal.MVariant())
  self.execAfterSetValFuncs()
  
    
#-----------------------------
#MVariant End
#-----------------------------
#-----------------------------
#MFilter3
#-----------------------------
type
  MFilter* = ref object
    sql*:string
    field_name*:string
    vals*:seq[MVariant]

proc `$`*(self:MFilter):string=
  if self.vals.len() == 0:
    result = self.sql & "\n" & "vals: empty"
  else:
    result = self.sql & "\n" & "vals:" & $ self.vals
 



proc `==`*(filter1: MFilter,val:MVariant):MFilter=
  filter1.sql = &"{filter1.sql}{val.name} = ?" 
  filter1.vals.add val
  return filter1

proc `==`*[T:int|int64|string|float](filter1:MFilter,val:T):MFilter=
  assert(filter1.field_name != "")
  filter1.vals.add(newMVariant(val,filter1.field_name))  
  filter1.sql = filter1.field_name & " = ? "
  return filter1
  

proc `>`*(filter1: MFilter,val:MVariant):MFilter=
  filter1.sql = &"{filter1.sql}{val.name} > ?"
  filter1.vals.add val
  return filter1

proc `>`*[T:int|int64|string|float](filter1:MFilter,val:T):MFilter=
  assert(filter1.field_name != "")
  filter1.vals.add(newMVariant(val,filter1.field_name))  
  filter1.sql = filter1.field_name & " > ? "
  return filter1

proc `>=`*(filter1: MFilter,val:MVariant):MFilter=
  filter1.sql = &"{filter1.sql}{val.name} >= ?"
  filter1.vals.add val
  return filter1

proc `>=`*[T:int|int64|string|float](filter1:MFilter,val:T):MFilter=
  assert(filter1.field_name != "")
  filter1.vals.add(newMVariant(val,filter1.field_name))  
  filter1.sql = filter1.field_name & " >= ? "
  return filter1

proc `<`*(filter1: MFilter,val:MVariant):MFilter=
  filter1.sql = &"{filter1.sql}{val.name} < ?" 
  filter1.vals.add val
  return filter1

proc `<`*[T:int|int64|string|float](filter1:MFilter,val:T):MFilter=
  assert(filter1.field_name != "")
  filter1.vals.add(newMVariant(val,filter1.field_name))  
  filter1.sql = filter1.field_name & " < ? "
  return filter1

proc `<=`*(filter1: MFilter,val:MVariant):MFilter=
  filter1.sql = &"{filter1.sql}{val.name} <= ?"
  filter1.vals.add val
  return filter1

proc `<=`*[T:int|int64|string|float](filter1:MFilter,val:T):MFilter=
  assert(filter1.field_name != "")
  filter1.vals.add(newMVariant(val,filter1.field_name))  
  filter1.sql = filter1.field_name & " <= ? "
  return filter1

proc like*(filter1: MFilter,val:MVariant):MFilter=
  filter1.sql = &"{filter1.sql} {val.name} like ?" 
  filter1.vals.add val
  return filter1

proc `and`*(filter1: MFilter,filter2:MFilter):MFilter=
  result = filter1
  filter1.sql = &"{filter1.sql} and {filter2.sql}"
  for val in filter2.vals:
    filter1.vals.add(val)

proc `or`*(filter1: MFilter,filter2:MFilter):MFilter=
  result = filter1
  filter1.sql = &"{filter1.sql} or {filter2.sql}"
  for val in filter2.vals:
    filter1.vals.add(val)

when isMainModule:
  var v1 = newMVariant(-10,"mimi")
  var v2 = newMVariant("10","nono")
  var v3 = newMVariant(-10.int64(),"big")
  #v.init(5,"ana")
  echo "v1:",v1
  echo "v2:",v2
  echo "v3:",v3
  echo "v1==v2:",v1 == v2
  echo "v1==v3:",v1 == v3
  echo($(5.int64))
  v1.setVal("-565")
  echo "setVal from str:",v1
  
  var filter = new MFilter
  filter.sql = "select * from user "
  var filter2 = new MFilter
  
  discard filter == newMVariant(5,"id") and filter2 > newMVariant(10,"id")
  echo filter
