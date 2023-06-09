import gui
type UserForm* = ref object of MDialog
  verticalLayout*: MVBoxLayout
  frame*: MFrame
  verticalLayout_2*: MVBoxLayout
  gridLayout_2*: MGridLayout
  label_2*: MLabel
  txt_login*: MLineEdit
  txt_pass*: MLineEdit
  label*: MLabel
  label_3*: MLabel
  horizontalSpacer_2*: MSpacerItem
  txt_name*: MLineEdit
  horizontalSpacer*: MSpacerItem
  label_4*: MLabel
  cmb_group*: MComboBox
  label_9*: MLabel
  txt_pass2*: MLineEdit
  verticalSpacer*: MSpacerItem
  ac_new*: MAction
  ac_edit*: MAction
  ac_delete*: MAction
  ac_groups*: MAction
  ac_save*: MAction
  ac_cancel*: MAction

proc newUserForm*(parent:MWidget):UserForm=
  new result
  let obj = newMDialog(parent)
  result.setObj(obj.getObj)
  
proc setupUI*(userForm:UserForm)=
  userForm.setGeometry(MRect(x:0,y:0,width:443,height:129))
  userForm.setWindowTitle("Dialog")
  userForm.verticalLayout=newMVBoxLayout(userForm)
  userForm.frame=newMFrame(userForm)
  userForm.verticalLayout.setContentsMargins(0, 0, 0, 0)
  userForm.frame.setFrameShape(MFrameShapeFlags.FrameShapeStyledPanel)
  userForm.frame.setFrameShadow(MFrameShadowFlags.FrameShadowRaised)
  userForm.verticalLayout_2=newMVBoxLayout(userForm)
  userForm.gridLayout_2=newMGridLayout()
  userForm.label_2=newMLabel(userForm)
  userForm.verticalLayout_2.setContentsMargins(0, 0, 0, 0)
  userForm.txt_login=newMLineEdit(userForm)
  userForm.txt_login.setEchoMode(MEchoModeFlags.EchoModePassword)
  userForm.txt_pass=newMLineEdit(userForm)
  userForm.txt_pass.setEchoMode(MEchoModeFlags.EchoModePassword)
  userForm.label=newMLabel(userForm)
  userForm.label.setText("الاسم")
  userForm.label_3=newMLabel(userForm)
  userForm.label_3.setText("كلمة السر")
  userForm.horizontalSpacer_2 = newMSpacerItem(40,20,MSpacerItemFlags.Horizontal)
  userForm.txt_name=newMLineEdit(userForm)
  userForm.horizontalSpacer = newMSpacerItem(40,20,MSpacerItemFlags.Horizontal)
  userForm.label_4=newMLabel(userForm)
  userForm.label_4.setText("المجموعة")
  userForm.cmb_group=newMComboBox(userForm)
  userForm.cmb_group.setEditable(false)
  userForm.label_9=newMLabel(userForm)
  userForm.label_9.setText("تأكيد كلمة المرور")
  userForm.txt_pass2=newMLineEdit(userForm)
  userForm.txt_pass2.setEchoMode(MEchoModeFlags.EchoModePassword)
  userForm.verticalSpacer = newMSpacerItem(20,40,MSpacerItemFlags.Vertical)
  userForm.ac_new=newMAction(userForm)
  userForm.ac_new.setIcon("../../../python/mnstock/resources/user-plus.svg")
  userForm.ac_new.setText("جديد")
  userForm.ac_new.setShortcut("Alt+N")
  userForm.ac_edit=newMAction(userForm)
  userForm.ac_edit.setIcon("../../../python/mnstock/resources/edit-2.svg")
  userForm.ac_edit.setText("تعديل")
  userForm.ac_edit.setShortcut("Alt+E")
  userForm.ac_delete=newMAction(userForm)
  userForm.ac_delete.setIcon("../../../python/mnstock/resources/user-minus.svg")
  userForm.ac_delete.setText("حذف")
  userForm.ac_delete.setShortcut("Alt+D")
  userForm.ac_groups=newMAction(userForm)
  userForm.ac_groups.setIcon("../../../python/mnstock/resources/users.svg")
  userForm.ac_groups.setText("المجموعات")
  userForm.ac_groups.setShortcut("Alt+G")
  userForm.ac_save=newMAction(userForm)
  userForm.ac_save.setIcon("../../../python/mnstock/resources/save.svg")
  userForm.ac_save.setText("حفظ")
  userForm.ac_save.setShortcut("Alt+S")
  userForm.ac_cancel=newMAction(userForm)
  userForm.ac_cancel.setIcon("../../../python/mnstock/resources/x-circle.svg")
  userForm.ac_cancel.setText("إلغاء")
  userForm.ac_cancel.setShortcut("Alt+C")
  userForm.gridLayout_2.addWidget(userForm.label_2,0,3,1,1)
  userForm.gridLayout_2.addWidget(userForm.txt_login,0,4,1,1)
  userForm.gridLayout_2.addWidget(userForm.txt_pass,1,2,1,1)
  userForm.gridLayout_2.addWidget(userForm.label,0,1,1,1)
  userForm.gridLayout_2.addWidget(userForm.label_3,1,1,1,1)
  userForm.gridLayout_2.addItem(userForm.horizontalSpacer_2,0,0,1,1)
  userForm.gridLayout_2.addWidget(userForm.txt_name,0,2,1,1)
  userForm.gridLayout_2.addItem(userForm.horizontalSpacer,0,5,1,1)
  userForm.gridLayout_2.addWidget(userForm.label_4,2,1,1,1)
  userForm.gridLayout_2.addWidget(userForm.cmb_group,2,2,1,1)
  userForm.gridLayout_2.addWidget(userForm.label_9,1,3,1,1)
  userForm.gridLayout_2.addWidget(userForm.txt_pass2,1,4,1,1)
  userForm.verticalLayout_2.addLayout(userForm.gridLayout_2)
  userForm.verticalLayout_2.addItem(userForm.verticalSpacer)
  userForm.frame.setLayout(userForm.verticalLayout_2)
  userForm.verticalLayout.addWidget(userForm.frame)
  userForm.setLayout(userForm.verticalLayout)
