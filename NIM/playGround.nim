# import std/strutils
# from std/macros import expandMacros

# type Foo = object
  # ival: int
  # fval: float

# proc setField[T: int](val: var T, str: string) =
  # val = parseInt(str)

# proc setField[T: float](val: var T, str: string) =
  # val = parseFloat(str)

# template implSetObjectField(obj: object, field, val: string): untyped =
  # block fieldFound:
    # for objField, objVal in fieldPairs(obj):
      # if objField == field:
        # setField(objVal, val)
        # break fieldFound
    # raise newException(ValueError, "unexpected field: " & field)

# proc setObjectField[T: object](obj: var T, field, val: string) =
  # inside a generic proc to avoid side-effects and reduce code size.
  # expandMacros: # to see what it generates
    # implSetObjectField(obj, field, val)

# var a = Foo(ival: 1, fval: 2.0)
# setObjectField(a, "ival", "38")
# setObjectField(a, "fval", "4e8")
# echo a


# for name,val in a.fieldPairs:
    # when name == "ival":
        # val = 5
    # when name == "fval":
        # val = 4.5

# echo a

# import std/tables
# let
  # t = [('z', 1), ('y', 2), ('x', 3)].toTable



#----------------



# import os

# echo paramCount(), " ", paramStr(1)


#-------------------------

# import std/tables
# type
#   Tbl* = Table[string,string]
#   Tbls* = seq[Tbl]

# # var input = readLine(stdin)

# # var user: Tbl

# # user["me"] = input
# var a = {"me":"lolo","she":"toto"}.toTable
# echo a["me"]
# var s = "gui"
# import macros

# const ss ="g"
# const module  : string = ss & "ui"
# macro importconst(name: static[string]): untyped =
#   #let value = name.symbol.getImpl
#   #echo "variable name: ", name.repr
#   #echo "default value: ", $value
#   result = newNimNode(nnkImportStmt).add(newIdentNode(name))

# importconst(module)
# var app = newMApplication()
# var btn = newMPushButton(nil)
# btn.show()
# echo app.exec()

#*********************
#testing pointers
#*********************type

# type Obj = object
#   name : string
#   age  :int
# var s : seq[ref Obj]
# var o1 = new Obj ; o1[]= Obj(name:"str",age:12)
# s.add(o1)
# s[0].age =15
# echo s[0][]
# echo o1[]
# proc dd(obj:var Obj)=
#   obj.age = 90
#   echo obj.name,",",obj.age
# proc dd(obj:ref Obj)=
#   dd(obj[])
# var o2 : Obj
# o2.name = "nono"
# o2.age = 45
# echo "--------"
# o2.dd()
# echo "-------"
# o2.repr.echo

# proc ec(obj:Obj|ref Obj):string=
#   return obj.name
# echo o1.ec()
# echo o2.ec()

var a = 3 # two rightmost bits, at position 0 and 1 are set
var b = a and 2 # extract bit 1, so b gets the value 2
echo b
b = a and 4 # extract bit 3, which is unset, so result is 0
echo b
b = a or (4 + 8)
echo b
