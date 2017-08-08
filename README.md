virtual-scroll for AngularDart
==============================


## Description

This component scrolls the large list in the browser.

I referred to the TypeScript version.<br>
https://github.com/rintoj/angular2-virtual-scroll

(But, my virtual-scroll is reduction version 😣)

## Demo

Live demo.<br>
https://takutaro.github.io/angular-virtual-scroll-demo/build/web/

## Requirement

* Dart >= 1.24
* AngularDart >= 4.0.0-alpha+1"
* Modern browser

## Usage

See the following sample code.<br>
https://github.com/takutaro/angular-virtual-scroll-demo/

Surround the content you want to scroll with the \<virtual-scroll\> tag.
* Specify your large list to [items].
* Prepare a partial list. This list is set by (update).
* Specify width and height with style.

```html
<virtual-scroll [items]="items" (update)="viewPortItems=\$event" style="width:auto; height:75vh;">
    <div *ngFor="let item of viewPortItems;">
        {{item.name}} Hello.
    </div>
</virtual-scroll>
```
Import the required package.

```Dart
import 'package:angular/angular.dart';
import 'package:virtual_scroll/virtual-scroll.dart';
```

Angular component:

```Dart
@Component(...)
class AppComponent {

  List<Item> items = []; // large list.
  var viewPortItems; // partial list.

  AppComponent() {
    for (int i = 0; i < 10000; i++)
      this.items.add(new Item());
  }
  add() {
    this.items.add(new Item());
    this.items = this.items.toList(); // Make new list to detect changes.
  }
}
```

## Author

takutaro.

## License

The MIT License (MIT).