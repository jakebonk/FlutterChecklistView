library checklist;

import 'package:checklist/checklist_view.dart';
import 'package:flutter/widgets.dart';
export 'package:checklist/checklist_view.dart';

/// A Calculator.
class Checklist extends StatefulWidget {
  final List<ChecklistView> checklists;
  final double width;
  final ScrollController controller;

  const Checklist({Key key, this.checklists, this.width, this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChecklistState();
  }
}

typedef void OnDropItem(int listIndex, int itemIndex);
typedef void OnDropList(int listIndex);

class ChecklistState extends State<Checklist> {
  Widget draggedItem;
  int draggedItemIndex;
  int draggedListIndex;
  double dx;
  double dxInit;
  double dyInit;
  double dy;
  double offsetX;
  double offsetY;
  double initialX = 0;
  double initialY = 0;
  double topListY;
  double bottomListY;
  double topItemY;
  double bottomItemY;
  double height;
  bool canDrag = true;
  bool isScrolling = false;
  double delta;
  double topChecklistY;
  double bottomChecklistY;

  int oldListIndex;
  int oldItemIndex;

  ScrollController checklistController = new ScrollController();

  List<ChecklistViewState> checklistStates = List<ChecklistViewState>();

  OnDropItem onDropItem;
  OnDropList onDropList;


  @override
  void initState() {
    super.initState();
    if(widget.controller != null){
      checklistController = widget.controller;
    }
  }

  void moveUp() {
    checklistStates[draggedListIndex].setState(() {
      topItemY -= checklistStates[draggedListIndex]
          .itemStates[draggedItemIndex - 1]
          .height;
      bottomItemY -= checklistStates[draggedListIndex]
          .itemStates[draggedItemIndex - 1]
          .height;
      var item = widget.checklists[draggedListIndex].items[draggedItemIndex];
      widget.checklists[draggedListIndex].items.removeAt(draggedItemIndex);
      var itemState =
          checklistStates[draggedListIndex].itemStates[draggedItemIndex];
      checklistStates[draggedListIndex].itemStates.removeAt(draggedItemIndex);
      widget.checklists[draggedListIndex].items
          .insert(--draggedItemIndex, item);
      checklistStates[draggedListIndex]
          .itemStates
          .insert(draggedItemIndex, itemState);
    });
  }

  void moveDown() {
    checklistStates[draggedListIndex].setState(() {
      topItemY += checklistStates[draggedListIndex]
          .itemStates[draggedItemIndex + 1]
          .height;
      bottomItemY += checklistStates[draggedListIndex]
          .itemStates[draggedItemIndex + 1]
          .height;
      var item = widget.checklists[draggedListIndex].items[draggedItemIndex];
      widget.checklists[draggedListIndex].items.removeAt(draggedItemIndex);
      var itemState =
          checklistStates[draggedListIndex].itemStates[draggedItemIndex];
      checklistStates[draggedListIndex].itemStates.removeAt(draggedItemIndex);
      widget.checklists[draggedListIndex].items
          .insert(++draggedItemIndex, item);
      checklistStates[draggedListIndex]
          .itemStates
          .insert(draggedItemIndex, itemState);
    });
  }

  void moveItemDownList() {
    setState(() {
      canDrag = false;
      ChecklistItemView item =
          widget.checklists[draggedListIndex].items[draggedItemIndex];
      ChecklistItemViewState itemState =
          checklistStates[draggedListIndex].itemStates[draggedItemIndex];
      checklistStates[draggedListIndex].setState(() {
        widget.checklists[draggedListIndex].items.removeAt(draggedItemIndex);
        checklistStates[draggedListIndex].itemStates.removeAt(draggedItemIndex);
      });
      draggedListIndex++;
      draggedItemIndex = 0;
      itemState.setState(() {
        checklistStates[draggedListIndex].setState(() {
          widget.checklists[draggedListIndex].items
              .insert(draggedItemIndex, item);
          checklistStates[draggedListIndex]
              .itemStates
              .insert(draggedItemIndex, itemState);
        });
      });
      Future.delayed(Duration(milliseconds: 50), () {
        canDrag = true;
        RenderBox box = checklistStates[draggedListIndex]
            .itemStates[draggedItemIndex]
            .context
            .findRenderObject();
        Offset itemPos = box.localToGlobal(Offset.zero);
        topItemY = itemPos.dy;
        bottomItemY = itemPos.dy + box.size.height;
      });
    });
  }

