import perser_t,gui
let app = newMApplication()
# let btn = newMPushButton(nil)
# btn.show()
var form = newUserForm(nil)
form.setLayoutDirection(LayoutDirectionRightToLeft)
form.setupUI()
form.show()
let a= app.exec()

echo a
