import  streams, parsexml, strformat,strutils,os,mlibrary
# var filename = "test.ui"
var filename = "/Users/merhab/dev/python/mnstock/ui/users/form/ui_user_form.ui"
#not

proc go_to_next_node(x:var XmlParser)=
  while not(x.kind == xmlElementOpen or x.kind == xmlElementStart) and x.kind != xmlEof:
    x.next()

proc is_end_of_node(x:var XmlParser,node_name:string):bool=
  if ((x.kind == xmlElementEnd or x.kind == xmlElementClose)) and 
  x.elementName == node_name:
    return true
  else:return false



proc compile_property(x:var XmlParser,parent_element:string):string=
    var element_name=""
    var them_name=""
    var resource_path=""
    var resource_name=""
    while x.kind != xmlElementOpen and x.kind != xmlElementStart:
        x.next()
        # x.kind.echo
        # x.elementName.echo
    # x.elementName.echo
    if x.elementName == "rect" :
      var elems = newSeq[string]()
      while len(elems)<4:
        x.next()
        if x.kind == xmlCharData:
          elems.add(x.elementName)
          # x.elementName.echo
      var s1 = &"{elems[0]},{elems[1]},{elems[2]},{elems[3]}"
      s1.echo     
      return s1
    if x.elementName == "string":
      x.next()
      if x.kind == xmlCharData:
        var s1 = &"\"{x.element_name}\""
        s1.echo
        return s1
    if x.elementName == "number" or x.elementName == "enum" or x.elementName == "bool":
      x.next()
      if x.kind == xmlCharData:
        # x.elementName.echo
        return x.elementName
    if x.elementName == "size":
      var elems = newSeq[string]()
      while len(elems)<2:
        x.next()
        if x.kind == xmlCharData:
          elems.add(x.elementName)
          # x.elementName.echo
      var s1 = &"{elems[0]},{elems[1]}"
      s1.echo
      return s1
    if x.elementName == "iconset":
      x.next()
      if x.kind == xmlAttribute:
        if x.attrKey == "theme":
          them_name = x.attrValue
          x.next
        if x.attrKey == "resource":
          resource_path = x.attrValue
      while x.kind != xmlCharData:
        x.next
      resource_name = x.elementName
      var path = resource_path.splitPath().head
      var file = resource_name.splitPath().tail
      path = path & DirSep & file
      var s1 = &"\"{path}\""
      s1.echo
      return s1
      


proc compile_property(x:var XmlParser,elementName:string,property_name:string):string=
  var s1 = ""
  x.go_to_next_node
  var my_elem_name = x.elementName
  if x.elementName == "rect" or x.elementName == "size":
    var elems = newSeq[string]()
    while not x.is_end_of_node("rect") and not x.is_end_of_node("size"):
      x.next()
      if x.kind == xmlCharData:
        elems.add(x.elementName)
        # x.elementName.echo
    s1 = ",".join(elems) 
    s1 = &"M{my_elem_name.capitalizeAscii}({s1})"
    s1.echo 
  elif x.elementName == "string":
    x.next()
    if x.kind == xmlCharData:
      s1 = &"\"{x.element_name}\""
      # s1.echo
  elif x.elementName == "number" or x.elementName == "enum" or x.elementName == "bool":
    x.next()
    if x.kind == xmlCharData:
      # x.elementName.echo
      if x.elementName().contains("::"):
        var words = x.elementName().split("::")
        words[0][0]= 'M'
        s1="M" & property_name.capitalizeAscii & "Flags." & words[1]
      else:
       s1= x.elementName
  elif x.elementName == "iconset":
    var them_name =""
    var resource_path = ""
    var resource_name = ""
    x.next()
    if x.kind == xmlAttribute:
      if x.attrKey == "theme":
        them_name = x.attrValue
        x.next()
      if x.attrKey == "resource":
        resource_path = x.attrValue
    while x.kind != xmlCharData and x.kind != xmlEof and not x.is_end_of_node("iconset"):
      x.next()
    if x.kind == xmlCharData: 
      resource_name = x.elementName
      var path = resource_path.splitPath().head
      var file = resource_name.splitPath().tail
      path = path & DirSep & file
      s1 = &"MIcon(\"{path}\")"
      # s1.echo
    else: return ""

  s1 = &"{elementName}.set{property_name.capitalizeAscii}({s1})\n"
  echo s1
  return s1

