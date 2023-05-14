//
// Created by merhab on 2023/5/13.
//

enum Alignment {
    Default,
    AlignLeft,
    AlignRight,
    AlignHCenter,
    AlignJustify,
    AlignTop,
    AlignBottom,
    AlignVCenter,
    AlignBaseline,
    AlignCenter,
    AlignAbsolute,
    AlignLeading,
    AlignTrailing,
    AlignHorizontal_Mask,
    AlignVertical_Mask
};
enum WindowType {
    Widget, Window, Dialog, Sheet, Drawer, Popup, Tool, ToolTip, SplashScreen, SubWindow, ForeignWindow, CoverWindow
};
enum Orientation {
    Horizontal = 0x1,
    Vertical = 0x2
};
enum Direction {
    LeftToRight = 0, RightToLeft = 1, TopToBottom = 2, BottomToTop = 3
};

#include <QtCore/Qt>


extern "C"
int mwindow_type_flags(WindowType flag) {
    switch (flag) {

        case Widget:
            return Qt::Widget;
        case Window:
            return Qt::Window;
        case Dialog:
            return Qt::Dialog;
        case Sheet:
            return Qt::Sheet;
        case Drawer:
            return Qt::Drawer;
        case Popup:
            return Qt::Popup;
        case Tool:
            return Qt::Tool;
        case ToolTip:
            return Qt::ToolTip;
        case SplashScreen:
            return Qt::SplashScreen;
        case SubWindow:
            return Qt::SubWindow;
        case ForeignWindow:
            return Qt::ForeignWindow;
        case CoverWindow:
            return Qt::CoverWindow;
    }
}
extern "C"
int malignment_flags(Alignment flag) {
    switch (flag) {
        default:
            break;
        case AlignLeft:
            return Qt::AlignLeft;
        case AlignRight:
            return Qt::AlignRight;
        case AlignHCenter:
            return Qt::AlignHCenter;
        case AlignJustify:
            return Qt::AlignJustify;
        case AlignTop:
            return Qt::AlignTop;
        case AlignBottom:
            return Qt::AlignBottom;
        case AlignVCenter:
            return Qt::AlignVCenter;
        case AlignBaseline:
            return Qt::AlignBaseline;
        case AlignCenter:
            return Qt::AlignCenter;
        case AlignAbsolute:
            return Qt::AlignAbsolute;
        case AlignLeading:
            return Qt::AlignLeading;
        case AlignTrailing:
            return Qt::AlignTrailing;
        case AlignHorizontal_Mask:
            return Qt::AlignHorizontal_Mask;
        case AlignVertical_Mask:
            return Qt::AlignVertical_Mask;
        case Default:
            return Qt::Alignment();
    }

}

extern "C"
int morientation_flags(Orientation flag) {
    switch (flag) {
        case Horizontal:
            return Qt::Horizontal;
        case Vertical:
            return Qt::Vertical;
    }
    return 0;
}


#include <cstdlib>
#include <cassert>

void mnassert(void *ptr) {
    assert(ptr);
}

void *mnalloc(size_t size) {
    void *ret = malloc(size);
    mnassert(ret);
    return ret;
}

void mnfree(void *ptr) {
    free(ptr);
}

size_t cstring_count(const char *str) {
    if (!str) {
        return 0;
    }
    size_t j;
    j = 0;
    for (;;) {
        if (str[j] == '\0') {
            break;
        }
        j++;
    }
    return j;
}

size_t cstring_size(const char *str) {
    return cstring_count(str) + 1;
}

char *cstring_new_clone(const char *str) {
    if (!str) {
        return 0;
    }
    size_t size = cstring_size(str);
    char *str2 = (char *) malloc(sizeof(char) * size);
    assert(str2);
    for (int i = 0; str[i] != 0; i++) {
        str2[i] = str[i];

    }
    str2[size - 1] = 0;
    return str2;
}



