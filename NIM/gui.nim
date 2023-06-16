const wid_lib* = "/Users/merhab/dev/nim/NimQt/CPP/build/libGUI.dylib"

type
  VMFnPtrCharPtr* = proc (text:cstring,sender:pointer){.cdecl.}
type
    Direction* =enum
        LeftToRight=0
        RightToLeft=1
        TopToBottom=2
        BottomToTop=3

    LayoutDirection* = enum
      LayoutDirectionLeftToRight
      LayoutDirectionRightToLeft
      LayoutDirectionAuto
    MLayoutDirectionFlags* = LayoutDirection
    Alignment* = enum
      Default
      AlignLeft
      AlignRight
      AlignHCenter
      AlignJustify
      AlignTop
      AlignBottom
      AlignVCenter
      AlignBaseline
      AlignCenter
      AlignAbsolute
      AlignLeading
      AlignTrailing
      AlignHorizontal_Mask
      AlignVertical_Mask
type
  MRect* = object of RootObj
    # int x, int y, int width, int height
    x*:int
    y*:int
    width*:int
    height*:int

proc cstring_free(str:cstring): void {.importc: "cstring_free_v1", dynlib: wid_lib}

type MTObject* =pointer

proc mobject_del(self: MTObject): void  {.importc: "mobject_del", dynlib: wid_lib}
proc mobject_new(parent: MTObject): MTObject  {.importc: "mobject_new", dynlib: wid_lib}
proc mobject_set_parent(self: MTObject,parent:MTObject): void  {.importc: "mobject_set_parent", dynlib: wid_lib}
proc mobject_get_parent(self: MTObject): MTObject  {.importc: "mobject_get_parent", dynlib: wid_lib}
proc mobject_set_object_name(self: MTObject,name:cstring): void  {.importc: "mobject_set_object_name", dynlib: wid_lib}
type
  MObject* = ref object of RootObj
    obj: MTObject
    parent : MObject

proc newMObject*(obj:MTObject, parent:MObject):MObject=
    new result
    result.obj= obj
    result.parent = parent
    if not isNil(parent):
      result.obj= mobject_new(parent.obj)
    else:
        result.obj= mobject_new(nil)

proc newMObject*(parent:MObject):MObject=
    var obj = mobject_new(nil)
    result=newMObject(obj,parent) 

proc getObj*(self:MObject): MTObject =
    return self.obj

proc setObj*(self:MObject,obj:MTObject) =
    self.obj = obj


proc setParent*(self:MObject,parent:MObject) =
    if not isNil(parent):
      mobject_set_parent(self.obj,parent.obj)
    else:
      echo("else me")  
      mobject_set_parent(self.obj,nil)
    self.parent=parent

proc setParent*(self:MObject,parent:MTObject) =
    mobject_set_parent(self.obj,parent)
    self.parent = newMObject(parent,nil)

# todo: test getParent
proc getParent*(self:MObject): MObject =
    var parent = mobject_get_parent(self.getObj)
    if not parent.isNil:
       var obj= newMObject(parent,nil)
       obj.setParent(obj.getParent)
       return obj
    else: return nil

    result = self.parent

proc setObjectName*(self:MObject,name:string)=
    mobject_set_object_name(self.getObj,name.cstring)


proc free*(self: MObject) =
    mobject_del(self.obj)

#MLayoutItem
type
    MLayoutItem* = ref object of MObject

#MWidget
proc mwidget_new(parent: MTObject): MTObject  {.importc: "mwidget_new", dynlib: wid_lib}
proc mwidget_show(self: MTObject): void  {.importc: "mwidget_show", dynlib: wid_lib}
proc mwidget_set_layout(self: MTObject,layout:MTObject): void  {.importc: "mwidget_set_layout", dynlib: wid_lib}
proc mwidget_set_parent(self: MTObject,parent:MTObject): void  {.importc: "mwidget_set_parent", dynlib: wid_lib}

type
    MWidget* =ref object of MObject

