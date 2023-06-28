import MTable,MVariant
type
  MRecord* = ref object of RootObj
    fields* : seq[ref MVariant]
  MVarTable* = ref object of MTable[MRecord]

proc newMRecord*():MRecord =
  new result
proc add*(self:var MRecord,val:ref MVariant)=
  self.fields.add(val)
proc newMVarTable*(data:seq[MRecord]):MVarTable=
  new result
  initMTable(MTable[MRecord](result),data)
proc getData*(self:MVarTable,row,column:int):ref MVariant=
  result =  self.data[row].fields[column] 
proc setData*(self:MVarTable,row,column:int,val:ref MVariant)=
  ## just change the value inside the MVariant
  var v = self.data[row].fields[column]
  v.setVal(val)
when isMainModule:
  var data :seq[MRecord]
  var rec = newMRecord()
  
  rec.add(newVar(5))
  data.add(rec)
  echo data.repr
  var tbl= newMVarTable(data)
  tbl.first()
  var cur = tbl.data[0]
  echo cur.repr