#include <QtCore/QString>

typedef QString MString;

#include <QtGui/QKeyEvent>
typedef void (*voidMFnMKeyEventPtr)(QKeyEvent *e, void *edt);

typedef QMouseEvent MMouseEvent;
typedef void (*VMFn)();
typedef void (*VMFnMouseEvent)(MMouseEvent*);
typedef void (*VMFnKeyEvent)(QKeyEvent*);


//MLineEdit
#include <QtWidgets/QLineEdit>
class MLineEdit : public QLineEdit {
public:
    voidMFnMKeyEventPtr onKeyPressed = 0;

    explicit MLineEdit(QWidget *parent = nullptr) :
            QLineEdit(parent) {

    }

    void keyPressEvent(QKeyEvent *e) override {
        if (onKeyPressed) {
            onKeyPressed(e, this);
        }
        if (e->isAccepted()) {
            QLineEdit::keyPressEvent(e);
        }
    }
};


extern "C"
MLineEdit *mline_edit_new(QWidget *parent) {
    return new(std::nothrow) MLineEdit(parent);
}

extern "C"
void mline_edit_on_key_pressed_connect(MLineEdit *self, voidMFnMKeyEventPtr fn) {
    self->onKeyPressed = fn;
}

extern "C"
void mline_edit_set_text(MLineEdit *self, const char *text) {
    self->setText(text);
}

extern "C"
char *mline_edit_get_text(MLineEdit *self) {
    return cstring_new_clone(self->text().toUtf8().data());
}

//MObject
#include <QtCore/QObject>


typedef QObject MObject;
extern "C"
void mobject_del(MObject *self) {
    delete self;
}

extern "C"
MObject *mobject_new(MObject *parent) {
    return new(std::nothrow)MObject(parent);
}

extern "C"
void mobject_set_parent(MObject *self, MObject *parent) {
    self->setParent(parent);
}

extern "C"
MObject *mobject_get_parent(MObject *self) {
    return self->parent();
}

extern "C"
void mobject_set_object_name(MObject *self, const char *name) {
    self->setObjectName(name);
}
//MLayout
#include <QtWidgets/QLayout>
#include <QtWidgets/QWidget>

typedef QWidget MWidget;
typedef QLayout MLayout;
extern "C"
void mlayout_add_widget(MLayout *self, MWidget *widget) {
    self->addWidget(widget);
}

extern "C"
void mlayout_remove_widget(MLayout *self, MWidget *widget) {
    self->removeWidget(widget);
}

//MWidget

extern "C"
MWidget *mwidget_new(MWidget *parent) {
    return new(std::nothrow) MWidget(parent);
}

extern "C"
void mwidget_show(MWidget *self) {
    self->show();
}

extern "C"
void mwidget_set_layout(MWidget *self, MLayout *layout) {
    self->setLayout(layout);
}

extern "C"
void mwidget_set_parent(MWidget *self, MWidget *parent) {
    self->setParent(parent);
}

//QAbstractButton

#include <QtWidgets/QAbstractButton>

typedef QAbstractButton MAbstractButton;

extern "C"
void mabstract_button_on_clicked(MAbstractButton *self, void *ctx, VMFn on_clicked) {
    MObject::connect(self, &MAbstractButton::clicked, [=] {
        on_clicked();
    });
}

extern "C"
void mabstract_button_set_text(MAbstractButton *self, const char *text) {
    self->setText(MString(text));
}


//MIcon

#include <QtGui/QIcon>

typedef QIcon MIcon;

extern "C"
MIcon *micon_new() {
    return new(std::nothrow) MIcon();
}

extern "C"
void micon_add_file(MIcon *self, const char *file_name) {
    self->addFile(MString::fromUtf8(file_name));
}

//MAction
#include <QtGui/QAction>

typedef QAction MAction;
extern "C"
MAction *m_action_new(MObject *parent) {
    return new(std::nothrow) MAction(parent);
}