  void moveItemUpList() {
    setState(() {
      canDrag = false;
      ChecklistItemView item =
          widget.checklists[draggedListIndex].items[draggedItemIndex];
      ChecklistItemViewState itemState =
          checklistStates[draggedListIndex].itemStates[draggedItemIndex];
      checklistStates[draggedListIndex].setState(() {
        widget.checklists[draggedListIndex].items.removeAt(draggedItemIndex);
        checklistStates[draggedListIndex].itemStates.removeAt(draggedItemIndex);
      });
      draggedListIndex--;
      draggedItemIndex = widget.checklists[draggedListIndex].items.length;
      itemState.setState(() {
        checklistStates[draggedListIndex].setState(() {
          widget.checklists[draggedListIndex].items
              .insert(draggedItemIndex, item);
          checklistStates[draggedListIndex]
              .itemStates
              .insert(draggedItemIndex, itemState);
        });
      });
      Future.delayed(Duration(milliseconds: 5), () {
        canDrag = true;
        RenderBox box = checklistStates[draggedListIndex]
            .itemStates[draggedItemIndex]
            .context
            .findRenderObject();
        Offset itemPos = box.localToGlobal(Offset.zero);
        topItemY = itemPos.dy;
        bottomItemY = itemPos.dy + box.size.height;
      });
    });
  }

  void moveListUp() async {
    setState(() {
      var checklistState = checklistStates[draggedListIndex];
      widget.checklists.removeAt(draggedListIndex);
      checklistStates.removeAt(draggedListIndex);
      draggedListIndex--;
      widget.checklists.insert(draggedListIndex, checklistState.widget);
      checklistStates.insert(draggedListIndex, checklistState);
      canDrag = false;
      waitForSync();
    });
  }

  void waitForSync() async {
    _checkIndex().then((val) {
      setState(() {
        RenderBox box =
            checklistStates[draggedListIndex].context.findRenderObject();
        Offset itemPos = box.localToGlobal(Offset.zero);
        topListY = itemPos.dy;
        bottomListY = itemPos.dy + box.size.height;
        canDrag = true;
      });
    });
  }

  Future<bool> _checkIndex() async {
    if (draggedListIndex != checklistStates[draggedListIndex].widget.index) {
      return Future.delayed(Duration(milliseconds: 5), () {
        return _checkIndex();
      });
    } else {
      return true;
    }
  }

