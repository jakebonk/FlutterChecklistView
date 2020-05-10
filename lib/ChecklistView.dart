import 'package:checklist/ChecklistListView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'ChecklistItemView.dart';
export 'ChecklistItemView.dart';

typedef void OnDropChecklist(int oldListIndex, int listIndex, ChecklistViewState state);
typedef void OnTapChecklist(int listIndex, ChecklistViewState state);
typedef void OnStartDragChecklist(
    int listIndex, ChecklistViewState state);
class ChecklistView extends StatefulWidget {
  Widget title;
  List<ChecklistItemView> items;
  ChecklistListViewState checklistState;
  int index;
  bool isOpen;
  bool canDrag;
  Widget footer;
  OnDropChecklist onDropChecklist;
  OnTapChecklist onTapChecklist;
  OnStartDragChecklist onStartDragChecklist;
  Color backgroundColor;

  ChecklistView(
      {Key key, this.items, this.canDrag,this.footer,this.title, this.checklistState, this.index, this.isOpen, this.onDropChecklist, this.onTapChecklist, this.onStartDragChecklist, this.backgroundColor})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChecklistViewState();
  }
}

class ChecklistViewState extends State<ChecklistView> with AutomaticKeepAliveClientMixin {
  double height;
  double width;
  double headerHeight;
  double footerHeight;

  List<ChecklistItemViewState> itemStates = List<ChecklistItemViewState>();

  void onDropList(int listIndex) {
    widget.checklistState.setState(() {
      if (widget.onDropChecklist != null) {
        widget.onDropChecklist(widget.checklistState.oldListIndex,widget.checklistState.draggedListIndex, this);
      }
      widget.checklistState.draggedListIndex = null;
    });
  }

  void _startDrag(Widget item, BuildContext context) {
    if (widget.checklistState != null) {
      widget.checklistState.setState(() {
        widget.checklistState.height = context.size.height;
        widget.checklistState.draggedListIndex = widget.index;
        widget.checklistState.draggedItemIndex = null;
        widget.checklistState.draggedItem = item;
        widget.checklistState.onDropList = onDropList;
        if (widget.onStartDragChecklist != null) {
          widget.onStartDragChecklist(widget.index, this);
        }
        widget.checklistState.oldListIndex = widget.index;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  void afterFirstLayout(BuildContext context) {
    height = context.size.height;
    width = context.size.width;
    if(_headerKey.currentContext != null) {
      headerHeight = _headerKey.currentContext.size.height;
    }else{
      headerHeight = 0;
    }
    if(_footerKey.currentContext != null) {
      footerHeight = _footerKey.currentContext.size.height;
    }else{
      footerHeight = 0;
    }
  }

  GlobalKey _headerKey = GlobalKey();
  GlobalKey _footerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => afterFirstLayout(context));
    List<Widget> widgets = new List();
    Widget header = GestureDetector(
      key: _headerKey,
        onTapDown: (otd) {
          if(widget.checklistState != null) {
            RenderBox object = context.findRenderObject();
            Offset pos = object.localToGlobal(Offset.zero);
            widget.checklistState.initialX = pos.dx;
            widget.checklistState.initialY = pos.dy;

            widget.checklistState.topListY = pos.dy;
            widget.checklistState.bottomListY = pos.dy + object.size.height;
          }
        },
        onTap: (){
          if (widget.onTapChecklist != null) {
            widget.onTapChecklist(widget.index, this);
          }
        },
        onTapCancel: () {},
        onLongPress: () {
          if(widget.canDrag == null || widget.canDrag == true) {
            _startDrag(widget, context);
          }
        },
        child: Container(
            color: (widget.backgroundColor != null)?widget.backgroundColor:Colors.white,
            child: Row(
              children: <Widget>[Expanded(child: widget.title??Container())],
            )));
    widgets.add(header);
  if(widget.items != null){
    for (int i = 0; i < widget.items.length; i++) {
      if (widget.items[i].checklist == null || widget.items[i].index != i || widget.items[i].checklist.widget.index != widget.index || widget.items[i].checklist == this) {
        widget.items[i] = ChecklistItemView(
          onTapItem: widget.items[i].onTapItem,
          onStartDragItem: widget.items[i].onStartDragItem,
          onDropItem: widget.items[i].onDropItem,
          onChanged: widget.items[i].onChanged,
          canDrag: widget.items[i].canDrag,
          index: i,
          title: widget.items[i].title,
          value: widget.items[i].value,
          backgroundColor: widget.items[i].backgroundColor,
          checklist: this,
        );
      }
      if (widget.checklistState.draggedItemIndex == i &&
          widget.checklistState.draggedListIndex == widget.index) {
        widgets.add(Opacity(
          opacity: 0.0,
          child: widget.items[i],
        ));
      } else {
        widgets.add(AnimatedCrossFade(duration: Duration(milliseconds: 140),crossFadeState: (widget.isOpen == null || widget.isOpen)?CrossFadeState.showFirst:CrossFadeState.showSecond,firstChild: widget.items[i], secondChild: Container(),));
      }
    }
  }
    if(widget.checklistState != null && widget.index != null) {
      if (widget.checklistState.checklistStates.length > widget.index) {
        widget.checklistState.checklistStates.removeAt(widget.index);
      }
      widget.checklistState.checklistStates.insert(widget.index, this);
    }
    if(widget.footer != null){
      widgets.add(AnimatedCrossFade(duration: Duration(milliseconds: 140),crossFadeState: (widget.isOpen == null || widget.isOpen)?CrossFadeState.showFirst:CrossFadeState.showSecond,firstChild:Material(key: _footerKey,color:widget.backgroundColor,child: widget.footer), secondChild: Container(),));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets??[],
    );
  }
}