proc newMWidget*(parent:MObject=nil):MWidget=
    var obj = mwidget_new(nil)
    new result
    result.setObj(obj)
    result.setParent(parent)

proc show*(self:MWidget)=
    mwidget_show(self.getObj)

proc setParent*(self:MWidget,parent:MWidget)=
    if parent.isNil:
       mwidget_set_parent(self.getObj,nil)
       return 
    mwidget_set_parent(self.getObj,parent.getObj)

proc setLayout*(self: MWidget , layout:MLayoutItem)=
    mwidget_set_layout(self.getObj,layout.getObj)

proc mwidget_set_geometry(self:MTObject,x:cint,y:cint,width:cint,height:cint) {.importc:"mwidget_set_geometry",dynlib:wid_lib}
proc setGeometry*(self:MWidget,rect:MRect)=
  mwidget_set_geometry(self.getObj,rect.x.cint,rect.y.cint,rect.width.cint,rect.height.cint)


proc mwidget_set_window_title(self:MTObject,title:cstring):void {.importc:"mwidget_set_window_title",dynlib:wid_lib}
proc setWindowTitle*(self:MWidget,title:string)=
  mwidget_set_window_title(self.getObj,title.cstring)

proc mwidget_set_layout_direction(self:MTObject,dir:cint):void {.importc:"mwidget_set_layout_direction",dynlib:wid_lib}
proc setLayoutDirection*(self:MWidget,dir:LayoutDirection)=
  mwidget_set_layout_direction(self.getObj(),dir.cint)

#MApplication

proc mapplication_new(): MTObject {.importc: "mapplication_new2", dynlib: wid_lib}
proc mapplication_exec(self:MTObject): cint {.importc: "mapplication_exec", dynlib: wid_lib}
proc mapplication_quit(self:MTObject): void {.importc: "mapplication_quit", dynlib: wid_lib}
type
    MApplication* = ref object of MObject

proc newMApplication*():MApplication=
    new result
    result.setObj(mapplication_new())

proc exec*(self:MApplication):int=
    result = mapplication_exec(self.getObj)

proc quit* (self:MApplication)=
    mapplication_quit(self.getObj)

#MAction
proc maction_new(parent: MTObject): MTObject  {.importc: "maction_new", dynlib: wid_lib}

type
    MAction* = ref object of MObject

proc newMAction*(parent :MObject = nil):MAction =
    new result
    result.setObj(maction_new(nil))   
    result.setParent(parent)
proc maction_set_icon(self:MTObject,icon_path:cstring) {.importc:"maction_set_icon",dynlib:wid_lib}
proc setIcon*(self:MAction,iconPath:string)=
  maction_set_icon(self.getObj,iconPath.cstring)
proc maction_set_text(self:MTObject,text:cstring) {.importc:"maction_set_text",dynlib:wid_lib}
proc setText*(self:MAction,text:string)=
  maction_set_text(self.getObj(),text.cstring)
proc maction_set_shortcut(self:MTObject,shortcut:cstring) {.importc:"maction_set_shortcut",dynlib:wid_lib}
proc setShortcut*(self:MAction,shortcut:string)=
  maction_set_shortcut(self.getObj(),shortcut.cstring)

#MAbstractButton


proc mabstract_button_set_text(self: MTObject, text: cstring): void {.importc: "mabstract_button_set_text", dynlib: wid_lib}
type
    MAbstractButton* = ref object of MWidget
    abstractButton_clicked* = proc(): void {.cdecl.}


proc mabstract_button_onClicked(self:MTObject,ctx:pointer  ,on_clicked: abstractButton_clicked ): void {.cdecl,importc: "mabstract_button_on_clicked", dynlib: wid_lib}
proc onClickedConnect*(self:MAbstractButton,callback:abstractButton_clicked) =
    mabstractButton_onClicked(self.getObj,nil,callback)

proc setText*(self:MAbstractButton,text:string)=
    var obj = self.getObj
    mabstract_button_set_text(obj,text.cstring)