  void moveListDown() {
    setState(() {
      var checklistState = checklistStates[draggedListIndex];
      widget.checklists.removeAt(draggedListIndex);
      checklistStates.removeAt(draggedListIndex);
      draggedListIndex++;
      widget.checklists.insert(draggedListIndex, checklistState.widget);
      checklistStates.insert(draggedListIndex, checklistState);
      canDrag = false;
      waitForSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackWidgets = List();
    List<Widget> checklistWidgets = List();
    for (int i = 0; i < widget.checklists.length; i++) {
      if (widget.checklists[i].checklistState == null ||
          widget.checklists[i].index != i) {
        widget.checklists[i] = ChecklistView(
          onTapChecklist: widget.checklists[i].onTapChecklist,
          onStartDragChecklist: widget.checklists[i].onStartDragChecklist,
          onDropChecklist: widget.checklists[i].onDropChecklist,
          items: widget.checklists[i].items,
          title: widget.checklists[i].title,
          checklistState: this,
          backgroundColor: widget.checklists[i].backgroundColor,
          index: i,
        );
      }
      checklistWidgets.add(Opacity(
          opacity: (draggedListIndex == i && draggedItemIndex == null) ? 0 : 1,
          child: widget.checklists[i]));
    }
    stackWidgets.add(Container(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
      controller: (widget.controller != null)?null:checklistController,
      shrinkWrap: true,
      children: checklistWidgets,
        )));
    if (initialX != null &&
        initialY != null &&
        offsetX != null &&
        offsetY != null &&
        dx != null &&
        dy != null &&
        height != null) {
      if (canDrag && dxInit != null && dyInit != null) {
        if (draggedItemIndex != null && draggedItem != null) {
          //dragging item
          if (0 <= draggedItemIndex - 1 &&
              dy <
                  topItemY -
                      checklistStates[draggedListIndex]
                              .itemStates[draggedItemIndex - 1]
                              .height /
                          2) {
            //move up
            moveUp();
          } else if (0 > draggedItemIndex - 1 &&
              0 <= draggedListIndex - 1 &&
              dy < topItemY) {
            moveItemUpList();
          }
          if (widget.checklists[draggedListIndex].items.length >
                  draggedItemIndex + 1 &&
              dy >
                  bottomItemY +
                      checklistStates[draggedListIndex]
                              .itemStates[draggedItemIndex + 1]
                              .height /
                          2) {
            //move down
            moveDown();
          } else if (widget.checklists[draggedListIndex].items.length <=
                  draggedItemIndex + 1 &&
              widget.checklists.length > draggedListIndex + 1 &&
              dy > bottomItemY) {
            moveItemDownList();
          }
        } else {
          //dragging list
          if (0 <= draggedListIndex - 1 &&
              dy <
                  topListY - checklistStates[draggedListIndex - 1].height / 2) {
            moveListUp();
          }
          if (checklistWidgets.length > draggedListIndex + 1 &&
              dy >
                  bottomListY +
                      checklistStates[draggedListIndex + 1].height / 2) {
            moveListDown();
          }
        }
        if (dy < topChecklistY + 50) {
          //scroll up
          if (checklistController != null &&
              checklistController.hasClients &&
              !isScrolling) {
            isScrolling = true;
            checklistController
                .animateTo(checklistController.position.pixels - 5,
                    duration: new Duration(milliseconds: 10),
                    curve: Curves.ease)
                .whenComplete(() {
              setState(() {
                isScrolling = false;
                if (draggedListIndex != null) {
                  if (draggedItemIndex != null) {
                    RenderBox box = checklistStates[draggedListIndex]
                        .itemStates[draggedItemIndex]
                        .context
                        .findRenderObject();
                    Offset itemPos = box.localToGlobal(Offset.zero);
                    topItemY = itemPos.dy;
                    bottomItemY = itemPos.dy + box.size.height;
                  }
                  RenderBox box = checklistStates[draggedListIndex]
                      .context
                      .findRenderObject();
                  Offset itemPos = box.localToGlobal(Offset.zero);
                  topListY = itemPos.dy;
                  bottomListY = itemPos.dy + box.size.height;
                }
              });
            });
          }
        }
        if (dy > bottomChecklistY - 50) {
          //scroll down
          if (checklistController != null &&
              checklistController.hasClients &&
              !isScrolling) {
            isScrolling = true;
            checklistController
                .animateTo(checklistController.position.pixels + 5,
                    duration: new Duration(milliseconds: 10),
                    curve: Curves.ease)
                .whenComplete(() {
              setState(() {
                isScrolling = false;
                if (draggedListIndex != null) {
                  if (draggedItemIndex != null) {
                    RenderBox box = checklistStates[draggedListIndex]
                        .itemStates[draggedItemIndex]
                        .context
                        .findRenderObject();
                    Offset itemPos = box.localToGlobal(Offset.zero);
                    topItemY = itemPos.dy;
                    bottomItemY = itemPos.dy + box.size.height;
                  }
                  RenderBox box = checklistStates[draggedListIndex]
                      .context
                      .findRenderObject();
                  Offset itemPos = box.localToGlobal(Offset.zero);
                  topListY = itemPos.dy;
                  bottomListY = itemPos.dy + box.size.height;
                }
              });
            });
          }
        }
      }
      if (draggedItem != null) {
        stackWidgets.add(Positioned(
          height: height,
          child: draggedItem,
          left: 0,
          right: 0,
          top: (dy - offsetY) + initialY,
        ));
      }
    }
    return Container(
        width: widget.width,
        child: Listener(
            onPointerMove: (opm) {

              if (draggedItem != null) {
                setState(() {
                  if (dxInit == null) {
                    dxInit = opm.position.dx;
                  }
                  if (dyInit == null) {
                    dyInit = opm.position.dy;
                  }
                  dx = opm.position.dx;
                  dy = opm.position.dy;
                });
              }else{
                if(widget.controller != null){
                  double pos = widget.controller.position.pixels-opm.delta.dy;
                  delta = opm.delta.dy;
                  widget.controller.jumpTo((pos > widget.controller.position.maxScrollExtent)?widget.controller.position.maxScrollExtent:pos);
                }
              }
            },
            onPointerDown: (opd) {
              setState(() {
                RenderBox box = context.findRenderObject();
                Offset pos = box.localToGlobal(opd.position);
                Offset spawn = box.localToGlobal(Offset.zero);
                topChecklistY = spawn.dy;
                bottomChecklistY = spawn.dy + box.size.height;
                offsetX = pos.dx;
                offsetY = pos.dy;
              });
            },
            onPointerUp: (opu) {
              setState(() {
                if (onDropItem != null && draggedItemIndex != null) {
                  onDropItem(draggedListIndex, draggedItemIndex);
                }
                if(onDropList != null && draggedListIndex != null && draggedItemIndex == null){
                  onDropList(draggedListIndex);
                }
                if(draggedItem == null && delta != null){
                  widget.controller.animateTo(widget.controller.position.pixels-delta*20, duration: Duration(milliseconds: 500), curve: Curves.easeOut);
                }
                delta = null;
                draggedItem = null;
                offsetX = null;
                offsetY = null;
                initialX = null;
                initialY = null;
                dx = null;
                dy = null;
                draggedItemIndex = null;
                draggedListIndex = null;
                dxInit = null;
                dyInit = null;
                topListY = null;
                bottomListY = null;
                topItemY = null;
                bottomItemY = null;
                oldListIndex = null;
                oldItemIndex = null;
              });
            },
            child: new Stack(
              overflow: Overflow.visible,
              children: stackWidgets,
            )));
  }
}
