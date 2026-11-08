import 'package:flutter/material.dart';
import '../core/theme/soundwave_theme.dart';

/// Conteúdo compartilhado no início de cada página, dentro da mesma rolagem.
class PageChrome extends InheritedWidget {
  const PageChrome({super.key, required this.leading, required super.child});
  final List<Widget> leading;
  static List<Widget> of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PageChrome>()?.leading ??
      const [];
  @override
  bool updateShouldNotify(PageChrome oldWidget) => leading != oldWidget.leading;
}

class ScrollingPage extends StatelessWidget {
  const ScrollingPage({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 28),
  });
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => ListView(
    primary: false,
    padding: EdgeInsets.zero,
    children: [
      Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 360,
            child: IgnorePointer(
              child: DecoratedBox(
                key: ValueKey('scrolling-top-gradient'),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: [Color(0xFF171020), Color(0xFF0C171D)],
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, SoundWaveColors.background],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...PageChrome.of(context),
              Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