proc echo*(x:var XmlParser)=
    echo "kind:",x.kind," name:",x.elementName
    if x.kind == xmlAttribute:
      echo "key:",x.attrKey,"/val:",x.attrValue
    echo "*************************"

proc isNodeOf(x:var XmlParser,node_name:string):bool=
   result= x.elementName == node_name and(x.kind == xmlElementOpen or x.kind == xmlElementStart)

proc isAttributeOf(x:var XmlParser,attribute_name:string):bool=
   result= x.kind == xmlAttribute and x.elementName == attribute_name



let gui_start_names = @["widget","layout","action","spacer"]
proc isGuiElementStart(x:var XmlParser):bool=
   result= (x.kind == xmlElementStart or x.kind == xmlElementOpen) and
   (x.elementName in gui_start_names)
   

proc isGuiElementEnd(x:var XmlParser):bool=
   result= (x.kind == xmlElementEnd or x.kind == xmlElementClose) and
   (x.elementName in gui_start_names)

 
proc newStructOfQlayoutElements(file_name:string):string=
  var str = ""
  var x: XmlParser
  var ident="  "
  var s = newFileStream(filename, fmRead)
  open(x, s, filename)
  var class = ""
  var parent_name = ""
  
  while x.kind != xmlEof and x.elementName != "widget":
    x.next()
  x.next()
  class = x.attrValue
  class[0]='M'
  # class.echo
  x.next()

  parent_name = x.attrValue
  parent_name[0]=parent_name[0].toLowerAscii()
  str = &"type {parent_name.capitalizeascii}* = ref object of {class}\n"
  while x.kind != xmlEof:
    # x.echo
    if x.isAttributeOf "class":
      if x.kind == xmlAttribute:
        var class_name = x.attrValue
        class_name[0]='M'
        # echo "class_name:",class_name
        x.next()
        # x.echo
        if x.elementName == "name":
          if x.kind == xmlAttribute:
            var obj_name = x.attrValue
            # echo "obj_name:",obj_name
            str = &"{str}{ident}{obj_name}: {class_name}\n"
            # str.echo
    elif x.isNodeOf("action") or 
    x.isNodeOf("spacer"):


      var class_name =""
      if x.elementName == "action":
        class_name = &"M{x.element_name.capitalizeAscii}"
      else:
        class_name = &"M{x.element_name.capitalizeAscii}Item"
      
      # class_name.echo
      # x.echo
      x.next()
      # x.echo
      if x.kind == xmlAttribute:
        var obj_name = x.attrValue
        str = &"{str}{ident}{obj_name}: {class_name}\n"
        # echo "\n************************\n",str,"\n************************\n"
    x.next()
  str = &"import gui\n{str}"  
  return str;

proc widget_get_next_attribute(x:var XmlParser):tuple[key:string,val:string]=
  x.next()
  while x.kind != xmlAttribute and x.kind != xmlEof:
    x.next()
  if x.kind == xmlAttribute:
    # x.echo
    result.key = x.attrKey
    result.val = x.attrValue
    # x.echo


proc widget_get_name_and_class(x:var XmlParser):tuple[name:string,class:string]=
  if x.elementName == "widget" or x.elementName == "layout":
    var atr = x.widget_get_next_attribute
    result.class = atr.val
    result.class[0]='M'
    atr = x.widget_get_next_attribute
    result.name = atr.val
  if x.elementName == "spacer":
    var atr=x.widget_get_next_attribute
    result.name = atr.val
    result.class = "MSpacerItem"
    
  if x.elementName == "action":
    var atr=x.widget_get_next_attribute
    result.name = atr.val
    result.class = "MAction"
    
    
    

    


proc init_widgets(x:var XmlParser,parent_name:string):string=
  var str=""
  var parent =""
  while x.kind != xmlEof:
    if x.isGuiElementStart:
      if x.elementName == "layout":parent = ""
      else: parent = parent_name
      var res = x.widget_get_name_and_class
      str = &"{str}  {res.name}=new{res.class}({parent})\n"
      

    x.next()  
  return str