#MPushButton

proc mpush_button_new(parent:MTObject): MTObject {.importc: "mpush_button_new", dynlib: wid_lib}
type
    MPushButton* = ref object of MAbstractButton

proc newMPushButton*(parent:MWidget=nil):MPushButton=
    new result
    var obj = mpush_button_new(nil)
    result.setObj(obj)
    result.setParent(parent)

#MLayout
proc madd_widget(self:MTObject,widget:MTObject): void {.importc: "madd_widget", dynlib: wid_lib}
proc mremove_widget(self:MTObject,widget:MTObject): void {.importc: "mremove_widget", dynlib: wid_lib}

type
    MLayout* = ref object of MLayoutItem

proc addWidget*(self:MLayout,widget:MWidget)=
    madd_widget(self.getObj,widget.getObj)

proc removeWidget*(self:MLayout,widget:MWidget)=
    mremove_widget(self.getObj,widget.getObj)

proc mlayout_set_contents_margins(self:MTObject,left:cint,top:cint,right:cint,bottom:cint) {.importc:"mlayout_set_contents_margins",dynlib:wid_lib}
proc setContentsMargins*(self:MLayout,left:int,top:int,right:int,bottom:int)=
  mlayout_set_contents_margins(self.getObj(),left.cint,top.cint,right.cint,bottom.cint)

#MLineEdit
type
  EchoMode = enum
    EchoModeNormal
    EchoModeNoEcho
    EchoModePassword
    EchoModePasswordEchoOnEdit
  MEchoModeFlags* = EchoMode
type
  MLineEdit* = ref object of MWidget
proc mline_edit_new(parent:MTObject):MTObject {.importc:"mline_edit_new",dynlib:wid_lib}
proc newMLineEdit*(parent:MWidget = nil ):MLineEdit =
  new result
  result.setObj(mline_edit_new(nil))
  result.setParent(parent)
proc mline_edit_set_text(self:MTObject,text:cstring):void {.importc:"mline_edit_set_text",dynlib:wid_lib}
proc setText*(self:MLayoutItem,text:string)=
  mline_edit_set_text(self.getObj(),text.cstring)
proc Mline_edit_get_text(self:MTObject):cstring {.importc:"mline_edit_set_text",dynlib:wid_lib}
proc getText*(self:MLineEdit):string =
  var str= Mline_edit_get_text(self.getObj())
  result = $str
  cstring_free(str)
proc mline_edit_on_text_changed_connect(self:MTObject,onTextChange:VMFnPtrCharPtr):void {.cdecl,importc:"mline_edit_on_text_changed_connect",dynlib:wid_lib}
proc connectOnTextChangeFn*(self:MLineEdit,onTextChange: VMFnPtrCharPtr):void=
  mline_edit_on_text_changed_connect(self.getObj(),onTextChange)

proc mline_edit_set_echo_mode(self:MTObject,mode:cint) {.importc:"mline_edit_set_echo_mode",dynlib:wid_lib}
proc setEchoMode*(self:MLineEdit,mode:EchoMode)=
  mline_edit_set_echo_mode(self.getObj(),mode.cint)

#MBoxLayout

proc mbox_layout_new(dir:cint,parent:MTObject): MTObject {.importc: "mbox_layout_new", dynlib: wid_lib}
proc mbox_layout_add_layout(self:MTObject,laout:MTObject,stretch:cint):void {.importc: "mbox_layout_add_layout", dynlib: wid_lib}
proc mbox_layout_add_widget(self:MTObject,widget:MTObject,stretch:cint,alignment:cint):void {.importc: "mbox_layout_add_widget", dynlib: wid_lib}
proc mbox_layout_add_widget_v1(self:MTObject,widget:MTObject):void {.importc: "mbox_layout_add_widget_v1", dynlib: wid_lib}
proc mbox_layout_set_direction(self:MTObject,direction:cint):void {.importc: "mbox_layout_set_direction", dynlib: wid_lib}
type
    MBoxLayout* = ref object of MLayout

