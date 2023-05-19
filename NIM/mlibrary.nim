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

when isMainModule:
  let str = ",".join(@["ans","howa","hiya"])
  str.echo