let classes_without_parent =["MVBoxLayer","MHBoxLayer","MGridLayout","MSpacerItem"]
proc init_widgets_properties(filename:string,parent_name:string):string=
  var s = newFileStream(filename, fmRead)
  var x:XmlParser
  open(x, s, filename)
  var str = ""
  var str_spacer = ""
  var isSpacer = false
  while x.kind != xmlEof:
    if x.isGuiElementStart:
      var res = x.widget_get_name_and_class
      res.name[0]=res.name[0].toLowerAscii()
      if parent_name != res.name:
        var par = ""
        if res.class notin classes_without_parent:
          par = parent_name
        if res.class == "MSpacerItem":
          isSpacer = true
        else:
          isSpacer = false
        if not isSpacer:  
          str = &"{str}  {parent_name}.{res.name}=new{res.class}({par})\n"
      while not x.isGuiElementEnd and not x.isGuiElementStart :
        if x.elementName == "property" and (x.kind == xmlElementOpen or x.kind == xmlElementStart):
          x.next()
          if x.kind == xmlAttribute:
            var property_name = x.attrValue
            var s1 = ""
            if isSpacer:
              s1 = x.compile_property(property_name)
              if str_spacer != "":
                str_spacer = &"{s1},{str_spacer}"
                str= &"{str}  {parent_name}.{res.name} = newMSpacerItem({str_spacer})\n"
                str_spacer = ""
              else:
                str_spacer = s1
                str_spacer = str_spacer.replace("Qt::","MSpacerItemFlags.")
            else:
              s1 = x.compile_property(res.name,property_name)
              if res.name == parent_name:
                str = &"{str}  {s1}"
              else: 
                 str = &"{str}  {parent_name}.{s1}"
        x.next()
    x.next()
  return str


type
  TNode* =  ref object #of RootObj
    class:string
    name:string
    row:string
    col:string
    parent_node :   TNode
    parent_widget:  TNode

proc echo(nd:TNode)=
  echo "------------------------------------------"
  echo "class:",nd.class
  echo "name:",nd.name
  echo "row:",nd.row
  echo "col:",nd.col
  if not nd.parent_node.isNil:
    echo "parent_node:",nd.parent_node.name
  if not nd.parent_widget.isNil:  
    echo "parent_widget:",nd.parent_widget.name


proc widget_tree(x:var XmlParser,paren_widget:TNode): seq[TNode] =
  var s = newMStack[TNode]()
  var row= ""
  var col = ""
  while x.kind != xmlEof:
    if x.elementName == "item":
      if x.kind == xmlElementOpen:#has attributes
        x.next()
        row = x.attrValue
        x.next()
        col = x.attrValue
        x.next()
      # elif x.kind == xmlElementStart:
      #   x.next()

    if x.isGuiElementStart :
      var ret=x.widget_get_name_and_class
      var nd = new TNode
      nd.class = ret.class
      nd.name = ret.name
      nd.row = row
      nd.col = col
      row =""
      col =""
      nd.parent_widget = paren_widget
      s.push(nd)
      echo nd
    if x.isGuiElementEnd:
      if s.isEmpty: 
        x.next()
        continue
      var nd = s.pop()
      if not s.isEmpty:
        nd.parent_node = s.getCurrent
      else:
        nd.parent_node = paren_widget
      result.add(nd)
      echo nd
    x.next()



let layouts = @["QVBoxLayout","QGridLayout","QHBoxLayout"]
proc widget_lay_out*(list:var seq[TNode]):string=
  var str =""
  for nod in list:
    if nod.parent_node.class in layouts:
      if nod.row!="":
        str = &"{str}  {nod.parent_node.name}.addItem({nod.name},{nod.row},{nod.col},1,1)\n"
      else: str = &"{str}  {nod.parent_node.name}.addItem({nod.name})\n"
    else:
      if nod.class in layouts:
        str = &"{str}  {nod.parent_node.name}.setLayout({nod.name})\n"
  return str
 





    

    


          


    
      

        

