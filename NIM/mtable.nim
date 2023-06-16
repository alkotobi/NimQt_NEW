type
  MTable*[T] = ref object of RootObj
    data*:seq[T]
    index*:int64

proc initMTable*[T](self:MTable,data:seq[T])=
  self.data =data
  if data.len>0:
    self.index = 0
  else:
    self.index = -1

proc newMTable*[T](data:seq[T]):MTable[T]=
  new result
  result.data =data
  initMTable(result,data)

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
