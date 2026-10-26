import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const _timeWidth = 96.0;

/// Weather's intrinsic table with its actual Local time cells pinned to the
/// leading edge. One layout owns row heights, text, hit tests and semantics.
class WeatherDetailsTable extends StatefulWidget {
  const WeatherDetailsTable({
    super.key,
    required this.rows,
    required this.background,
  });

  final List<TableRow> rows;
  final Color background;

  @override
  State<WeatherDetailsTable> createState() => _WeatherDetailsTableState();
}

class _WeatherDetailsTableState extends State<WeatherDetailsTable> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: const Key('weather.table'),
    scrollDirection: Axis.horizontal,
    controller: _scroll,
    child: _TimeTable(
      children: widget.rows,
      scroll: _scroll,
      background: widget.background,
    ),
  );
}

class _TimeTable extends Table {
  _TimeTable({
    required super.children,
    required this.scroll,
    required this.background,
  }) : super(
         columnWidths: const {0: FixedColumnWidth(_timeWidth)},
         defaultColumnWidth: const IntrinsicColumnWidth(),
       );

  final ScrollController scroll;
  final Color background;

  @override
  RenderTable createRenderObject(BuildContext context) => _TimeTableRender(
    scroll,
    background,
    columns: children.isEmpty ? 0 : children.first.children.length,
    rows: children.length,
    columnWidths: columnWidths,
    defaultColumnWidth: defaultColumnWidth,
    textDirection: Directionality.of(context),
    rowDecorations: children.map((row) => row.decoration).toList(),
    configuration: createLocalImageConfiguration(context),
  );

  @override
  void updateRenderObject(BuildContext context, RenderTable renderObject) {
    super.updateRenderObject(context, renderObject);
    (renderObject as _TimeTableRender)
      ..scroll = scroll
      ..background = background;
  }
}

class _TimeTableRender extends RenderTable {
  _TimeTableRender(
    this._scroll,
    this._background, {
    required super.columns,
    required super.rows,
    required super.columnWidths,
    required super.defaultColumnWidth,
    required super.textDirection,
    required super.rowDecorations,
    required super.configuration,
  });

  final _painters = <Decoration, BoxPainter>{};
  ScrollController _scroll;
  Color _background;

  set scroll(ScrollController value) {
    if (identical(value, _scroll)) return;
    if (attached) _scroll.removeListener(_scrolled);
    _scroll = value;
    if (attached) _scroll.addListener(_scrolled);
    _scrolled();
  }

  set background(Color value) {
    if (value == _background) return;
    _background = value;
    markNeedsPaint();
  }

  void _scrolled() {
    markNeedsPaint();
    markNeedsSemanticsUpdate();
    visitChildren((child) => child.markNeedsSemanticsUpdate());
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..isSemanticBoundary = true
      ..explicitChildNodes = true;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scroll.addListener(_scrolled);
  }

  @override
  void detach() {
    _scroll.removeListener(_scrolled);
    super.detach();
  }

  @override
  void dispose() {
    for (final painter in _painters.values) {
      painter.dispose();
    }
    super.dispose();
  }

  double get _shift =>
      (_scroll.hasClients ? _scroll.offset : 0) *
      (textDirection == TextDirection.ltr ? 1 : -1);

  Rect get _timeRect => Rect.fromLTWH(
    (textDirection == TextDirection.ltr ? 0 : size.width - _timeWidth) + _shift,
    0,
    _timeWidth,
    size.height,
  );

  Rect get _metricsRect => textDirection == TextDirection.ltr
      ? Rect.fromLTRB(_timeRect.right, 0, size.width, size.height)
      : Rect.fromLTRB(0, 0, _timeRect.left, size.height);

  bool _isTime(RenderObject child) =>
      (child.parentData! as TableCellParentData).x == 0;

  List<RenderBox> get _cells {
    final cells = <RenderBox>[];
    visitChildren((child) => cells.add(child as RenderBox));
    return cells;
  }

  void _paintRows(PaintingContext context, Offset offset) {
    final decorations = rowDecorations;
    for (var row = 0; row < rows; row++) {
      final decoration = row < decorations.length ? decorations[row] : null;
      if (decoration == null) continue;
      final rect = getRowBox(row);
      _painters
          .putIfAbsent(
            decoration,
            () => decoration.createBoxPainter(markNeedsPaint),
          )
          .paint(
            context.canvas,
            offset + rect.topLeft,
            configuration.copyWith(size: rect.size),
          );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (rows == 0 || columns == 0) return;
    for (final old
        in _painters.keys.where((d) => !rowDecorations.contains(d)).toList()) {
      _painters.remove(old)!.dispose();
    }
    _paintRows(context, offset);
    final cells = _cells;
    context.pushClipRect(needsCompositing, offset, _metricsRect, (
      context,
      offset,
    ) {
      for (final child in cells.where((child) => !_isTime(child))) {
        context.paintChild(
          child,
          offset + (child.parentData! as BoxParentData).offset,
        );
      }
    });
    context.pushClipRect(needsCompositing, offset, _timeRect, (
      context,
      offset,
    ) {
      context.canvas.drawRect(
        _timeRect.shift(offset),
        Paint()..color = _background,
      );
      _paintRows(context, offset);
      for (final child in cells.where(_isTime)) {
        context.paintChild(
          child,
          offset +
              (child.parentData! as BoxParentData).offset +
              Offset(_shift, 0),
        );
      }
    });
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    super.applyPaintTransform(child, transform);
    if (_isTime(child)) transform.translateByDouble(_shift, 0, 0, 1);
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) =>
      _isTime(child) ? _timeRect : _metricsRect;

  @override
  Rect? describeSemanticsClip(RenderObject? child) =>
      child == null ? null : describeApproximatePaintClip(child);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final time = _timeRect.contains(position);
    for (final child in _cells.reversed.where(
      (child) => _isTime(child) == time,
    )) {
      final offset =
          (child.parentData! as BoxParentData).offset +
          (time ? Offset(_shift, 0) : Offset.zero);
      if (result.addWithPaintOffset(
        offset: offset,
        position: position,
        hitTest: (result, point) => child.hitTest(result, position: point),
      )) {
        return true;
      }
    }
    return false;
  }

  @override
  void showOnScreen({
    RenderObject? descendant,
    Rect? rect,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
  }) {
    RenderObject? cell = descendant;
    while (cell != null && cell.parent != this) {
      cell = cell.parent;
    }
    if (cell != null && !_isTime(cell)) {
      final target = MatrixUtils.transformRect(
        descendant!.getTransformTo(this),
        rect ?? descendant.paintBounds,
      );
      final reveal = textDirection == TextDirection.ltr
          ? Rect.fromLTRB(
              target.left - _timeWidth,
              target.top,
              target.right,
              target.bottom,
            )
          : Rect.fromLTRB(
              target.left,
              target.top,
              target.right + _timeWidth,
              target.bottom,
            );
      super.showOnScreen(
        descendant: this,
        rect: reveal,
        duration: duration,
        curve: curve,
      );
    } else {
      super.showOnScreen(
        descendant: descendant,
        rect: rect,
        duration: duration,
        curve: curve,
      );
    }
  }
}