proc newMBoxLayout*(dir:Direction,parent:MWidget=nil):MBoxLayout=
    new result
    result.setObj(mbox_layout_new(dir.cint,nil))
    result.setParent(parent)

proc addLayout*(self:MBoxLayout,layout:MLayout,stretch:int=0)=
    mbox_layout_add_layout(self.getObj,layout.getObj,stretch.cint)

proc addWidget*(self:MBoxLayout,widget:MWidget,stretch:int,alignment:Alignment=Default)=
    mbox_layout_add_widget(self.getObj,widget.getObj,stretch.cint,alignment.cint)

proc addWidget*(self:MBoxLayout,widget:MWidget)=
    mbox_layout_add_widget_v1(self.getObj,widget.getObj)

proc setdirection*(self:MBoxLayout,direction:Direction)=
    mbox_layout_set_direction(self.getObj,direction.cint)

#MHBoxLayout

proc mhbox_layout_new(parent:MTObject):MTObject {.importc: "mhbox_layout_new", dynlib: wid_lib}
type
    MHBoxLayout* = ref object of MBoxLayout

proc newMHBoxLayout*(parent:MWidget=nil):MBoxLayout=
    new result
    result.setObj(mhbox_layout_new(nil))
    result.setParent(parent)

proc mhbox_layout_add_item(self:MTObject,item:MTObject) {.importc:"mhbox_layout_add_item",dynlib:wid_lib}
proc addItem*(self:MHBoxLayout,item:MLayoutItem)=
  mhbox_layout_add_item(self.getObj,item.getObj())

#MVBoxLayout

proc mvbox_layout_new(parent:MTObject):MTObject {.importc: "mvbox_layout_new", dynlib: wid_lib}
type
    MVBoxLayout* = ref object of MBoxLayout

proc newMVBoxLayout*(parent:MWidget=nil):MVBoxLayout=
    new result
    result.setObj(mvbox_layout_new(nil))
    result.setParent(parent)

proc mvbox_layout_add_item(self:MTObject,item:MTObject) {.importc:"mvbox_layout_add_item",dynlib:wid_lib}
proc addItem*(self:MVBoxLayout,item:MLayoutItem)=
  mvbox_layout_add_item(self.getObj(),item.getObj())

#MGridLayout

proc mgrid_layout_new(parent:MTObject):MTObject {.importc: "mgrid_layout_new", dynlib: wid_lib}
proc mgrid_layout_add_layout(self:MTObject,layout:MTObject,row:cint,column:cint,rowSpan:cint,columnSpan:cint,alingnment:cint){.importc: "mgrid_layout_add_layout", dynlib: wid_lib}
proc mgrid_layout_add_widget(self:MTObject,widget:MTObject,row:cint,column:cint,rowSpan:cint,columnSpan:cint,alingnment:cint){.importc: "mgrid_layout_add_widget", dynlib: wid_lib}
type
    MGridLayout* = ref object of MLayout

proc newMGridLayout*(parent:MWidget=nil):MGridLayout =
    new result
    result.setObj(mgrid_layout_new(nil)) 
    result.setParent(parent)

proc addLayout*(self:MGridLayout,layout:MLayoutItem,row:int,column:int,rowSpan:int=1,columnSpan:int=1,alignment:Alignment=Default)=
  mgrid_layout_add_layout(self.getObj,layout.getObj,row.cint,column.cint,rowSpan.cint,columnSpan.cint,alignment.cint)

proc addWidget*(self:MGridLayout,widget:MWidget,row:int,column:int,rowSpan:int=1,columnSpan:int=1,alignment:Alignment=Default)=
  mgrid_layout_add_widget(self.getObj,widget.getObj,row.cint,column.cint,rowSpan.cint,columnSpan.cint,alignment.cint)
