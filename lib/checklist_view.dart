library checklist;

import 'package:checklist/checklist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
export 'checklist_item_view.dart';

typedef void OnDropChecklist(int oldListIndex, int listIndex, ChecklistViewState state);
typedef void OnTapChecklist(int listIndex, ChecklistViewState state);
typedef void OnStartDragChecklist(
    int listIndex, ChecklistViewState state);
class ChecklistView extends StatefulWidget {
  final Widget title;
  final List<ChecklistItemView> items;
  final ChecklistState checklistState;
  final int index;
  final OnDropChecklist onDropChecklist;
  final OnTapChecklist onTapChecklist;
  final OnStartDragChecklist onStartDragChecklist;
  final Color backgroundColor;

  const ChecklistView(
      {Key key, this.items, this.title, this.checklistState, this.index, this.onDropChecklist, this.onTapChecklist, this.onStartDragChecklist, this.backgroundColor})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChecklistViewState();
  }
}

class ChecklistViewState extends State<ChecklistView> {
  double height;
  double width;

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

  void afterFirstLayout(BuildContext context) {
    height = context.size.height;
    width = context.size.width;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => afterFirstLayout(context));
    List<Widget> widgets = new List();
    widgets.add(GestureDetector(
        onTapDown: (otd) {
          RenderBox object = context.findRenderObject();
          Offset pos = object.localToGlobal(Offset.zero);
          widget.checklistState.initialX = pos.dx;
          widget.checklistState.initialY = pos.dy;

          widget.checklistState.topListY = pos.dy;
          widget.checklistState.bottomListY = pos.dy+object.size.height;
        },
        onTap: (){
          if (widget.onTapChecklist != null) {
            widget.onTapChecklist(widget.index, this);
          }
        },
        onTapCancel: () {},
        onLongPress: () {
          _startDrag(widget, context);
        },
        child: Container(
            color: (widget.backgroundColor != null)?widget.backgroundColor:Colors.white,
            child: Row(
          children: <Widget>[Expanded(child: widget.title)],
        ))));

    for (int i = 0; i < widget.items.length; i++) {
      if (widget.items[i].checklist == null || widget.items[i].index != i || widget.items[i].checklist.widget.index != widget.index || widget.items[i].checklist == this) {
        widget.items[i] = ChecklistItemView(
          onTapItem: widget.items[i].onTapItem,
          onStartDragItem: widget.items[i].onStartDragItem,
          onDropItem: widget.items[i].onDropItem,
          onChanged: widget.items[i].onChanged,
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
        widgets.add(widget.items[i]);
      }
    }

    if (widget.checklistState.checklistStates.length > widget.index) {
      widget.checklistState.checklistStates.removeAt(widget.index);
    }
    widget.checklistState.checklistStates.insert(widget.index, this);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }
}