proc compile_element*(x:var XmlParser,parent_node:var string,parent_widget:string): tuple[instruction:string,element_name:string] =
    var str = ""
    var elementName =""
    # while x.kind != xmlElementOpen and x.kind != xmlElementStart and x.kind != xmlEof:
    #     x.next()
    #     x.kind.echo
    #     x.elementName.echo

    while  not((x.kind == xmlElementClose and x.elementName == parent_node) or
        (x.kind == xmlElementEnd and x.elementName == parent_node)) and x.kind != xmlEof:


        # x.kind.echo
        # x.elementName.echo


        if x.elementName == "property" and (x.kind == xmlElementOpen or x.kind == xmlElementStart):
          var property_name =""
          x.next()
          if x.kind == xmlAttribute:
            if x.attrKey == "name":
              property_name = x.attrValue
              elementName = property_name
              # property_name.echo
              var s1 = compile_property(x,property_name)
              echo s1
              str = &"{str} {parent_node}.set{property_name.capitalizeAscii}({s1})\n"
              str.echo
              x.next()
              continue

        if x.elementName == "layout" and (x.kind == xmlElementOpen or x.kind == xmlElementStart):
          var class_name =""
          var layout_name = "" 
          # -----------
          x.next()
          if x.kind == xmlAttribute:
            if x.attrKey == "class":
              class_name = x.attrValue
              # class_name.echo
          x.next()
          if x.kind == xmlAttribute:
            if x.attrKey == "name":
              layout_name = x.attrValue
              # layout_name.echo
          str = &"var {layout_name} : {class_name} = new{class_name}({parent_node})\n"
          str.echo
          x.next()
          var s1 =compile_element(x,layout_name,parent_widget)
          s1.instruction.echo
          s1.element_name.echo
          str = str & s1.instruction 
          str.echo
          x.next()
          continue


        if (x.elementName == "widget")and
        (x.kind == xmlElementOpen or x.kind == xmlElementStart):
          var class_name=""
          var widget_name = ""
          x.next()
          if x.kind == xmlAttribute:
            if x.attrKey == "class":
              class_name = x.attrValue
              # class_name.echo
          x.next()
          if x.kind == xmlAttribute:
            if x.attrKey == "name":
              widget_name = x.attrValue
              elementName = widget_name
              # widget_name.echo
          str = &"{str}  var {widget_name} : {class_name} = new{class_name}({parent_widget})\n"
          str.echo
          var s1 =compile_element(x,widget_name,parent_widget)
          s1.instruction.echo
          s1.element_name.echo
          str = str & s1.instruction 
          str.echo
          x.next()
          continue


        if x.elementName == "action" and (x.kind == xmlElementOpen or x.kind == xmlElementStart):
          var instruction_str="" 
          var action_name ="" 
          x.next()
          if x.kind == xmlAttribute:
            if x.attrKey == "name":
                action_name = x.attrValue
                if action_name == "ac_cancel":
                  echo " anan"
                elementName = action_name
                # action_name.echo
            if action_name != "":
              instruction_str = &"{instruction_str}{action_name} = newQAction({parent_widget})\n"
              var s1 =compile_element(x,action_name,parent_widget)
              s1.instruction.echo
              s1.element_name.echo
              str = str & instruction_str & s1.instruction
              str.echo
              x.next()
              continue
        
        if x.elementName == "item" and (x.kind == xmlElementOpen or x.kind == xmlElementStart):
          x.next()
          var row = ""
          var col = "" 
          if x.kind == xmlAttribute:
            if x.attrKey == "row":
              row = x.attrValue   
              x.next()
              if x.kind == xmlAttribute:
                if x.attrKey == "column":
                  col = x.attrValue
                  # col.echo
                  var(xpr,elm_name)=compile_element(x,parent_node,parent_widget)
                  # xpr.echo
                  # elm_name.echo
                  str = str & xpr
                  # str.echo
                  str = &"{str}{parent_node}.addItem({elm_name},{row},{col},1,1)\n"
                  # str.echo
                  x.next()
                  continue
          var(ex,elm_name)=compile_element(x,parent_node,parent_widget)
          ex.echo
          elm_name.echo
          str = str & ex
          str.echo
          str = &"{str}{parent_node}.addItem({elm_name})\n"
          str.echo
          x.next()
          continue

        if x.elementName == "spacer" and (x.kind == xmlElementOpen or x.kind == xmlElementStart):
          var oriorientation =""
          var spacer_name=""
          var w =""
          var h = ""
          x.next()
          if x.kind == xmlAttribute:
            if x.attrKey == "name":
                spacer_name = x.attrValue
                elementName = spacer_name
                spacer_name.echo
          x.next() #property
          x.next() #property name
          x.next() #enum
          x.next()
          if x.kind == xmlCharData:
            oriorientation = x.elementName
            oriorientation.echo
          x.next() #enum close
          x.next() #property close
          x.next() #property open  
          x.next() #attribute name 
          x.next() #attribute stdset
          x.next() #size open
          x.next() #width open
          x.next()
          if x.kind == xmlCharData:
            w = x.elementName 
            w.echo
          x.next() #width close
          x.next() #hight open
          x.next()
          if x.kind == xmlCharData:
            h = x.elementName
            h.echo
          if oriorientation == "Qt::Horizontal":oriorientation = "Horizontal"
          if oriorientation == "Qt::Vertical":oriorientation = "Vertical"
          str = &"{str} var {spacer_name}= newQSpacerItem({w},{h},{oriorientation})\n"
          str.echo
          x.next()
          continue
          # return (str,element_name)
        x.next()    
            
    return (str,element_name)
    