proc mgrid_layout_add_item(self:MTObject,item:MTObject,row:cint,column:cint,rowSpan:cint,columnSpan:cint,alingnment:cint){.importc: "mgrid_layout_add_item", dynlib: wid_lib}
proc addItem*(self:MGridLayout,item:MLayoutItem,row:int,column:int,rowSpan:int=1,columnSpan:int=1,alignment:Alignment=Default)=
  mgrid_layout_add_item(self.getObj,item.getObj,row.cint,column.cint,rowSpan.cint,columnSpan.cint,alignment.cint)

#MFrame
proc mframe_new(parent:MTObject,win_type:cint): MTObject {.importc: "mframe_new", dynlib: wid_lib}
proc mframe_set_frame_shape(self:MTObject,win_type:cint): void {.importc: "mframe_set_frame_shape", dynlib: wid_lib}
proc mframe_set_frame_shadow(self:MTObject,shadow:cint): void {.importc: "mframe_set_frame_shadow", dynlib: wid_lib}
type
    MFrame* = ref object of MWidget
    Shape* =enum
        FrameShapeNoFrame
        FrameShapeBox
        FrameShapePanel
        FrameShapeStyledPanel
        FrameShapeHLine
        FrameShapeVLine
        FrameShapeWinPanel
    Shadow* = enum
      FrameShadowPlain
      FrameShadowRaised
      FrameShadowSunken
    MFrameShapeFlags* = Shape
    MFrameShadowFlags* = Shadow

proc newMframe*(parent:MWidget=nil,shape:Shape=FrameShapePanel):MFrame=
    new result
    result.setObj(mframe_new(nil,shape.cint))
    result.setParent(parent)

proc setFrameShape*(self: MFrame,shape:Shape)=
    mframe_set_frame_shape(self.getObj,shape.cint)

proc setFrameShadow*(self:MFrame,shadow:Shadow)=
    mframe_set_frame_shadow(self.getObj,shadow.cint)

proc mframe_set_layout(self:MTObject,layout:MTObject) {.importc:"mframe_set_layout",dynlib:wid_lib}
proc setLayout*(frame:Mframe,layout:MLayout)=
  mframe_set_layout(frame.getObj(),layout.getObj())

#MLabel

proc mlabel_new(parent:MTObject): MTObject {.importc: "mlabel_new", dynlib: wid_lib}
proc mlabel_set_text(parent:MTObject,text:cstring): void {.importc: "mlabel_set_text", dynlib: wid_lib}
proc mlabel_get_text(self:MTObject): cstring {.importc: "mlabel_get_text", dynlib: wid_lib}

type
    MLabel* = ref object of MFrame

proc newMLabel*(parent:MWidget = nil): MLAbel =
    new result
    var obj = mlabel_new(nil)
    result.setObj(obj)
    result.setParent(parent)

proc setText*(self:MLabel,text:string)=
    mlabel_set_text(self.getObj,text.cstring)

proc getText*(self:MLabel): string =
    let s:cstring = mlabel_get_text(self.getObj)
    result = $mlabel_get_text(self.getObj)
    cstring_free(s)

#MSpacerItem
type
  MSpacerItem* = ref object of MLayoutItem
  Orientation* = enum
    Horizontal = 1
    Vertical = 2
  MSpacerItemFlags* = Orientation
proc mspacer_item_new(w:cint,h:cint,orientation:cint):MTObject {.importc:"mspacer_item_new",dynlib:wid_lib}

proc newMSpacerItem*(w:int,h:int,orientation:Orientation):MSpacerItem=
  new result
  result.setObj(mspacer_item_new(w.cint,h.cint,orientation.cint))
#MComboBox
type
  MComboBox* = ref object of MWidget
proc mcombobox_new(parent:MTObject):MTObject {.importc:"mcombobox_new",dynlib:wid_lib}
proc newMComboBox*(parent:MWidget):MComboBox=
  new result
  result.setObj(mcombobox_new(nil))
  result.setParent(parent)
proc mcombobox_set_editable(self:MTObject,is_editable:cint):void {.importc:"mcombobox_set_editable",dynlib:wid_lib}
proc setEditable*(self:MComboBox,isEditable:bool)=
  mcombobox_set_editable(self.getObj(),isEditable.cint)

