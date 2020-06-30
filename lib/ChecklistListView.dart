import 'package:checklist/ChecklistView.dart';
import 'package:flutter/widgets.dart';

import 'checklist.dart';
import 'checklist.dart';

class ChecklistListView extends StatefulWidget {
  List<ChecklistView> checklists;
  double width;
  ScrollController controller;
  ScrollBottom scrollBottom;
  ScrollTop scrollTop;
  int checklistCount;
  ChecklistItemCount checklistItemCount;
  IndexedChecklistBuilder checklistBuilder;
  IndexedChecklistItemBuilder checklistItemBuilder;
  ChecklistListView({Key key, this.checklists, this.width, this.controller, this.scrollBottom, this.scrollTop}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChecklistListViewState();
  }
}

typedef int ChecklistItemCount(int index);
typedef ChecklistView IndexedChecklistBuilder(BuildContext context,int checklistIndex);
typedef ChecklistItemView IndexedChecklistItemBuilder(BuildContext context,int checklistIndex, int itemIndex);
typedef void OnDropListItem(int listIndex, int itemIndex);
typedef void OnDropList(int listIndex);
typedef double ScrollTop();
typedef double ScrollBottom();

class ChecklistListViewState extends State<ChecklistListView>  with AutomaticKeepAliveClientMixin{
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
  double startScroll;
  int oldListIndex;
  int oldItemIndex;

  double localPosition; //From Checklist Local position
  double bottomList;
  double topList;

  ScrollController checklistController = new ScrollController();

  List<ChecklistViewState> checklistStates = List<ChecklistViewState>();

  OnDropListItem onDropItem;
  OnDropList onDropList;

  bool checkStarted = true;

  @override
  void initState() {
    super.initState();
    if(widget.controller != null){
      checklistController = widget.controller;
    }
  }


  @override
  bool get wantKeepAlive => true;

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
        try {
          RenderBox box = checklistStates[draggedListIndex]
              .itemStates[draggedItemIndex]
              .context
              .findRenderObject();
          Offset itemPos = box.localToGlobal(Offset.zero);
          topItemY = itemPos.dy;
          bottomItemY = itemPos.dy + box.size.height;
        }catch(e){}
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
        try {
          RenderBox box = checklistStates[draggedListIndex]
              .itemStates[draggedItemIndex]
              .context
              .findRenderObject();
          Offset itemPos = box.localToGlobal(Offset.zero);
          topItemY = itemPos.dy;
          bottomItemY = itemPos.dy + box.size.height;
        }catch(e){}
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
        if(draggedListIndex != null && checklistStates[draggedListIndex].mounted) {
          RenderBox box =
          checklistStates[draggedListIndex].context.findRenderObject();
          Offset itemPos = box.localToGlobal(Offset.zero);
          topListY = itemPos.dy;
          bottomListY = itemPos.dy + box.size.height;
        }
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

  List<ChecklistView> checklists = new List();

