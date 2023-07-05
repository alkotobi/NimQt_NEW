import strUtils

const
  String* = "string"
  Int* = "int"
  Int64* = "int64"
  Float* = "float"
  Nil* = "nil"
type
  MFNBeforSetVal* = proc(oldVar:MVariant,newVar:MVariant):bool
  MFNAfterSetVal* = proc(self:MVariant)
  MVariantMeta* = ref object of RootObj
    kind*:string
    name*:string
    beforeSetValFuncs* :seq[MFNBeforSetVal]
    afterSetValFuncs* : seq[MFNAfterSetVal]

  MVariant* = object of RootObj
    meta*:MVariantMeta
proc `$`*(self:MFNBeforSetVal):string=
  result = "funcBeforeSetVal"

proc `$`*(self:MFNAfterSetVal):string=
  result = "funcAfterSetVal"

proc `$`*(self:MVariantMeta):string=
  result = self.name & ":" & self.kind & "\n"
proc init*(self:MVariantMeta,name="",kind=Nil)=
  self.kind = kind
  self.name = name
proc newMVariantMeta*(name="",kind=Nil):MVariantMeta=
  new result
  result.init(name,kind)
proc kind*(self:MVariant|ref MVariant):string=
  return self.meta.kind

proc init*(self:var MVariant,name="",meta=newMVariantMeta())=
  self.meta = meta
  if name != "":self.meta.name = name

proc name*(self:MVariant|ref MVariant):string=
  return self.meta.name


proc execBforeSetValFuncs(self:MVariant|ref MVariant,newVal:MVariant):bool=
  for fn in self.meta.beforeSetValFuncs:
    if not fn(self,newVal):
      return false
  return true
proc execAfterSetValFuncs(self:MVariant|ref MVariant)=
  for fn in self.meta.afterSetValFuncs:
    fn(self)
proc addBeforSetValFunc*(self:var MVariant,beforeFunc:MFNBeforSetVal)=
  if beforeFunc notin self.meta.beforeSetValfuncs:
    self.meta.beforeSetValFuncs.add(beforeFunc)
proc addBeforSetValFunc*(self:ref MVariant,beforeFunc:MFNBeforSetVal)=
  addBeforSetValFunc(self[],beforeFunc)
proc addAfterSetValFunc*(self:var MVariant,afterFunc:MFNAfterSetVal)=
  if afterFunc notin self.meta.afterSetValfuncs:
    self.meta.afterSetValFuncs.add(afterFunc)
proc addAfterSetValFunc*(self:ref MVariant,afterFunc:MFNAfterSetVal)=
  addAfterSetValFunc(self[],afterFunc)

type
  MNilVar* = object of MVariant
  MNilVarRef* = ref MNilVar
let nilMeta = newMVariantMeta("",Nil)

proc newVar*():ref MNilVar=
  new result
  result.meta = nilMeta
proc Var*():MNilVar=
  result.meta = nilMeta
proc isNil*(self:MVariant|ref MVariant):bool =
  return self.meta.kind ==  Nil

type MVariantRefList* = seq[ref MVariant]
proc `[]`*(varList:MVariantRefList,name:string):ref MVariant=
  for v in varList:
    if v.meta.name == name :
      return v
  return newVar()

proc getNames*(fields:MVariantRefList):string=
  assert(fields.len()!=0)
  result = fields[0].name()
  for i in 1..fields.len()-1:
    result = result & "," & fields[i].name()

type
  MIntVar* = object of MVariant
    intVal :int
  MIntVarRef* = ref MIntVar
proc val*(self: MIntVar|ref MIntVar):int =
  result = self.intVal
proc init*(self:var MIntVar,val:int,name="",meta = newMVariantMeta(kind=Int))=
  self.MVariant().init(name,meta)
  self.intVal = val
proc newVar*(val:int,name="",meta = newMVariantMeta(kind=Int)):ref MIntVar=
  new result
  init(result[],val,name,meta)