proc compile_layout*(x:var XmlParser,layout_name:string,parent_node:string,parent_widget :string):tuple[instruction:string,element_name:string]=
  var str= ""
  var class_name =""
  var layout_name = ""
  # -----------
  x.next()
  if x.kind == xmlAttribute:
    if x.attrKey == "class":
      class_name = x.attrValue
      class_name.echo
  x.next()
  if x.kind == xmlAttribute:
    if x.attrKey == "name":
      layout_name = x.attrValue
      layout_name.echo
  str = &"var {layout_name} : {class_name} = new{class_name}({parent_node})\n"
  str.echo
  var s1 =compile_element(x,layout_name,parent_widget)
  s1.instruction.echo
  s1.element_name.echo
  str = str & s1.instruction 
  str.echo
  # -----------
  while not((x.kind == xmlElementClose and x.elementName == layout_name) or
  (x.kind == xmlElementEnd and x.elementName == layout_name)) and x.kind != xmlEof:
    x.next()
    var row = ""
    var col = "" 
    if x.kind == xmlAttribute:
      if x.attrKey == "row":
        row = x.attrValue   
        x.next()
        if x.kind == xmlAttribute:
          if x.attrKey == "column":
            col = x.attrValue
            col.echo
            var(xpr,elm_name)=compile_element(x,layout_name,parent_widget)
            xpr.echo
            elm_name.echo
            str = str & xpr
            str.echo
            str = &"{str}{layout_name}.addItem({elm_name},{row},{col},1,1)\n"
            str.echo
            continue
    var(ex,elm_name)=compile_element(x,layout_name,parent_widget)
    ex.echo
    elm_name.echo
    str = str & ex
    str.echo
    str = &"{str}{layout_name}.addItem({elm_name})\n"
    str.echo 
    x.next()           
  return (str,layout_name)


proc compile_xml*(file_name:string):string =
  var x: XmlParser
  var s = newFileStream(filename, fmRead)
  open(x, s, filename)
  var str = ""
  var class = ""
  var parent_name = ""
  
  while x.kind != xmlEof and x.elementName != "widget":
    x.next()
  x.next()
  class = x.attrValue
  class.echo
  x.next
  parent_name = x.attrValue
  parent_name.echo
  while x.kind != xmlEof:  
    var(str1,_)=compile_element(x,parent_name,parent_name)
    str1.echo
    str = str & str1
    str.echo
  x.close
  return str


proc compile_xml_2*(filename:string):string=
  var x: XmlParser
  var s = newFileStream(filename, fmRead)
  open(x, s, filename)
  while  x.kind != xmlEof:
    x.kind.echo
    x.elementName.echo
    x.next
  return ""


    

when isMainModule:   
  var x: XmlParser
  var s = newFileStream(filename, fmRead)
  open(x, s, filename)
  var class = ""
  var parent_name = ""
  
  while x.kind != xmlEof and x.elementName != "widget":
    x.next()
  x.next()
  class = x.attrValue
  class[0]='M'
  # class.echo
  x.next()
  parent_name = x.attrValue
  parent_name[0] = parent_name[0].toLowerAscii()
  # parent_name.echo
  var nd = new TNode
  nd.name = parent_name
  nd.parent_node =nil
  nd.class = class
  nd.parent_widget = nil
  # nd.echo
  var str=newStructOfQlayoutElements(filename)
  str = &"{str}proc setupUI({parent_name}:{parent_name.capitalizeascii})=\n"
  str =str & init_widgets_properties(filename,parent_name)
  var wid_tree = widget_tree(x,nd)
  echo "tree done"
  str =str & widget_lay_out(wid_tree) #
  writeFile("str.nim",str)  
  echo str
  str =  init_widgets(x,parent_name)
  echo "________________________________________"
  str.echo
  
