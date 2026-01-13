import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'liquid_bottom_bar.dart';

class LiquidGlassShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<LiquidTabItem> items;

  const LiquidGlassShell({
    super.key,
    required this.navigationShell,
    required this.items,
  });

  @override
  State<LiquidGlassShell> createState() => _LiquidGlassShellState();
}

class _LiquidGlassShellState extends State<LiquidGlassShell> {
  late PageController _pageController;
  bool _isDragging = false;
  double _lastDragPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.navigationShell.currentIndex);
  }

  @override
  void didUpdateWidget(LiquidGlassShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.navigationShell.currentIndex != oldWidget.navigationShell.currentIndex && !_isDragging) {
      _pageController.animateToPage(
        widget.navigationShell.currentIndex,
        duration: const Duration(milliseconds: 600),
        curve: const Cubic(0.2, 0.0, 0.0, 1.0),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    _lastDragPosition = details.globalPosition.dx;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_pageController.hasClients) return;
    
    final double currentPosition = details.globalPosition.dx;
    final double delta = currentPosition - _lastDragPosition;
    _lastDragPosition = currentPosition;
    
    // Sensitivity: how much the drag on the bar translates to page movement
    // Since the bar is smaller than the screen, we need a multiplier to cover all tabs
    final double moveRatio = 3.0; 
    
    final double newOffset = _pageController.offset + (delta * moveRatio);
    _pageController.jumpTo(newOffset.clamp(
      0.0, 
      _pageController.position.maxScrollExtent,
    ));
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    final int currentPage = _pageController.page?.round() ?? 0;
    
    // Animate to the final snapped page
    _pageController.animateToPage(
      currentPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
    
    if (currentPage != widget.navigationShell.currentIndex) {
      widget.navigationShell.goBranch(currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        double pageValue = 0.0;
        if (_pageController.hasClients && _pageController.position.hasContentDimensions) {
          pageValue = _pageController.page ?? widget.navigationShell.currentIndex.toDouble();
        } else {
          pageValue = widget.navigationShell.currentIndex.toDouble();
        }

        return Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification) {
                    if (notification.dragDetails != null) _isDragging = true;
                  } else if (notification is ScrollEndNotification) {
                    _isDragging = false;
                    final int currentPage = _pageController.page?.round() ?? 0;
                    if (currentPage != widget.navigationShell.currentIndex) {
                      widget.navigationShell.goBranch(currentPage);
                    }
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.items.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    if (_isDragging) {
                      widget.navigationShell.goBranch(index);
                    }
                  },
                  itemBuilder: (context, index) {
                    final double pageOffset = pageValue - index;
                    final double absOffset = pageOffset.abs();
                    
                    // Premium transition logic: Liquid scale + fade
                    final double scale = 1.0 - (absOffset * 0.12).clamp(0.0, 0.12);
                    final double opacity = 1.0 - (absOffset).clamp(0.0, 1.0);
                    final double translation = pageOffset * 60.w;

                    return Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(translation, 0),
                        child: Transform.scale(
                          scale: scale,
                          child: index == widget.navigationShell.currentIndex 
                              ? widget.navigationShell 
                              : const SizedBox.shrink(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: LiquidBottomBar(
            pageOffset: pageValue,
            onItemSelected: (index) {
              widget.navigationShell.goBranch(index);
            },
            onHorizontalDragStart: _handleDragStart,
            onHorizontalDragUpdate: _handleDragUpdate,
            onHorizontalDragEnd: _handleDragEnd,
            items: widget.items,
          ),
        );
      },
    );
  }
}