proc Var*(val:int,name="",meta = newMVariantMeta(kind=Int)):MIntVar=
  result.init(val,name,meta)

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
  MInt64VarRef* = ref MInt64Var
proc val*(self: MInt64Var|ref MInt64Var):int64 =
  result = self.int64Val
proc init*(self:var MInt64Var,val:int64,name="",meta = newMVariantMeta(kind=Int64))=
  self.MVariant().init(name,meta) 
  self.int64Val = val

proc newVar*(val:int64,name="",meta = newMVariantMeta(kind=Int64)):ref MInt64Var=
  new result
  result[].init(val,name,meta)
proc Var*(val:int64,name="",meta = newMVariantMeta(kind=Int64)):MInt64Var=
  result.init(val,name,meta)
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
proc setVal*(self: MInt64VarRef,val:string,runBeforeFuncs:bool = false,runAfterFuncs=false)=
  setVal(self[],val,runBeforeFuncs,runAfterFuncs)
proc setVal*(self: MInt64VarRef,val:int64,runBeforeFuncs:bool = false,runAfterFuncs=false)=
  setVal(self[],val,runBeforeFuncs,runAfterFuncs)

type
  MStrVar* = object of MVariant
    strVal:string
  MStrVarRef* = ref MStrVar
proc val*(self: MStrVar|ref MStrVar):string =
  result = self.strVal
proc init*(self:var MStrVar,val:string,name="",meta = newMVariantMeta(kind=String))=
  self.MVariant().init(name,meta)
  self.strVal = val

proc newVar*(val:string,name="",meta = newMVariantMeta(kind=String)):ref MStrVar=
  new result
  result[].init(val,name,meta)
proc Var*(val:string,name="",meta = newMVariantMeta(kind=Int64)):MStrVar=
  result.init(val,name,meta)

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
proc init*(self:var MFloatVar,val:float,name="",meta = newMVariantMeta(kind=Float))=
  self.MVariant().init(name,meta)
  self.floatVal = val

proc newVar*(val:float,name="",meta = newMVariantMeta(kind=Float)):ref MfloatVar=
  new result
  result[].init(val,name,meta)

proc Var*(val:float,name="",meta = newMVariantMeta(kind=Int64)):MFloatVar=
  result.init(val,name,meta)

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
  case self.meta.kind:
    of "nil": return "nil"
    of "int": return $(self.MIntVar())
    of "int64":return $(self.MInt64Var())
    of "string":return $(self.MStrVar())
    of "float":return $(self.MFloatVar())
proc `$`*(self:ref MVariant):string = 
  $(self[])
     
proc setVal*(self:ref MVariant,val:ref MVariant)=
  assert(self.meta.kind == val.meta.kind)
  case self.meta.kind:
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

#***********general api*******
proc toInt*(self:MVariant|ref MVariant):int=
  assert(self.kind == Int)
  when self is MVariant:
    return self.MIntVar().val
  else:
    return self.MIntVarRef().val
proc toInt64*(self:MVariant|ref MVariant):int64=
  assert(self.kind == Int64)
  when self is MVariant:
    return self.MInt64Var().val
  else:
    return self.MInt64VarRef().val
proc toStr*(self:MVariant|ref MVariant):string=
  assert(self.kind == String)
  when self is MVariant:
    return self.MStrVar().val
  else:
    return self.MStrVarRef().val
proc toFloat*(self:MVariant|ref MVariant):float=
  assert(self.kind == Float)
  when self is MVariant:
    return self.MFloatVar().val
  else:
    return self.MFloatVarRef().val
#***********test**************

when isMainModule:
  import sugar
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
  var l = @[newVar(1,meta=newMVariantMeta("id",Int)),newVar("nour")]
  dump(l["id"])
  dump(l["name"])
  dump(l["****"])
  dump(l["id"].meta)
  
