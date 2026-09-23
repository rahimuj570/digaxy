import 'dart:async';

import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../services/api/api_service.dart';

/// A floating chatbot widget available only in the mover section.
class MoverChatbot extends StatefulWidget {
  const MoverChatbot({super.key});

  @override
  State<MoverChatbot> createState() => _MoverChatbotState();
}

class _MoverChatbotState extends State<MoverChatbot>
    with SingleTickerProviderStateMixin {
  static const double _fabSize = 56;
  static const double _edgePadding = 16;

  bool _open = false;
  bool _sending = false;
  int _typingDots = 1;
  final List<Map<String, String>> _messages = [];
  final TextEditingController _ctrl = TextEditingController();
  final ApiService _api = Get.isRegistered<ApiService>()
      ? Get.find<ApiService>()
      : ApiService();
  late final AnimationController _anim;
  Map<String, dynamic>? _assistantState;
  Timer? _typingTimer;
  double? _fabTop;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _anim.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _startTypingAnimation() {
    _typingTimer?.cancel();
    _typingDots = 1;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      if (!mounted || !_sending) return;
      setState(() {
        _typingDots = _typingDots == 3 ? 1 : _typingDots + 1;
      });
    });
  }

  void _stopTypingAnimation() {
    _typingTimer?.cancel();
    _typingTimer = null;
    _typingDots = 1;
  }

  void _ensureFabPosition(Size size, EdgeInsets insets) {
    if (_fabTop != null) return;
    _fabTop = size.height - insets.bottom - _fabSize - _edgePadding;
  }

  void _clampFabPositionToBounds(Size size, EdgeInsets insets) {
    if (_fabTop == null) return;

    final minTop = insets.top + _edgePadding;
    final maxTop = size.height - insets.bottom - _fabSize - _edgePadding;

    _fabTop = _fabTop!.clamp(minTop, maxTop);
  }

  void _onDragUpdate(DragUpdateDetails details, Size size, EdgeInsets insets) {
    final minTop = insets.top + _edgePadding;
    final maxTop = size.height - insets.bottom - _fabSize - _edgePadding;

    setState(() {
      _fabTop = (_fabTop! + details.delta.dy).clamp(minTop, maxTop);
    });
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _anim.forward();
    } else {
      _anim.reverse();
    }
  }

  Future<void> _send() async {
    if (_sending) return;

    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _ctrl.clear();
      _sending = true;
    });
    _startTypingAnimation();

    try {
      final result = await _api.aiSupport(
        message: text,
        state: _assistantState,
      );
      final reply = (result['response'] as String?)?.trim();
      final state = result['state'];
      if (state is Map<String, dynamic>) {
        _assistantState = state;
      }

      if (!mounted) return;
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': reply == null || reply.isEmpty
              ? 'I could not generate a response right now.'
              : reply,
        });
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({'role': 'assistant', 'text': e.message});
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': 'Unable to contact AI support right now. Please try again.',
        });
      });
    } finally {
      if (!mounted) return;
      _stopTypingAnimation();
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const panelWidth = 340.0;
    const panelHeight = 460.0;
    const panelGap = 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final insets = EdgeInsets.zero;

        _ensureFabPosition(size, insets);
        _clampFabPositionToBounds(size, insets);

        final buttonLeft = size.width - _fabSize - _edgePadding;
        final buttonTop = _fabTop!;
        final panelLeft = (size.width - panelWidth - _edgePadding).clamp(
          _edgePadding,
          size.width - panelWidth - _edgePadding,
        );
        final minPanelTop = insets.top + _edgePadding;
        final maxPanelTop =
            size.height - insets.bottom - panelHeight - _edgePadding;
        final safeMaxPanelTop = maxPanelTop < minPanelTop
            ? minPanelTop
            : maxPanelTop;
        final panelTop = (buttonTop - panelHeight - panelGap).clamp(
          minPanelTop,
          safeMaxPanelTop,
        );

        return SizedBox.expand(
          child: Stack(
            children: [
              if (_open)
                Positioned(
                  left: panelLeft,
                  top: panelTop,
                  child: SizeTransition(
                    sizeFactor: CurvedAnimation(
                      parent: _anim,
                      curve: Curves.easeInOut,
                    ),
                    axisAlignment: -1.0,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: panelWidth,
                        height: panelHeight,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.6),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFF111111),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.accent,
                                    child: Icon(
                                      Icons.chat_bubble,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Customer Assistant',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _toggle,
                                    icon: const Icon(
                                      Icons.close,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: (_messages.isEmpty && !_sending)
                                    ? const Center(
                                        child: Text(
                                          'Say hi to the assistant',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        reverse: true,
                                        itemCount:
                                            _messages.length +
                                            (_sending ? 1 : 0),
                                        itemBuilder: (context, idx) {
                                          if (_sending && idx == 0) {
                                            return Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                    ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                constraints:
                                                    const BoxConstraints(
                                                      maxWidth: panelWidth - 64,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF1F1F1F,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'AI is typing${'.' * _typingDots}',
                                                  style: const TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          final messageIndex =
                                              _messages.length -
                                              1 -
                                              idx +
                                              (_sending ? 1 : 0);
                                          final msg = _messages[messageIndex];
                                          final isUser = msg['role'] == 'user';
                                          return Align(
                                            alignment: isUser
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                  ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              constraints: const BoxConstraints(
                                                maxWidth: panelWidth - 64,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isUser
                                                    ? AppColors.accent
                                                    : const Color(0xFF1F1F1F),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                msg['text'] ?? '',
                                                style: TextStyle(
                                                  color: isUser
                                                      ? Colors.black
                                                      : AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _ctrl,
                                      enabled: !_sending,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Type a message',
                                        hintStyle: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFF111111),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                      ),
                                      onSubmitted: (_) => _send(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _sending ? null : _send,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: AppColors.accent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.send,
                                        color: Colors.black,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (!_open)
                Positioned(
                  left: buttonLeft,
                  top: buttonTop,
                  child: GestureDetector(
                    onTap: _toggle,
                    onPanUpdate: (details) =>
                        _onDragUpdate(details, size, insets),
                    child: Container(
                      width: _fabSize,
                      height: _fabSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.chat, color: Colors.black),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
