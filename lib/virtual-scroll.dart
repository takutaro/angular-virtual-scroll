library virtual_scroll;

import 'dart:async';
import 'dart:html';
import 'dart:math' as Math;
import 'package:angular2/core.dart';

@Component(
  selector: 'virtual-scroll',
  styles: const ['''
    :host {
      overflow: hidden;
      overflow-y: auto;
      position: relative;
      display: block;
    }
    .total-padding {
      width: 1px;
      opacity: 0;
    }
    .scrollable-content {
      top: 0;
      left: 0;
      width: 10000px;
      height: 100%;
      position: absolute;
      -webkit-overflow-scrolling: touch;
    }
  '''],
  template: '''
    <div class="total-padding" #padding  tabindex="-1" [style.height]="scrollHeight.toString() + 'px'"></div>
    <div class="scrollable-content" #content [style.transform]="'translateY(' + topPadding.toString() + 'px)'">
      <ng-content></ng-content>
    </div>
  ''',
)
class VirtualScrollComponent implements OnInit, OnChanges {

  @Input() List items = [];
  @Input() int chgTrigger = 0;

  final StreamController<List> _update$ = new StreamController<List>();
  @Output() Stream<List> get update => this._update$.stream;

  @ViewChild('padding') ElementRef paddingElementRef;
  @ViewChild('content') ElementRef contentElementRef;

  int topPadding = 0;
  int scrollHeight = 0;

  int _itemHeight = 1;
  int _previousStart;
  int _previousEnd;
  bool _startup = true;

  ElementRef _element;
  VirtualScrollComponent(this._element) {}

  ngOnInit() {
    window.onResize.listen(this._onResize);
  }
  ngOnChanges(Map<String, SimpleChange> changes) {
    this._itemHeight = 1;
    this._previousStart = this._previousEnd = null;
    this._startup = true;
    this._refresh();
  }

  @HostListener('scroll')
  onScroll() {
    this._refresh();
  }
  _onResize(Event e) {
    this._refresh();
  }
  _refresh() {
    window.requestAnimationFrame((num tick) {
      HtmlElement content = this.contentElementRef.nativeElement;
      if (content?.children?.length > 0 && this._itemHeight == 1) {
        this._itemHeight = Math.max(content.children.first.clientHeight, content.children.first.offsetHeight);
        this._itemHeight = Math.max(this._itemHeight, content.children.first.scrollHeight);
      }
      this.scrollHeight = this.items.length * this._itemHeight;

      HtmlElement el = this._element.nativeElement;
      int itemsPerView = Math.max(1, (el.clientHeight / this._itemHeight).ceil());
      double topItemIndex = this.items.length * el.scrollTop / this.scrollHeight;
      int end = Math.min(topItemIndex.ceil() + itemsPerView + 1, this.items.length);
      int maxStart = Math.max(0, end - itemsPerView - 1);
      int start = Math.min(maxStart, topItemIndex.floor());
      this.topPadding = this._itemHeight * start;

      if (start != this._previousStart || end != this._previousEnd) {
        this._update$.add(this.items.sublist(start, end)); // (update)="yourViewPortItems=\$event"
        this._previousStart = start;
        this._previousEnd = end;
        if (this._startup) {
          this._startup = false;
          this._refresh(); // To scroll smoothly at the first time.
        }
        this.paddingElementRef.nativeElement.focus();
      }
    });
  }
}