#MDialog
type
  MDialog* = ref object of MWidget
proc mdialog_new(parent:MTObject):MTObject {.importc:"mdialog_new",dynlib:wid_lib}
proc newMDialog*(parent:MWidget):MDialog=
  new result
  result.setObj(mdialog_new(nil))
  result.setParent(parent)

#**************************************
#********* MGVariant *********
#************************************** 
type
  MGVariant = ref object of MObject
proc mvariant_new*():MTObject{.importc:"mvariant_new",dynlib:wid_lib}
proc newMGVariant*():MGVariant=
  new result 
  result.setObj(mvariant_new())
proc mvariant_set_int*(self:MTObject,val:cint){.importc:"mvariant_set_int",dynlib:wid_lib}
proc setValue*(self:MGVariant,val:int)=
  mvariant_set_int(self.getObj(),val.cint)
proc mvariant_set_int64*(self:MTObject,val:clonglong){.importc:"mvariant_set_int64",dynlib:wid_lib}
proc setValue*(self:MGVariant,val:int64)=
  mvariant_set_int64(self.getObj(),val.clonglong)
proc mvariant_set_float*(self:MTObject,val:cfloat){.importc:"mvariant_set_float",dynlib:wid_lib}
proc setValue*(self:MGVariant,val:float)=
  mvariant_set_float(self.getObj(),val.cfloat)
proc mvariant_set_str*(self:MTObject,val:cstring){.importc:"mvariant_set_str",dynlib:wid_lib}
proc setValue*(self:MGVariant,val:string)=
  mvariant_set_str(self.getObj(),val.cstring)
proc mvariant_to_int*(self:MTObject):cint{.importc:"mvariant_to_int",dynlib:wid_lib}
proc toInt*(self:MGVariant):int=
  result = mvariant_to_int(self.getObj()).int
proc mvariant_to_int64*(self:MTObject):clonglong{.importc:"mvariant_to_int64",dynlib:wid_lib}
proc toInt64*(self:MGVariant):int64=
  result = mvariant_to_int64(self.getObj()).int64
proc mvariant_to_float*(self:MTObject):cfloat{.importc:"mvariant_to_float",dynlib:wid_lib}
proc toFloat*(self:MGVariant):float=
  result = mvariant_to_float(self.getObj()).float
proc mvariant_to_cstring*(self:MTObject):cstring{.importc:"mvariant_to_cstring",dynlib:wid_lib}
proc toString*(self:MGVariant):string=
  var s =  mvariant_to_cstring(self.getObj())
  result = $s
  #cstring_free(s)

#**************************************
#********* MAbstractItemModel *********
#************************************** 
type 
  MAbstractItemModel* = ref object of MObject
  MItemDataRole = enum
    DisplayRole = 0  #	The key data to be rendered in the form of text. (QString)
    DecorationRole =1#The data to be rendered as a decoration in the form of an icon. (QColor, QIcon or QPixmap)
    EditRole=2 # The data in a form suitable for editing in an editor. (QString)
    ToolTipRole=3 #The data displayed in the item's tooltip. (QString)
    StatusTipRole=4 #The data displayed in the status bar. (QString)
    WhatsThisRole=5 #The data displayed for the item in "What's This?" mode. (QString)
    SizeHintRole=13 #The size hint for the item that will be supplied to views. (QSize)


#**************************************
#************* MTableModel ************
#**************************************
type
  MTableModel* = ref object of MAbstractItemModel
proc mtable_model_new(parent:MTObject):MTObject{.importc:"mtable_model_new",dynlib:wid_lib}
proc newMTableModel*(parent:MObject=nil):MTableModel=
  new result
  result.setObj(mtable_model_new(nil))
  result.setParent(parent)
