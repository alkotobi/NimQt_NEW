import MTable,MVariant
type
  MRecord* = object of RootObj
    fields* : seq[ref MVariant]
  MVarTable* = object of MTable[MRecord]

proc newMVarTable(data:seq[MRecord]):MVarTable=
  new result
  initMTable(result.MTable(),data)
proc getData*(self:MVarTable,row,column:int):ref MVariant=
  result =  self.data[row].fields[column] 
proc setData*(self:MVarTable,row,column:int,val:ref MVariant)=
  ## just change the value inside the MVariant
  var v = self.data[row].fields[column]
  v.setVal(val)
