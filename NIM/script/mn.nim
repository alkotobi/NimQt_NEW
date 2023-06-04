# started
import strformat,terminal,std/json

type
  Field* = ref object
    name:string
    caption:string
    kind:string
    isAutoInc:bool
    isPrimaryKey:bool
    isUnic:bool
  Record* = seq[Field]
  Fields* = Record
  InputData* = object of RootObj
     tableName*:string
     fields:seq[Field]

proc setTableName*(self:var InputData)=
  echo "What is ur table name?"
  self.tableName = readline(stdin)
  styledEcho(fgGreen, &"your table Name is: {self.tablename}")

proc createField*(fld:Field)=
  echo "what is ur field Name?"
  styledEcho fgCyan,"q to exit"
  var fieldName = readLine(stdin)
  if fieldName == "q":
    styledEcho(fgGreen, "u choose to exit")
    return
  fld.name = fieldName
  styledEcho(fgGreen, &"ur field name is :{fld.name}")
  while true:
    echo &"what is the type of ur field?\n"
    styledEcho fgCyan,&"for int pres 1\n"
    styledEcho fgCyan,&"for string press 2\n"
    styledEcho fgCyan,&"for float press 3\n"
    var choice = readLine(stdin)
    var isChoiceCorrect = true
    case choice:
      of "1":
        fld.kind = "int"
      of "2":
        fld.kind = "string"
      of "3":
        fld.kind = "float"
      else:
        isChoiceCorrect = false
    if isChoiceCorrect : break
  styledEcho(fgGreen, &"{fld.name} type is: {fld.kind}")
  echo "is ur field auto inc?"
  styledEcho fgCyan,"press enter for yes any other key for no"
  if readLine(stdin) == "":
    fld.isAutoInc = true
  else:
    fld.isAutoInc = false
  styledEcho(fgGreen, &"{fld.name} auto inc is: {fld.isAutoInc}")
  echo &"is {fld.name} unic?"
  styledEcho fgCyan, "press enter for yes any other key for no"
  if readLine(stdin) == "":
    fld.isUnic = true
  else:
    fld.isUnic = false
  styledEcho(fgGreen, &"{fld.name} Unic is: {fld.isUnic}")
  echo &"is {fld.name} primary key?"
  styledEcho fgCyan, "press enter for yes any other key for no"
  if readLine(stdin) == "":
    fld.isPrimaryKey = true
  else:
    fld.isPrimaryKey = false
  echo &"what is the caption to use for {fld.name}?"
  styledEcho(fgCyan,"press enter to use the name as caption or enter the caption")
  let caption = readLine(stdin)
  if caption == "":
    fld.caption = fld.name
  else:
    fld.caption = caption

proc addFields*(self:var InputData)=
  var choice = ""
  var fieldName = ""
  while choice != "q":
    var fld = Field()
    echo "what is ur field Name?"
    styledEcho fgCyan,"q to exit"
    fieldName = readLine(stdin)
    if fieldName == "q":
      styledEcho(fgGreen, "u choose to exit")
      return
    fld.name = fieldName
    styledEcho(fgGreen, &"ur field name is :{fld.name}")
    while true:
      echo &"what is the type of ur field?\n"
      styledEcho fgCyan,&"for int pres 1\n"
      styledEcho fgCyan,&"for string press 2\n"
      styledEcho fgCyan,&"for float press 3\n"
      choice = readLine(stdin)
      var isChoiceCorrect = true
      case choice:
        of "1":
          fld.kind = "int"
        of "2":
          fld.kind = "string"
        of "3":
          fld.kind = "float"
        else:
          isChoiceCorrect = false
      if isChoiceCorrect : break
    styledEcho(fgGreen, &"{fld.name} type is: {fld.kind}")
    echo "is ur field auto inc?"
    styledEcho fgCyan,"press enter for yes any other key for no"
    if readLine(stdin) == "":
      fld.isAutoInc = true
    else:
      fld.isAutoInc = false
    styledEcho(fgGreen, &"{fld.name} auto inc is: {fld.isAutoInc}")
    echo &"is {fld.name} unic?"
    styledEcho fgCyan, "press enter for yes any other key for no"
    if readLine(stdin) == "":
      fld.isUnic = true
    else:
      fld.isUnic = false
    styledEcho(fgGreen, &"{fld.name} Unic is: {fld.isUnic}")
    echo &"is {fld.name} primary key?"
    styledEcho fgCyan, "press enter for yes any other key for no"
    if readLine(stdin) == "":
      fld.isPrimaryKey = true
    else:
      fld.isPrimaryKey = false
    echo &"what is the caption to use for {fld.name}?"
    styledEcho(fgCyan,"press enter to use the name as caption or enter the caption")
    let caption = readLine(stdin)
    if caption == "":
      fld.caption = fld.name
    else:
      fld.caption = caption
    styledEcho(fgBlue,&"filed name is:{fld.name}\nof type:{fld.kind}\nauto inc is:{fld.isAutoinc}\nunic is:{fld.isUnic}\nprimary key is:{fld.isPrimarykey}\n caption is:{fld.caption}")
    echo "is this info correct?"
    styledEcho(fgCyan,"press enter to agree; any key else to redo")
    if readLine(stdin) == "":
      self.fields.add(fld)
      styledEcho(fgYellow,&"{fld.name} is successfully added :)")

