import strUtils,sugar

const
  String* = "string"
  Int* = "int"
  Int64* = "int64"
  Float* = "float"
type
  MFNBeforSetVal* = proc(oldVar:MVariant,newVar:MVariant):bool
  MFNAfterSetVal* = proc(self:MVariant)
  MVariantMeta* = ref object of RootObj
    kind*:string
    name*:string
  MVariant* = object of RootObj
    kind*:string
    name*:string
    beforeSetValFuncs* :seq[MFNBeforSetVal]
    afterSetValFuncs* : seq[MFNAfterSetVal]


proc execBforeSetValFuncs(self:MVariant|ref MVariant,newVal:MVariant):bool=
  for fn in self.beforeSetValFuncs:
    if not fn(self,newVal):
      return false
  return true
proc execAfterSetValFuncs(self:MVariant|ref MVariant)=
  for fn in self.afterSetValFuncs:
    fn(self)
proc addBeforSetValFunc*(self:var MVariant,beforeFunc:MFNBeforSetVal)=
  if beforeFunc notin self.beforeSetValfuncs:
    self.beforeSetValFuncs.add(beforeFunc)
proc addBeforSetValFunc*(self:ref MVariant,beforeFunc:MFNBeforSetVal)=
  addBeforSetValFunc(self[],beforeFunc)
proc addAfterSetValFunc*(self:var MVariant,afterFunc:MFNAfterSetVal)=
  if afterFunc notin self.afterSetValfuncs:
    self.afterSetValFuncs.add(afterFunc)
proc addAfterSetValFunc*(self:ref MVariant,afterFunc:MFNAfterSetVal)=
  addAfterSetValFunc(self[],afterFunc)

type
  MNilVar* = object of MVariant
  MNilVarRef* = ref MNilVar
proc newVar*():ref MNilVar=
  new result
  result.kind = "nil"
proc Var*():MNilVar=
  result.kind = "nil"
proc isNil*(self:MVariant|ref MVariant):bool =
  return self.kind ==  "nil"

type MVariantList* = seq[ref MVariant]
proc `[]`*(varList:MVariantList,name:string):ref MVariant=
  for v in varList:
    if v.name == name :
      return v
  return newVar()

type
  MIntVar* = object of MVariant
    intVal :int
  MIntVarRef* = ref MIntVar
proc val*(self: MIntVar|ref MIntVar):int =
  result = self.intVal
proc newVar*(val:int,name=""):ref MIntVar=
  new result
  result.name = name
  result.kind = "int"
  result.intVal = val
proc Var*(val:int,name=""):MIntVar=
  result.name = name
  result.kind = "int"
  result.intVal = val
proc `$`*(self:MIntVar|ref MIntVar):string=
  result = `$`(self.intVal)
proc setVal*(self:var MIntVar,val:int,runBeforeFuncs:bool = false,runAfterFuncs=false)=
  if self.intVal == val : return
  var accept  =true
  if runBeforeFuncs:
    accept = self.execBforeSetValFuncs(Var(val))
  if accept:
    self.intVal = val
  if runAfterFuncs:
    self.execAfterSetValFuncs()
proc setVal*(self:var MIntVar,val:string,runBeforeFuncs:bool = false,runAfterFuncs=false)=
  self.setVal(val.parseInt(),runBeforeFuncs,runAfterFuncs)
proc setVal*(self:ref MIntVar,val:string,runBeforeFuncs:bool = false,runAfterFuncs=false)=
  self[].setVal(val.parseInt(),runBeforeFuncs,runAfterFuncs)
proc setVal*(self:ref MIntVar,val:int,runBeforeFuncs:bool = false,runAfterFuncs=false)=
  self[].setVal(val,runBeforeFuncs,runAfterFuncs)

type
  MInt64Var* = object of MVariant
    int64Val :int64
  MInt64VarRef* = ref MIntVar
proc val*(self: MInt64Var|ref MInt64Var):int64 =
  result = self.int64Val
proc newVar*(val:int64,name=""):ref MInt64Var=
  new result
  result.name = name
  result.kind = "int64"
  result.int64Val = val
proc Var*(val:int64,name = ""):MInt64Var=
  result.name = name
  result.kind = "int64"
  result.int64Val = val
proc `$`*(self:MInt64Var|ref MInt64Var):string=
  result = `$`(self.int64Val)
proc setVal*(self:var MInt64Var,val:int64,runBeforeFuncs:bool = false,runAfterFuncs=false)=
  if self.int64Val == val : return
  var accept  =true
  if runBeforeFuncs:
    accept = self.execBforeSetValFuncs(Var(val))
  if accept:
    self.int64Val = val
  if runAfterFuncs:
    self.execAfterSetValFuncs()
