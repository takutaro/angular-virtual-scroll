library virtual_scroll.core;

import 'dart:async';
import 'dart:html';
import 'dart:math' as Math;
import 'package:angular/angular.dart';

@Component(
  selector: 'virtual-scroll',
  styleUrls: const ["virtual_scroll.css"],
  templateUrl: "virtual_scroll.html",
)
class VirtualScrollComponent implements OnInit, OnDestroy {
  final _update = new StreamController<List>();
  StreamSubscription<Event> _resizeSubscription;
  StreamSubscription<Event> _scrollSubscription;

  List _items = [];
  List get items => _items;

  @Input()
  set items(List values) {
    _items = values;
    _itemHeight = 1;
    _previousStart = _previousEnd = null;
    _startup = true;
    _refresh();
  }

  @Output()
  Stream<List> get update => _update.stream;

  @ViewChild('padding')
  ElementRef paddingElementRef;

  @ViewChild('content')
  ElementRef contentElementRef;

  int topPadding = 0;
  int scrollHeight = 0;

  int _itemHeight = 1;
  int _previousStart;
  int _previousEnd;
  bool _startup = true;

  final HtmlElement el;

  VirtualScrollComponent(this.el);

  void ngOnInit() {
    _resizeSubscription = el.onResize.listen((_) => _refresh());
    _scrollSubscription = el.onScroll.listen((_) => _refresh());
  }

  void ngOnDestroy() {
    _update.close();
    _resizeSubscription?.cancel();
    _scrollSubscription?.cancel();
  }

  void _refresh() {
    window.requestAnimationFrame((num tick) {
      if (items == null) return;
      final content = contentElementRef.nativeElement;
      if (content?.children?.length > 0 && _itemHeight == 1) {
        _itemHeight = Math.max(content.children.first.clientHeight,
            content.children.first.offsetHeight);
        _itemHeight =
            Math.max(_itemHeight, content.children.first.scrollHeight);
      }
      scrollHeight = items.length * _itemHeight;

      final itemsPerView = Math.max(1, (el.clientHeight / _itemHeight).ceil());
      final topItemIndex = items.length * el.scrollTop / scrollHeight;
      final end =
          Math.min(topItemIndex.ceil() + itemsPerView + 1, items.length);
      final maxStart = Math.max(0, end - itemsPerView - 1);
      final start = Math.min(maxStart, topItemIndex.floor());
      topPadding = _itemHeight * start;

      if (start != _previousStart || end != _previousEnd) {
        _update.add(this
            .items
            .sublist(start, end)); // (update)="yourViewPortItems=\$event"
        _previousStart = start;
        _previousEnd = end;
        if (_startup) {
          _startup = false;
          _refresh(); // To scroll smoothly at the first time.
        }
        paddingElementRef.nativeElement.focus();
      }
    });
  }
}
