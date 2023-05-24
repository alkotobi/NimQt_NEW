import strFormat
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
  MVariant* = ref object of RootRef
    name:string
    case kind: Kind
    of MInt:
      valInt: int
    of MString:
      valString: string
    of MFloat:
      valFloat: float
    of MNil:
      valNil:bool
proc newMVariant*():MVariant=
  new result
proc newMVariant*(val:int,name=""):MVariant=
  result = MVariant(name:name,kind:MInt,valInt:val)
proc newMVariant*(val:float,name=""):MVariant=
  result = MVariant(name:name,kind:MFloat,valFloat:val)
proc newMVariant*(val:string,name=""):MVariant=
  result = MVariant(name:name,kind:MString,valString:val)
proc getIntValue*(self:MVariant):int=
  assert self.kind == MInt
  result = self.valInt
proc getStringValue*(self:MVariant):string=
  assert self.kind == MString
  result = self.valString
proc getFloatValue*(self:MVariant):float=
  assert self.kind == MFloat
  result = self.valFloat
proc init*(self:MVariant,intVal:int,name:string="")=
  self.kind = MInt
  self.valInt = intVal
  self.name = name
proc init*(self:MVariant,strVal:string,name:string="")=
  self.kind = MString
  self.valString = strVal
  self.name = name
proc init*(self:MVariant,floatVal:float,name:string="")=
  self.kind = MFloat
  self.valFloat = floatVal
  self.name =name
proc init*(self:MVariant,name:string="")=
  self.kind = MNil
  self.name = name
proc beforeSetVal(oldVal:MVariant,newVal:MVariant):bool=
  return true
proc afterSetVal(self:MVariant)=
  return
proc setVal*(self:MVariant,val:MVariant)=
  if not beforeSetVal(self,val):
    return
  assert(self.kind == val.kind)
  case self.kind:
    of MInt:
      self.valInt = val.valInt
    of MFloat:
      self.valFloat = val.valFloat
    of MString:
      self.valString = val.valString
    of MNil:
      return
  afterSetVal(self)

proc `$`*(self:MVariant):string=
  case self.kind:
    of MInt:    
      result = &"name:{self.name}\nkind:{self.kind}\nVal:{self.valint}\n"
    of MFloat:    
      result = &"name:{self.name}\nkind:{self.kind}\nVal:{self.valfloat}\n"
    of MString:    
      result = &"name:{self.name}\nkind:{self.kind}\nVal:{self.valstring}\n"
    of MNil:    
      result = &"name:{self.name}\nkind:{self.kind}\n"
type
  MVariantSeq* = seq[MVariant]

    
#-----------------------------
#MVariant End
#-----------------------------

var v = newMVariant(10,"mimi")
#v.init(5,"ana")
echo(v)
