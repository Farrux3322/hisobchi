import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'liquid_bottom_bar.dart';
import 'package:hisobchi/application/subscription/subscription_status_cubit.dart';
import 'package:hisobchi/domain/common/enums/subscription_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/presentation/components/subscription/subscription_blocked_view.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';

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

class _LiquidGlassShellState extends State<LiquidGlassShell> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late double _pageValue;
  bool _isDragging = false;
  double _lastDragPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _pageValue = widget.navigationShell.currentIndex.toDouble();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(() {
      setState(() {
        _pageValue = _animationController.value * (widget.items.length - 1);
      });
    });
  }

  @override
  void didUpdateWidget(LiquidGlassShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.navigationShell.currentIndex != oldWidget.navigationShell.currentIndex && !_isDragging) {
      _animationController.animateTo(
        widget.navigationShell.currentIndex / (widget.items.length - 1),
        curve: const Cubic(0.2, 0.0, 0.0, 1.0),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    _lastDragPosition = details.globalPosition.dx;
    _animationController.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final double currentPosition = details.globalPosition.dx;
    final double delta = currentPosition - _lastDragPosition;
    _lastDragPosition = currentPosition;
    
    // Calculate move ratio based on bar width vs total pages
    final double barWidth = MediaQuery.of(context).size.width - 40.w;
    final double widthPerTab = barWidth / widget.items.length;
    final double normalizedDelta = delta / widthPerTab;
    
    setState(() {
      _pageValue = (_pageValue + normalizedDelta).clamp(0.0, widget.items.length - 1.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    final int targetPage = _pageValue.round();
    
    // Animate indicator to the final snapped tab
    _animationController.value = _pageValue / (widget.items.length - 1);
    _animationController.animateTo(
      targetPage / (widget.items.length - 1),
      curve: Curves.easeOutCubic,
    );
    
    // ONLY switch branch on release to ensure comfort and state preservation
    if (targetPage != widget.navigationShell.currentIndex) {
      widget.navigationShell.goBranch(targetPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionStatusCubit, SubscriptionStatus>(
      builder: (context, status) {
        if (status.isDeleted) {
          return SubscriptionBlockedView(
            title: 'Hisobingiz o‘chirildi',
            message: 'Afsuski, sizning hisobingiz o‘chirilgan. Iltimos, ma’lumot olish uchun qo‘llab-quvvatlash xizmati bilan bog‘laning.',
          );
        }

        return Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              widget.navigationShell,
              if (status.isArchived)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: SubscriptionBlockedView(
                      title: 'Hisobingiz arxivlangan',
                      message: 'Sizning hisobingiz arxivlangan xolatda. Ma’lumotlarni ko‘rish uchun tarifni yangilang.',
                      actionLabel: 'Tarifni yangilash',
                      onAction: () {
                        context.push(Routes.subscription.path);
                      },
                    ),
                  ),
                ),
            ],
          ), // Direct use of navigationShell preserves state (IndexedStack)
          bottomNavigationBar: LiquidBottomBar(
            pageOffset: _pageValue,
            isDragging: _isDragging,
            onItemSelected: (index) {
              if (status.isArchived) {
                // Show archive message or do nothing
                return;
              }
              widget.navigationShell.goBranch(index);
            },
            onHorizontalDragStart: (details) {
              if (status.isArchived) return;
              _handleDragStart(details);
            },
            onHorizontalDragUpdate: (details) {
              if (status.isArchived) return;
              _handleDragUpdate(details);
            },
            onHorizontalDragEnd: (details) {
              if (status.isArchived) return;
              _handleDragEnd(details);
            },
            items: widget.items,
          ),
        );
      },
    );
  }
}