proc mtable_model_get_val_connect(self:MTObject,getValProc:proc(row:cint,col:cint,role:cint):MTObject){.cdecl,importc:"mtable_model_get_val_connect",dynlib:wid_lib}
proc getValConnect*(self:MTableModel,getValProc:proc(row:cint,col:cint,role:cint):MTObject)=
  mtable_model_get_val_connect(self.getObj(),getValProc)
proc mtable_model_get_row_count_connect(self:MTObject,getRowCountProc:proc():cint){.cdecl,importc:"mtable_model_get_row_count_connect",dynlib:wid_lib}
proc getRowCountConnect*(self:MTableModel,getRowCountProc:proc():cint)=
  mtable_model_get_row_count_connect(self.getObj(),getRowCountProc)
proc mtable_model_get_column_count_connect(self:MTObject,getColumnCountProc:proc():cint){.cdecl,importc:"mtable_model_get_column_count_connect",dynlib:wid_lib}
proc getColumnCountConnect*(self:MTableModel,getColumnCountProc:proc():cint)=
  mtable_model_get_column_count_connect(self.getObj(),getColumnCountProc)
proc mtable_model_insert_row_connect(self:MTObject,doInsertRow:proc(position:cint)){.cdecl,importc:"mtable_model_insert_row_connect",dynlib:wid_lib}
proc InsertRowConnect*(self:MTableModel,doInsertRow:proc (position:cint))=
  mtable_model_insert_row_connect(self.getObj(),doInsertRow)
proc mtable_model_insert_row(self:MTObject,position:cint):cint{.importc:"mtable_model_insert_row",dynlib:wid_lib}
proc insertRow*(self:MTableModel,position:int):bool=
  result=mtable_model_insert_row(self.getObj(),position.cint).bool
proc mtable_model_save_data_connect(self:MTObject,saveData:proc(row:cint,col:cint,val:MTObject):cint){.cdecl,importc:"mtable_model_save_data_connect",dynlib:wid_lib}
proc saveDataConnect*(self:MTableModel,saveData:proc(row:cint,col:cint,val:MTObject):cint)=
  mtable_model_save_data_connect(self.getObj(),saveData)
proc mtable_model_get_headers_data_connect(self:MTObject,getHeadersData:proc(section:cint,orientation:cint,role:cint):MTObject){.importc:"mtable_model_get_headers_data_connect",dynlib:wid_lib}
proc headersDataConnect*(self:MTableModel,headersData:proc(section:cint,orientation:cint,role:cint):MTObject)=
  mtable_model_get_headers_data_connect(self.getObj(),headersData)
#**************************************
#************* MModelIndex ************
#************************************** 
type 
  MModelIndex* = ref object of MObject

proc mmodel_indx_new(model:MTObject,row:cint,col:cint):MTObject{.importc:"mmodel_index_new",dynlib:wid_lib}
proc newMModelIndex*(model:MAbstractItemModel,row:int,col:int):MModelIndex=
  new result
  result.setObj(mmodel_indx_new(model.getObj(),row.cint,col.cint))
proc mmodel_index_column(self:MTObject):cint {.importc:"mmodel_index_column",dynlib:wid_lib}
proc column*(self:MModelIndex):int =
  result = mmodel_index_column(self.getObj).int
proc mmodel_index_row(self:MTObject):cint {.importc:"mmodel_index_row",dynlib:wid_lib}
proc row*(self:MModelIndex):int =
  result = mmodel_index_row(self.getObj).int
proc mmodel_index_isvalid(self:MTObject):cint {.importc:"mmodel_index_isvalid",dynlib:wid_lib}
proc isValid*(self:MModelIndex):bool =
  result = mmodel_index_isvalid(self.getObj).bool
proc mmodel_index_get_model(self:MTObject):MTObject {.importc:"mmodel_index_model",dynlib:wid_lib}
proc getModel*(self:MModelIndex):MAbstractItemModel =
  new result
  result.setObj(mmodel_index_get_model(self.getObj()))
  var parent = mobject_get_parent(result.getObj())
  result.setParent(parent)
