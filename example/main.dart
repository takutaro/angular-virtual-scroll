import 'dart:async';

import 'package:angular/angular.dart';
import "package:virtual_scroll/virtual_scroll.dart";
import 'main.template.dart' as ng;

Future<Null> main() async {
  runApp(ng.AppComponentNgFactory);
}

@Component(
  selector: "demo-app",
  template: '''
  <virtual-scroll [items]="items" (update)="viewPortItems=\$event" style="width:auto; height:75vh;">
    <div *ngFor="let item of viewPortItems;">
        {{item.name}} Hello.
    </div>
</virtual-scroll>
<button (click)="add()">ADD</button>
  ''',
  directives: const [VirtualScrollComponent, NgFor],
)
class AppComponent {
  List<Item> items = []; // large list.
  List<Item> viewPortItems; // partial list.

  AppComponent() {
    for (int i = 0; i < 10000; i++) items.add(new Item("Robot $i"));
  }
  void add() {
    items.add(new Item("New Robot"));
    items = items.toList(); // Make new list to detect changes.
  }
}

class Item {
  final String name;
  Item(this.name);
}
