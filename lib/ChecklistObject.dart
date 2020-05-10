import 'ChecklistItemObject.dart';

class ChecklistObject {
  bool isOpen = true;
  String title = "";
  List<ChecklistItemObject> items = [];
  ChecklistObject({this.title,this.items});
}