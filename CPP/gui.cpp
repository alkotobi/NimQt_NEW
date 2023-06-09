//
// Created by merhab on 2023/5/13.
//

#include <QtCore/Qt>
#include <QFlags>

enum LayoutDirection {
  LayoutDirectionLeftToRight = 0,
  LayoutDirectionRightToLeft =1,
  LayoutDirectionAuto =2
} ;
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

enum WindowType {
    Widget, Window, Dialog, Sheet, Drawer, Popup, Tool, ToolTip, SplashScreen, SubWindow, ForeignWindow, CoverWindow
};
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

enum Orientation {
    Horizontal = 0x1,
    Vertical = 0x2
};


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


enum Direction {
    LeftToRight = 0, RightToLeft = 1, TopToBottom = 2, BottomToTop = 3
};



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

char cstring_is_equal(const char *str1, const char *str2)
{
    size_t count1= cstring_count(str1);
    size_t count2= cstring_count(str2);
    if (count1!=count2){
        return 0;
    }
    for (int i=0;i<count1 ;i++ ) {
        if(str1[i]!=str2[i]){
            return 0;
        }
    }
    return 1;
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
typedef void (*VMFnPtrPtr)(void*e, void *edt);

typedef QMouseEvent MMouseEvent;
typedef void (*VMFn)();
typedef void (*VMFnPtr)(void*);
typedef void (*VMFnMouseEvent)(MMouseEvent*);
typedef void (*VMFnKeyEvent)(QKeyEvent*);
typedef void (*VMFnPtrChar)(char*);
typedef void (*VMFnPtrCharPtr)(char*,void*);
typedef int (*IntFnPtr)(void*);
typedef int(*IntFnIntInt)(int,int);
typedef float(*FltFnIntInt)(int,int);
typedef char*(*PtrCharFnIntInt)(int,int);
typedef int64_t(*Int64FnIntInt)(int,int);
//MLineEdit
enum EchoMode { Normal=0, NoEcho=1, Password=2, PasswordEchoOnEdit=3};

#include <QtWidgets/QLineEdit>
class MLineEdit : public QLineEdit {
private:
    VMFnPtrPtr onKeyPressed = 0; 
    VMFnPtrCharPtr onTextChanged =0;
public:

    explicit MLineEdit(QWidget *parent = nullptr) :
            QLineEdit(parent) {
          QObject::connect(this,&QLineEdit::textChanged,this,
                     &MLineEdit::textChanged);

    }
  void textChanged(QString str){
    qDebug() << "is connected";
    if(onTextChanged){
      onTextChanged(str.toUtf8().data(),this);
    }
  }

    void keyPressEvent(QKeyEvent *e) override {
        if (onKeyPressed) {
            onKeyPressed(e, this);
        }
        if (e->isAccepted()) {
            QLineEdit::keyPressEvent(e);
        }
    }
  void setOnTextChangedFn(VMFnPtrCharPtr fn){
    this->onTextChanged = fn;
  }
    void setOnKeyPressedFn(VMFnPtrPtr fn){
    this->onKeyPressed = fn;
  }
};


extern "C"
MLineEdit *mline_edit_new(QWidget *parent) {
    return new(std::nothrow) MLineEdit(parent);
}

extern "C"
void mline_edit_on_text_changed_connect(MLineEdit *self, VMFnPtrCharPtr fn) {
    self->setOnTextChangedFn(fn);
}
extern "C"
void mline_edit_on_key_pressed_connect(MLineEdit *self, VMFnPtrPtr fn) {
    self->setOnKeyPressedFn(fn);
}

extern "C"
void mline_edit_set_text(MLineEdit *self, const char *text) {
    self->setText(text);
}

extern "C"
char *mline_edit_get_text(MLineEdit *self) {
    return cstring_new_clone(self->text().toUtf8().data());
}

extern "C"
void mline_edit_set_echo_mode(MLineEdit* self , EchoMode mode){
  self->setEchoMode((QLineEdit::EchoMode)mode);  
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
typedef QLayoutItem MLayoutItem;

//MWidget

typedef QWidget MWidget;

extern "C"
void mwidget_set_geometry(MWidget* self,int x, int y, int width, int height){
  self->setGeometry(QRect(x,y,width,height));
}

extern "C"
void mwidget_set_window_title(MWidget* self,const char* title){
  self->setWindowTitle(title);
}
extern "C"
void mwidget_set_layout_direction(MWidget* self , LayoutDirection dir){
  self->setLayoutDirection((Qt::LayoutDirection) dir);
}
//MLayout
typedef QLayout MLayout;

extern "C"
void mlayout_set_contents_margins(MLayout* self,int left, int top, int right, int bottom){
  self->setContentsMargins(left,top,right,bottom);
}
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
/*
 * don't forget free the returned char*
 */
extern "C"
char* mabstract_button_get_text(MAbstractButton* self){
    return cstring_new_clone(self->text().toUtf8().data());

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
MAction *maction_new(MObject *parent) {
    return new(std::nothrow) MAction(parent);
}

extern "C"
void maction_set_icon(MAction *self, const char *icon_path) {
    MIcon icon;
    icon.addFile(MString::fromUtf8(icon_path));
    self->setIcon(icon);
}

extern "C"
void maction_set_text(MAction* self,const char* text){
  self->setText(text);
}
#include <QKeySequence>
extern "C"
void maction_set_shortcut(MAction* self,const char* shortcut){
  self->setShortcut(QKeySequence(shortcut));
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
  self->addWidget(widget, stretch, QFlags<Qt::AlignmentFlag>(malignment_flags(alignment)));
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
void mgrid_layout_add_layout(MGridLayout *self, MLayout *layout, int row, int column,int rowSpan,int columnSpan, Alignment alignment) {
  self->addLayout(layout, row, column, rowSpan, columnSpan,QFlags<Qt::AlignmentFlag>(malignment_flags(alignment)));
}


extern "C"
void mgrid_layout_add_item(MGridLayout *self, MLayoutItem *item, int row, int column,int rowSpan,int columnSpan, Alignment alignment) {
    self->addItem(item, row, column, rowSpan, columnSpan, (Qt::Alignment) malignment_flags(alignment));
}

extern "C"
void mgrid_layout_add_widget(MGridLayout *self, MWidget *widget, int row, int column,
                             int rowSpan,
                             int columnSpan, Alignment alignment) {
    self->addWidget(widget, row, column, rowSpan, columnSpan, QFlags<Qt::AlignmentFlag>(malignment_flags(alignment)));
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

extern "C"
void mhbox_layout_add_item(MHBoxLayout* self , MLayoutItem* item){
    self->addItem(item);
}


//QVBoxLayout
typedef QVBoxLayout MVBoxLayout;
extern "C"
MVBoxLayout* mvbox_layout_new(MWidget* parent){
    std::cout << "mvbox_layout_new";
    return new (std::nothrow) MVBoxLayout(parent);
}

extern "C"
MVBoxLayout* mvbox_layout_new_v1(){
    std::cout << "mvbox_layout_new_v1";
    return new (std::nothrow) MVBoxLayout();
}

extern "C"
void mvbox_layout_add_item(MVBoxLayout* self, MLayoutItem* item){
    self->addItem(item);
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
  int f = mwindow_type_flags(win_type); 
  return new (std::nothrow) MFrame(parent,QFlags<Qt::WindowType>(f));
}

extern "C"
void mframe_set_frame_shape(MFrame *self, Shape shape) {
  self->setFrameShape((QFrame::Shape)mframe_shape_flags(shape));
}

extern "C"
void mframe_set_frame_shadow(MFrame *self, Shadow shadow) {
    self->setFrameShadow((QFrame::Shadow) mframe_shadow_flags(shadow));
}

extern "C"
void mframe_set_layout(MFrame *self, MLayout* layout) {
    self->setLayout(layout);
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

//MPushButton

#include <QtWidgets/QPushButton>

class MPushButton : public QPushButton {
private:
    VMFnMouseEvent onMousePressed = 0;
    VMFnKeyEvent onKeyPressed = 0;
    VMFnPtr onPressed = 0;
    void mousePressEvent(MMouseEvent *event) override {
        if (onMousePressed) {
            onMousePressed(event);
        }
        if (onPressed){
            if(event->button()==Qt::LeftButton){
                onPressed(this);
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
            if(event->key()==Qt::Key_Return or event->key()==Qt::Key_Space){
                onPressed(this);
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
    void onPressedConnect(VMFnPtr fn){
        onPressed = fn;
    }


};

extern "C"
MPushButton *mpush_button_new(MWidget *parent) {
    return new(std::nothrow)MPushButton(parent);
}
extern "C"
void mpush_button_on_clicked_connect(MPushButton* self , VMFnPtr onclick){
    self->onPressedConnect(onclick);

}

extern "C"
char* mpush_button_get_text(MPushButton* self ){
     char* str =cstring_new_clone((char*)self->text().toUtf8().data());
    return str;

}
//
// Created by merhab on 2023/5/9.
//
#include <QtWidgets/QSpacerItem>
typedef QSpacerItem MSpacerItem;
extern "C"
MSpacerItem* mspacer_item_new(int w,int h,Orientation orientation){
    MSpacerItem* s =0;
    switch (orientation) {
        case Horizontal:
	  s= new (std::nothrow) QSpacerItem(w,h,QSizePolicy::Expanding, QSizePolicy::Minimum);
            break;
        case Vertical:
	  s= new (std::nothrow) QSpacerItem(w,h,QSizePolicy::Minimum, QSizePolicy::Expanding);
            break;
    }
    return s;
}

//MComboBox
#include <QtWidgets/QComboBox>
class MComboBox: public QComboBox{
private:
public:
  MComboBox(MWidget* parent = 0):QComboBox(parent){
    
  }
};
extern "C"
MComboBox* mcombobox_new(MWidget* parent){
  return new (std::nothrow) MComboBox(parent);
}


extern "C"
void mcombobox_set_editable(MComboBox* self,int is_editable){
  self->setEditable(is_editable);
}


//MDialog
#include <QtWidgets/QDialog>
class MDialog : public QDialog{

private:

public:
  MDialog(MWidget* parent = 0):QDialog(parent){

  }
};

extern "C"
MDialog* mdialog_new(MWidget* parent){
  return new (std::nothrow) MDialog(parent);
}

extern "C"
void mdialog_show(MDialog* self){
  self->show();
}

//MAbstractItemModel
#include <QAbstractItemModel>
typedef QAbstractItemModel MAbstractItemModel;

//MModelIndex dec
#include <QModelIndex>
typedef QModelIndex  MModelIndex;

//MModelIndex imp
extern "C"
MModelIndex* mmodel_index_new(MAbstractItemModel* model,int row,int col){
  MModelIndex* ind = new (std::nothrow) QModelIndex();
  *ind = model->index(row, col);
  return ind;
}
extern "C"
int mmodel_index_column(MModelIndex* index){
  return index->column();
}

extern "C"
int mmodel_index_row(MModelIndex* index){
  return index->row();
}

extern "C"
int mmodel_index_isvalid(MModelIndex* index){
  return index->isValid();
}

extern "C"
const MAbstractItemModel * mmodel_index_model(MModelIndex* index){
  return index->model();
}

//MAbstractScrollArea
#include <QAbstractItemView>
typedef QAbstractItemView MAbstractItemView;

extern "C"
int mabstract_item_view_alternating_row_colors(MAbstractItemView* self){
  return self->alternatingRowColors();
}

extern "C"
void mabstract_set_item_view_alternating_row_colors(MAbstractItemView* self,int enable){
  return self->setAlternatingRowColors(enable);
}

extern "C"
void mabstract_item_view_close_persistent_editor(MAbstractItemView* self,QModelIndex* index){
  return self->closePersistentEditor(*index);
}
//MVariant
typedef QVariant MVariant;
extern "C"
MVariant* mvariant_new(){
  return new (std::nothrow) MVariant();  
}
extern "C"
void mvariant_set_int(MVariant* self,int val){
  self->setValue(val);  
}
void mvariant_set_int64(MVariant* self,int64_t val){
  self->setValue(val);  
}
void mvariant_set_float(MVariant* self,float val){
  self->setValue(val);  
}
void mvariant_set_str(MVariant* self,char* val){
  self->setValue(val);
}
//MTableModel
typedef QAbstractTableModel MAbstractTableModel;
typedef enum{DisplayRole = 0,//	The key data to be rendered in the form of text. (QString)
  DecorationRole =1,//The data to be rendered as a decoration in the form of an icon. (QColor, QIcon or QPixmap)
  EditRole=2,//The data in a form suitable for editing in an editor. (QString)
  ToolTipRole=3,//The data displayed in the item's tooltip. (QString)
  StatusTipRole=4,//The data displayed in the status bar. (QString)
  WhatsThisRole=5,//The data displayed for the item in "What's This?" mode. (QString)
  SizeHintRole=13//The size hint for the item that will be supplied to views. (QSize)
} MItemDataRole;
typedef QVector<QVariant> MRecord;
typedef QVector<MRecord> MRecordset;
class MTableModel : public MAbstractTableModel{
private:
  MRecordset dataset;


public:
  void append(MRecord rd){
    this->dataset.append(rd);
  }

  
  explicit MTableModel(int row_count,int column_count,MVariant* (*getValFn)(int,int),MObject* parent = 0):MAbstractTableModel(parent){
    for (int i=0 ; i < row_count; ++i) {
      MRecord r;
      dataset.append(r);
      for (int j =0; j < column_count; ++j) {
	MVariant* v = getValFn(i, j);
	dataset[i].append(*v);
	delete v;
      }
    }
  }
  int rowCount(const QModelIndex &parent = QModelIndex()) const {
    return this->dataset.count();
  }
  int columnCount(const QModelIndex &parent = QModelIndex()) const{
    if (dataset.count()>0) {
      return dataset[0].count();
    }
    return 0;
  }
  QVariant data(const QModelIndex &index, int role = Qt::DisplayRole){
    
  }
};
//MTableView
#include <QTableView>
class MTableView : public QTableView{
private:
public:
  explicit MTableView(MWidget *parent = nullptr) :QTableView(parent){
    
  }
};  

extern "C"
MTableView* mtable_view_new(MWidget* parent){
  return new (std::nothrow) MTableView(parent);
}