#**************************************
#********* MAbstractScrollArea ********
#**************************************
type
  MAbstractScrollArea* = ref object of MFrame
#**************************************
#*********** MAbstractItemView ********
#**************************************
type 
  MAbstractItemView = ref object of MAbstractScrollArea
#**************************************
#************** MTableView ************
#**************************************
type
  MTableView*  =  ref object of MAbstractItemView
proc mtable_view_new(parent:MTObject):MTObject {.importc:"mtable_view_new",dynlib:wid_lib}
proc newMTableView*(parent : MWidget=nil):MTableView=
  new result
  result.setObj(mtable_view_new(nil))
  result.setParent(parent)
proc mtable_view_set_model(self:MTObject,model:MTObject){.importc:"mtable_view_set_model",dynlib:wid_lib}
proc setModel*(self:MTableView,model:MAbstractItemModel)=
  mtable_view_set_model(self.getObj(),model.getObj())
proc mtable_view_set_read_only(self:MTObject,read_only:cint){.importc:"mtable_view_set_read_only",dynlib:wid_lib}
proc setReadOnly*(self:MTableView,readOnly:bool)=
  mtable_view_set_read_only(self.getObj(),readOnly.cint)
proc mtable_view_current_row(self:MTObject):cint{.importc:"mtable_view_current_row",dynlib:wid_lib}
proc currentRow*(self:MTableView):int=
  result = mtable_view_current_row(self.getObj()).int
proc mtable_view_current_column(self:MTObject):cint{.importc:"mtable_view_current_column",dynlib:wid_lib}
proc currentColumn*(self:MTableView):int=
  result = mtable_view_current_column(self.getObj()).int

#**********************************
#************* TEST ***************
#**********************************
var app = newMApplication()
var tbl = newMTableView()
var model = newMTableModel()
var layout = newMHBoxLayout()
var wid = newMWidget()
var btn = newMPushButton()
var dataSet :seq[seq[string]]
#var record:seq[string]
proc emptyRecord():seq[string]=
  var s = newSeq[string]()
  s.add("1")
  s.add("2")
  s.add("3")
  return s
dataSet.add(emptyRecord())

proc btnClicked(){.cdecl.}=
  dataSet.add(emptyRecord())
  echo tbl.currentRow()
  echo "inserted:", model.insertRow(tbl.currentRow()+1)
btn.onClickedConnect(btnClicked)  
wid.setLayout(layout)
layout.addWidget(tbl)
layout.addWidget(btn)

proc insertRow(pos:cint)=
  dataSet.insert(emptyRecord(),pos)
model.InsertRowConnect(insertRow)
proc rowCount():cint=
  return dataSet.len().cint
model.getRowCountConnect(rowCount)
proc colCount():cint=
  return emptyRecord().len().cint
proc data(row:cint,col:cint,role:cint):MTObject=
  if role.int == DisplayRole.int or role.int == EditRole.int :
    var v = newMGVariant()
    v.setValue(dataSet[row.int][col.int]);
    return v.getObj()
  return newMGVariant().getObj()
proc saveData(row:cint,col:cint,val:MTObject):cint=
  var s = mvariant_to_cstring(val)
  echo $s
  dataSet[row.int][col.int] = $s
  echo dataSet[row.int][col.int]
  cstring_free(s)
  return 1.cint
proc headersData(col:cint,orientation:cint,role:cint):MTObject=
  result = mvariant_new()
  if role == DisplayRole.cint and orientation == Horizontal.cint:
    if col == 0.cint:
      mvariant_set_str(result,"col1".cstring)
    elif col == 1.cint:
      mvariant_set_str(result,"col2".cstring)
    elif col == 2.cint:
      mvariant_set_str(result,"col3".cstring)
    


model.headersDataConnect(headersData)    
model.saveDataConnect(saveData)  
model.getColumnCountConnect(colCount)
model.getValConnect(data)
tbl.setModel(model)
tbl.setReadOnly(false)
wid.show()
discard app.exec()