import os
proc toJsonFile(self:var InputData,file_name:string)=
  let str2 = pretty(%* self)
  var file:File
  if open(file, fileName, fmWrite):
    file.write(str2)
    file.close()

proc fromJsonFile(fileName:string) : InputData=
  var inFile:File
  if not open(inFile, fileName, fmRead):
    echo "Could not open file for recovering data"
    quit()
  let str2 = inFile.readAll()
  inFile.close
  result = to(parseJson(str2), InputData)
# echo paramCount(), " ", paramStr(1)
proc isPathCorrect*(path:string):bool=
  return dirExists(splitPath(path).head)

proc saveData*(data:InputData,fileName:string)=
  if not fileName.isPathCorrect():
    echo "incorrect path"
    raise
  let str2 = pretty(%* data)
  var file:File
  if open(file, fileName, fmWrite):
    file.write(str2)
    file.close()
  else:
    echo "can`t save data"
    raise 

proc compileParams()=
  if paramCount()==2:
    echo paramStr(1)
    echo paramStr(2)
    var fileName = paramStr(2)
    if paramStr(1) == "-n":
      if not dirExists(splitPath(fileName).head):
        echo fileName," is incorrect path"
        return
      if fileName.fileExists():
        echo fileName , " already exists do u want to override?"
        echo "press 'y' to override"
        echo "any key else to cancel"
        var choice = readline(stdin)
        if choice != "y":
          return
      var data:InputData
      data.setTableName()
      data.addFields()
      let str2 = pretty(%* data)
      var file:File
      if open(file, fileName, fmWrite):
        file.write(str2)
        file.close()
    if paramStr(1) == "-u":
      if not fileExists(fileName):
        echo fileName , " is not existing"
        return
      var data = fromjsonfile(fileName)
      echo "choose a commande:"
      echo "1: add fields"
      echo "2: delete a field"
      echo "3: change a field"
      echo "4: change table Name\n"
      var choice = readline(stdin)
      if choice == "1":
        data.addfields()
        data.toJsonFile(fileName)
      elif choice == "2":
        var str = ""
        for fld in data.fields:
          str = str & " " & fld.name
        echo "witch filed u want to remove"
        echo str
        choice = readline(stdin)
        var i = 0
        var done = ""
        for fld in data.fields:
          if fld.name == choice:
            data.fields.delete(i)
            echo choice , " is deleted"
            done = "done"
            data.tojsonfile(fileName)
            return
          i = i+1
        if done != "done":
          echo choice , " dont exists"
          return
      elif choice == "3":
        var str = ""
        for fld in data.fields:
          str = str & " " & fld.name
        echo "witch filed u want to change?:"
        echo str
        choice = readline(stdin)
        var done = ""
        for fld in data.fields:
          if fld.name == choice:
            fld.createField()
            echo choice , " is changed"
            done = "done"
            data.tojsonfile(fileName)
            return
        if done != "done":
          echo choice , " dont exists"
          return
      elif choice == "4":
        echo " what is the new table name?"
        var choice = readline(stdin)
        if choice != "":
          data.tableName = choice
          data.tojsonfile(fileName)
          return
      else :
        echo "wrong input"
        return

compileParams()
# var data:InputData
# data.setTableName()
# data.addFields()
# styledEcho(fgBlue,data.fields.repr)
# let str2 = pretty(%* data)
# echo str2
# var fileName = data.tableName & ".json"
# if paramCount()>0:
#   fileName= paramStr(1)
#  data.tableName=fileName.splitFile().name
# var file:File
# if open(file, fileName, fmWrite):
#   file.write(str2)
#   file.close()