proc setVal*(self:var MInt64Var,val:string,runBeforeFuncs:bool = false,runAfterFuncs=false)=
  self.setVal(val.parseBiggestInt(),runBeforeFuncs,runAfterFuncs)
proc setVal*(self:ref MInt64Var,val:string,runBeforeFuncs:bool = false,runAfterFuncs=false)=
  setVal(self[],val,runBeforeFuncs,runAfterFuncs)
proc setVal*(self:ref MInt64Var,val:int64,runBeforeFuncs:bool = false,runAfterFuncs=false)=
  setVal(self[],val,runBeforeFuncs,runAfterFuncs)

type
  MStrVar* = object of MVariant
    strVal:string
  MStrVarRef* = ref MStrVar
proc val*(self: MStrVar|ref MStrVar):string =
  result = self.strVal
proc newVar*(val:string,name = ""):ref MStrVar=
  new result
  result.name = name
  result.kind = "string"
  result.strVal = val
proc Var*(val:string,name = ""):MStrVar=
  result.name = name
  result.kind = "string"
  result.strVal = val
proc `$`*(self:MStrVar|ref MStrVar):string=
  result = self.strVal
proc setVal*(self:var MStrVar,val:string,runBeforeFuncs:bool = false,runAfterFuncs=false)=
  if self.strVal == val : return
  var accept  =true
  if runBeforeFuncs:
    accept = self.execBforeSetValFuncs(Var(val))
  if accept:
    self.strVal = val
  if runAfterFuncs:
    self.execAfterSetValFuncs()
proc setVal*(self:ref MStrVar,val:string,runBeforeFuncs:bool = false,runAfterFuncs=false)=
  setVal(self[],val,runBeforeFuncs,runAfterFuncs)

type
  MFloatVar* = object of MVariant
    floatVal : float
  MFloatVarRef* = ref MFloatVar
proc val*(self: MFloatVar|ref MFloatVar):float =
  result = self.floatVal
proc newVar*(val:float,name = ""):ref MfloatVar=
  new result
  result.name = name
  result.kind = "float"
  result.floatVal = val
proc Var*(val:float,name = ""):MFloatVar=
  result.name = name
  result.kind = "float"
  result.floatVal = val
proc `$`*(self:MFloatVar|ref MFloatVar):string=
  result = $self.floatVal
proc setVal*(self:var MFloatVar,val:float,runBeforeFuncs:bool = false,runAfterFuncs=false)=
  if  self.floatVal == val : return
  var accept  =true
  if runBeforeFuncs:
    accept = self.execBforeSetValFuncs(Var(val))
  if accept:
    self.floatVal = val
  if runAfterFuncs:
    self.execAfterSetValFuncs()
proc setVal*(self:var MFloatVar,val:string,runBeforeFuncs:bool = false,runAfterFuncs=false)=
  self.setVal(val.parseFloat(),runBeforeFuncs,runAfterFuncs)
proc setVal*(self:ref MFloatVar,val:string,runBeforeFuncs:bool = false,runAfterFuncs=false)=
  setVal(self[],val,runBeforeFuncs,runAfterFuncs)
proc setVal*(self:ref MFloatVar,val:float,runBeforeFuncs:bool = false,runAfterFuncs=false)=
  setVal(self[],val,runBeforeFuncs,runAfterFuncs)


proc `$`*(self:MVariant):string = 
  case self.kind:
    of "nil": return "nil"
    of "int": return $(self.MIntVar())
    of "int64":return $(self.MInt64Var())
    of "string":return $(self.MStrVar())
    of "float":return $(self.MFloatVar())
proc `$`*(self:ref MVariant):string = 
  $(self[])
     
proc setVal*(self:ref MVariant,val:ref MVariant)=
  assert(self.kind == val.kind)
  case self.kind:
    of "nil": assert(false)
    of "int":
      self.MIntVarRef().setVal(val.MIntVarRef().val())
    of "int64":
      self.MInt64VarRef().setVal(val.MInt64VarRef().val())
    of "string":
      self.MStrVarRef().setVal(val.MStrVarRef().val())
    of "float":
      self.MFloatVarRef().setVal(val.MFloatVarRef().val())
    else: assert(false)
 
#***********test**************8

when isMainModule:
  proc t (oldVar:MVariant,newVar:MVariant):bool = 
    echo oldVar.MIntVar()
    return true
  var v = newVar(5)
  v.addBeforSetValFunc(t)
  v.setVal(10,true,true)
  v.setVal("20")
  echo v
  v.setVal(newVar(10))
  echo "v.setVal(newVar(10)):",v
  echo "******* test MVariantlist ********"
  var l = @[newVar(1,"id"),newVar("nour","name")]
  dump(l["id"])
  dump(l["name"])
  dump(l["****"])
  