extern "C"
void m_action_set_icon(MAction *self, const char *icon_path) {
    MIcon icon;
    icon.addFile(MString::fromUtf8(icon_path));
    self->setIcon(icon);
}

#include <QtWidgets/QApplication>
#include <iostream>

typedef QApplication MApplication;

extern "C"
MApplication *mapplication_new(int argc, char **argv) {
    std::cout << " [TRACE] Create MAppliction Object Ok" << std::endl;
    return new MApplication(argc, argv);
}

extern "C"
MApplication *mapplication_new2() {
    std::cout << " [TRACE] Create MAppliction Object Ok" << std::endl;
    static int argc = 1;
    static const char *argv[] = {"dummy_app"};
    return new MApplication(argc, (char **) argv);
}

extern "C"
int mapplication_exec(MApplication *self) {
    return self->exec();
}

extern "C"
void mapplication_quit(MApplication *self) {
    return self->quit();
}


//MBoxLayout

typedef QBoxLayout MBoxLayout;

extern "C"
MBoxLayout *mbox_layout_new(Direction dir, MWidget *parent) {
    return new(std::nothrow) MBoxLayout(MBoxLayout::Direction(dir), parent);
}

extern "C"
void mbox_layout_add_layout(MBoxLayout *self, MLayout *layout, int stretch) {
    self->addLayout(layout, stretch);
}

extern "C"
void mbox_layout_add_layout_v1(MBoxLayout *self, MLayout *layout) {
    self->addLayout(layout, 0);
}

extern "C"
void mbox_layout_add_widget(MBoxLayout *self, MWidget *widget, int stretch, Alignment alignment) {
    self->addWidget(widget, stretch, (Qt::Alignment) malignment_flags(alignment));
}

extern "C"
void mbox_layout_add_widget_v1(MBoxLayout *self, MWidget *widget) {
    self->addWidget(widget);
}

extern "C"
void mbox_layout_set_direction(MBoxLayout *self, Direction direction) {
    self->setDirection((MBoxLayout::Direction) direction);
}

//MGridLayout
// Created by merhab on 2023/5/5.
//

typedef QGridLayout MGridLayout;
extern "C"
MGridLayout *mgrid_layout_new(MWidget *parent) {
    return new(std::nothrow) MGridLayout(parent);
}

extern "C"
void mgrid_layout_add_layout(MGridLayout *self, MLayout *layout, int row, int column,
                             int rowSpan,
                             int columnSpan, Alignment alignment) {
    self->addLayout(layout, row, column, rowSpan, columnSpan, (Qt::Alignment) malignment_flags(alignment));
}

extern "C"
void mgrid_layout_add_widget(MGridLayout *self, MWidget *widget, int row, int column,
                             int rowSpan,
                             int columnSpan, Alignment alignment) {
    self->addWidget(widget, row, column, rowSpan, columnSpan, (Qt::Alignment) malignment_flags(alignment));
}

//MHBoxLayout

typedef QHBoxLayout MHBoxLayout;

extern "C"
MHBoxLayout *mhbox_layout_new(MWidget *parent) {
    return new(std::nothrow) MHBoxLayout(parent);
}

extern "C"
MHBoxLayout *mhbox_layout_new_v1() {
    return new(std::nothrow) MHBoxLayout();
}

//QVBoxLayout
typedef QVBoxLayout MVBoxLayout;
extern "C"
MVBoxLayout* mvbox_layout_new(MWidget* parent){
    return new (std::nothrow) MVBoxLayout(parent);
}

extern "C"
MVBoxLayout* mvbox_layout_new_v1(){
    return new (std::nothrow) MVBoxLayout();
}


//
// Created by merhab on 2023/5/5.
//

#include <QtWidgets/QFrame>

enum Shape {
    NoFrame, Box, Panel, StyledPanel, HLine, VLine, WinPanel
};
enum Shadow {
    Plain, Raised, Sunken
};

