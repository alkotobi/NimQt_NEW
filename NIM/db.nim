import mlibrary , strformat

type Db* = object of RootObj
  id:int

proc getFieldsNames*(self :Db):seq[string]=
  for name , val in self.fieldPairs:
    result.add name

proc getFieldsCount*(self:auto):int=
  for name , val in self.fieldPairs:
    result+=1
#------------------------------
#MSqlFilter
#------------------------------
type
  MLogicOp* = enum
    And
    Or
    AndNot
    OrNot
    Not
  MCompOp* = enum
    Equal
    Great
    Less
    Like
    GreatEqual
    LessEqual
  MSqlFilter* = ref object of RootObj
    filterPrv: MSqlFilter
    logOp:MLogicOp
    fieldName:string
    compOp:MCompOp
    val:MVariant
proc newMSqlFilter*():MSqlFilter=
  new result
proc newMSqlFilter(logicOP:MLogicOp,fieldName:string,compOp:MCompOp,val:MVariant,filterPrv:MSqlFilter=nil):MSqlFilter=
  new result
  result.compOp = compOP
  result.fieldName = fieldName
  if not filterPrv.isNil():
    result.filterPrv = filterPrv
  result.logOp = logicOP
  result.val = val
proc getLogicOp(logicOp:MLogicOp):string=
  case logicOp:
    of And: return " AND "
    of Or : return " OR "
    of Not: return " NOT "
    of AndNot: return " AND NOT "
    of OrNot: return " OR NOT "
    else: assert false

proc getCompOp(compOP:MCompOp):string=
  case compOp:
    of Equal: return " = "
    of Great: return " > "
    of Less: return " < "
    of Like: return " LIKE "
    of GreatEqual : return " >= "
    of LessEqual: return " <= "
    else: assert false

proc getPrmWhere*(self:MSqlFilter):string=
  var str=""
  if not self.filterPrv.isNil():
    str = str & getPrmWhere(self.filterPrv)
    str = str & getLogicOp(self.logOp)
  str = str & self.fieldName & getCompOp(self.compOp) & ":" & self.fieldName & " "
  return str

    
    

#------------------------------
#MSqlFilter End
#------------------------------
echo "done"

proc dispayVarargs(va: varargs[string,`$`]) =
    echo va.len

var se: seq[int] = @[2, 3, 4]

dispayVarargs(se)