  @override
  Widget build(BuildContext context) {
    List<Widget> stackWidgets = List();
    List<Widget> checklistWidgets = List();
    if(widget.checklists != null) {
      for (int i = 0; i < widget.checklists.length; i++) {
        if (widget.checklists[i].checklistState == null ||
            widget.checklists[i].index != i) {
          widget.checklists[i] = ChecklistView(
            onTapChecklist: widget.checklists[i].onTapChecklist,
            onStartDragChecklist: widget.checklists[i].onStartDragChecklist,
            onDropChecklist: widget.checklists[i].onDropChecklist,
            canDrag: widget.checklists[i].canDrag,
            items: widget.checklists[i].items,
            title: widget.checklists[i].title,
            footer: widget.checklists[i].footer,
            checklistState: this,
            backgroundColor: widget.checklists[i].backgroundColor,
            index: i,
            isOpen: widget.checklists[i].isOpen,
          );
        }
        checklistWidgets.add(Opacity(
            opacity: (draggedListIndex == i && draggedItemIndex == null)
                ? 0
                : 1,
            child: widget.checklists[i]));
      }
    }
    stackWidgets.add(Container(
        child: ListView(
          addAutomaticKeepAlives: true,
          cacheExtent: 2000,
          physics: NeverScrollableScrollPhysics(),
      controller: checklistController,
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

          double topPadding = checklistStates[draggedListIndex].headerHeight;
          double bottomPadding = 0;
          if(checklistStates[draggedListIndex].footerHeight != null){
            bottomPadding = checklistStates[draggedListIndex].footerHeight/2;
            topPadding += checklistStates[draggedListIndex].headerHeight-checklistStates[draggedListIndex].footerHeight/2;
          }


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
              0 <= draggedListIndex - 1 && checklistStates[draggedListIndex].headerHeight != null &&
              dy < topItemY - topPadding/2) {
            moveItemUpList();
          }
          if (widget.checklists[draggedListIndex].items.length >
                  draggedItemIndex + 1 && dy > bottomItemY + checklistStates[draggedListIndex].itemStates[draggedItemIndex].height/2) {
            //move down
            moveDown();
          } else if (widget.checklists[draggedListIndex].items.length <=
                  draggedItemIndex + 1 &&
              widget.checklists.length > draggedListIndex + 1 &&
              dy > bottomItemY + bottomPadding) {
            moveItemDownList();
          }
        } else {
          //dragging list
          if (0 <= draggedListIndex - 1 && localPosition != null && topList != null &&
              localPosition <
                  topList) {
            moveListUp();
          }
          if (checklistWidgets.length > draggedListIndex + 1 && localPosition != null && bottomList != null &&
              localPosition > bottomList) {
            moveListDown();
          }
        }

        if (dy < topChecklistY + 50) {
          //scroll up
          if (checklistController != null &&
              checklistController.hasClients &&
              !isScrolling) {
            isScrolling = true;
            double pos = checklistController.position.pixels;
            checklistController
                .animateTo(checklistController.position.pixels - 5,
                    duration: new Duration(milliseconds: 10),
                    curve: Curves.ease)
                .whenComplete(() {

              setState(() {
                pos -= checklistController.position.pixels;
                if(initialY == null)
                  initialY = 0;
                initialY -= pos;
                isScrolling = false;
                if(topItemY != null) {
                  topItemY += pos;
                }
                if(bottomItemY != null) {
                  bottomItemY += pos;
                }
                if(topListY != null) {
                  topListY += pos;
                }
                if(bottomListY != null){
                  bottomListY += pos;
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
            double pos = checklistController.position.pixels;
            checklistController
                .animateTo(checklistController.position.pixels + 5,
                    duration: new Duration(milliseconds: 10),
                    curve: Curves.ease)
                .whenComplete(() {
              setState(() {
                pos -= checklistController.position.pixels;
                if(initialY == null){
                  initialY = 0;
                }
                initialY -= pos;
                isScrolling = false;
                if(topItemY != null) {
                  topItemY += pos;
                }
                if(bottomItemY != null) {
                  bottomItemY += pos;
                }
                if(topListY != null){
                  topListY += pos;
                }
                if(bottomListY != null) {
                  bottomListY += pos;
                }
              });
            });
          }
        }
      }
      if(draggedListIndex != null) {
        localPosition = (dy - offsetY) + initialY; //From Checklist Local position
        bottomList = 0;
        topList = 0;
        for(var i = 0; i < checklistStates.length;i++){
          if(i <= draggedListIndex) {
            if(checklistStates[i]
                .mounted) {
              RenderBox box = checklistStates[i]
                  .context
                  .findRenderObject();
              bottomList += box.size.height;
              if (i < draggedListIndex - 1) {
                topList += box.size.height;
              } else if (i < draggedListIndex) {
                topList += box.size.height / 2;
              }
            }
          }
        }
        if(draggedListIndex < checklistStates.length){
          if(checklistStates[draggedListIndex].mounted) {
            RenderBox box = checklistStates[draggedListIndex]
                .context
                .findRenderObject();
            bottomList += box.size.height / 2;
          }
        }
      }else{
        localPosition = null;
        bottomList = null;
        topList = null;
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
                  if(pos < 0){
                    pos = 0;
                  }
                  widget.controller.jumpTo((pos > widget.controller.position.maxScrollExtent)?widget.controller.position.maxScrollExtent:pos);
                }
              }
            },
            onPointerDown: (opd) {
              if(mounted) {
                setState(() {
                  RenderBox box = context.findRenderObject();
                  Offset pos = box.localToGlobal(opd.position);
                  if (widget.scrollTop != null && widget.scrollBottom != null) {
                    topChecklistY = widget.scrollTop();
                    bottomChecklistY = widget.scrollBottom();
                  } else {
                    Offset spawn = box.localToGlobal(Offset.zero);
                    topChecklistY = spawn.dy;
                    bottomChecklistY = spawn.dy + box.size.height;
                  }
                  offsetX = pos.dx;
                  offsetY = pos.dy;
                  if (widget.controller != null && widget.controller.hasClients){
                    startScroll = widget.controller.position.pixels;
                  }
                  pointer = opd;
                });
              }
            },
            onPointerUp: (opu) {
              if(mounted) {
                setState(() {
                  if (onDropItem != null && draggedItemIndex != null) {
                    onDropItem(draggedListIndex, draggedItemIndex);
                  }
                  if (onDropList != null && draggedListIndex != null &&
                      draggedItemIndex == null) {
                    onDropList(draggedListIndex);
                  }
                  if (draggedItem == null && delta != null) {
                    widget.controller.animateTo(
                        widget.controller.position.pixels - delta * 20,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOut);
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
                  bottomList = null;
                  topList = null;
                  oldListIndex = null;
                  oldItemIndex = null;
                });
              }
            },
            child: new Stack(
              overflow: Overflow.visible,
              children: stackWidgets,
            )));
  }

  var pointer;

  void run() {
    if (pointer != null) {
      setState(() {
        dx = pointer.position.dx;
        dy = pointer.position.dy;
      });
    }
  }
}