int mframe_shadow_flags(Shadow shadow) {
    switch (shadow) {

        case Plain:
            return QFrame::Plain;
        case Raised:
            return QFrame::Raised;
        case Sunken:
            return QFrame::Sunken;
    }
}

int mframe_shape_flags(Shape shape) {
    switch (shape) {

        case NoFrame:
            return QFrame::NoFrame;
        case Box:
            return QFrame::Box;
        case Panel:
            return QFrame::Panel;
        case StyledPanel:
            return QFrame::StyledPanel;
        case HLine:
            return QFrame::HLine;
        case VLine:
            return QFrame::VLine;
        case WinPanel:
            return QFrame::WinPanel;
    }
}

typedef QFrame MFrame;
extern "C"
MFrame *mframe_new(MWidget *parent, WindowType win_type) {
    return new(std::nothrow) MFrame(parent, (Qt::WindowFlags) mwindow_type_flags(win_type));
}

extern "C"
void mframe_set_frame_shape(MFrame *self, Shape shape) {
    self->setFrameShape((QFrame::Shape) mframe_shape_flags(shape));
}

extern "C"
void mframe_set_frame_shadow(MFrame *self, Shadow shadow) {
    self->setFrameShadow((QFrame::Shadow) mframe_shadow_flags(shadow));
}

//MLabel
#include <QtWidgets/QLabel>

typedef QLabel MLabel;
extern "C"
MLabel *mlabel_new(MWidget *parent) {
    return new(std::nothrow) MLabel(parent);
}
extern "C"
void mlabel_set_text(MLabel *self, const char *text) {
    self->setText(text);
}
extern "C"
char *mlabel_get_text(MLabel *self) {
    return cstring_new_clone(self->text().toUtf8().data());
}

#include <QtWidgets/QPushButton>

class MPushButton : public QPushButton {
private:
    VMFnMouseEvent onMousePressed = 0;
    VMFnKeyEvent onKeyPressed = 0;
    VMFn onPressed = 0;
    void mousePressEvent(MMouseEvent *event) override {
        if (onMousePressed) {
            onMousePressed(event);
        }
        if (onPressed){
            if(event->button()==Qt::LeftButton){
                onPressed();
            }

        }
        if (event->isAccepted()) {
            QPushButton::mousePressEvent(event);
        }
    }

    void keyPressEvent(QKeyEvent *event) override {
        if (onKeyPressed){
            onKeyPressed(event);
        }
        if (onPressed){
            if(event->key()==Qt::Key_Enter or event->key()==Qt::Key_Space){
                onPressed();
            }
        }

        if(event->isAccepted()){
            QPushButton::keyPressEvent(event);
        }
    }

public:
    explicit MPushButton(MWidget *parent = nullptr) : QPushButton(parent) {

    }
    void onMousePressedConnect(VMFnMouseEvent fn){
        onMousePressed = fn;
    }
    void onKeyPressedConnect(VMFnKeyEvent fn){
        onKeyPressed = fn;
    }
    void onPressedConnect(VMFn fn){
        onPressed = fn;
    }


};

extern "C"
MPushButton *mpush_button_new(MWidget *parent) {
    return new(std::nothrow)MPushButton(parent);
}


//
// Created by merhab on 2023/5/9.
//
#include <QtWidgets/QSpacerItem>
typedef QSpacerItem MSpacerItem;
extern "C"
MSpacerItem* mspacer_item_new(int w,int h,int direction,Orientation orientation){
    MSpacerItem* s =0;
    switch (orientation) {
        case Horizontal:
            s= new (std::nothrow) QSpacerItem(0,0,QSizePolicy::Expanding, QSizePolicy::Minimum);
            break;
        case Vertical:
            s= new (std::nothrow) QSpacerItem(0,0,QSizePolicy::Minimum, QSizePolicy::Expanding);
            break;
    }
    return s;
}



