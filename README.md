# Flutter ChecklistView

## Getting Started

This package is a custom view that allows you to be able to re-order items in a list vertically. You can drag between lists, use it in a ScrollController (ListView,Column etc) and show and hide lists. To show Checkboxes pass in value to ChecklistItemView.

![Example](https://github.com/jakebonk/FlutterChecklistView/blob/master/images/example.gif?raw=true)

## Example

```
  List<ChecklistObject> items = [];

  @override
  void initState() {
    super.initState();
    items.add(ChecklistObject(title: "Title 1",items: []));
    items.add(ChecklistObject(title: "Title 2",items: [
      ChecklistItemObject(title: "Item 1"),
      ChecklistItemObject(title: "Item 2"),
      ChecklistItemObject(title: "Item 3"),
      ChecklistItemObject(title: "Item 4")
    ]));
  }

  @override
  Widget build(BuildContext context) {
    List<ChecklistView> checklistsViews = new List();
    for (var i = 0; i < items.length; i++) {
      List<ChecklistItemView> subItems = new List();
      for(var j = 0; j < items[i].items.length;j++){
        subItems.add(ChecklistItemView(title: Card(child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(items[i].items[j].title),
        )),
        canDrag:true,
        onDropItem: (oldListIndex,oldItemIndex,listIndex, itemIndex, state){
          //Update our local data
          setState(() {
            ChecklistItemObject object = items[oldListIndex].items[oldItemIndex];
            items[oldListIndex].items.removeAt(oldItemIndex);
            items[listIndex].items.insert(itemIndex, object);
          });
        },));
      }
      checklistsViews.add(ChecklistView(items: subItems,isOpen: items[i].isOpen,canDrag:true,onDropChecklist:(oldIndex,newIndex,state){
        //Update our local data
        setState(() {          
          ChecklistObject object = items[oldIndex];
          items.removeAt(oldIndex);
          items.insert(newIndex, object);
        });
      },title: Row(children: <Widget>[IconButton(icon: Icon(items[i].isOpen?Icons.arrow_drop_up:Icons.arrow_drop_down),onPressed: (){
        setState(() {
          items[i].isOpen = !items[i].isOpen;
        });
      },),Expanded(child: Text(items[i].title))],),));
    }
    return Scaffold(
      appBar: AppBar(),
        body: ChecklistListView(checklists: checklistsViews)
    );
  }
```
