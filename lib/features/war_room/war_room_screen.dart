import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/vigil_bottom_nav.dart';
import 'war_room_provider.dart';

class WarRoomScreen extends ConsumerStatefulWidget {
  const WarRoomScreen({super.key});
  @override
  ConsumerState<WarRoomScreen> createState() => _WarRoomScreenState();
}

class _WarRoomScreenState extends ConsumerState<WarRoomScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    if (_ctrl.text.trim().isEmpty) return;
    ref.read(warRoomProvider.notifier).send(_ctrl.text, 'James Harrington');
    _ctrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(warRoomProvider);

    return Scaffold(
      bottomNavigationBar: VigilBottomNav(
        current: VigilTab.warRoom,
        hasCrisisActive: true,
        onTabSelected: (tab) => _nav(context, tab),
      ),
      body: AuroraBackground(
        blobColors: [
          AppColors.warningAmber.withOpacity(0.08),
          AppColors.crisisRed.withOpacity(0.06),
          AppColors.intelViolet.withOpacity(0.05),
        ],
        child: SafeArea(
          bottom: false,
          child: Column(children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.go('/crisis-command'),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderDefault)),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('War Room',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    Text('INC-001 · Kitchen Fire',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.crisisRed)),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: AppColors.crisisRedDim,
                      borderRadius: BorderRadius.circular(6)),
                  child: Row(children: [
                    Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                            color: AppColors.crisisRed,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('LIVE',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.crisisRed,
                            letterSpacing: 1.5)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 10),

            // Members row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                for (final name in [
                  'James H.',
                  'Sarah C.',
                  'Raj P.',
                  'David O.',
                  'Maria S.'
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: Row(children: [
                        Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(
                                color: AppColors.statusTeal,
                                shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(name,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ]),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 10),
            const Divider(color: AppColors.borderDefault, height: 1),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                itemCount: messages.length,
                itemBuilder: (_, i) => _Bubble(msg: messages[i]),
              ),
            ),

            // Input
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              decoration: const BoxDecoration(
                color: AppColors.bgCard,
                border: Border(
                    top: BorderSide(color: AppColors.borderDefault)),
              ),
              child: SafeArea(
                top: false,
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Message the team…',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                          color: AppColors.crisisRed,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.send_rounded,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _nav(BuildContext context, VigilTab tab) {
    switch (tab) {
      case VigilTab.dashboard:
        context.go('/dashboard');
      case VigilTab.warRoom:
        break;
      case VigilTab.map:
        context.go('/floor-map');
      case VigilTab.notifications:
        context.go('/notifications');
      case VigilTab.profile:
        context.go('/profile');
    }
  }
}

// ── Bubble ────────────────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  final WarMessage msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isSystem = msg.type == MessageType.system;
    final isAI = msg.type == MessageType.ai;

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderDefault)),
            child: Text(msg.content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.textMuted)),
          ),
        ),
      );
    }

    if (isAI) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: GlassCard(
          borderColor: AppColors.intelViolet.withOpacity(0.35),
          glowColor: AppColors.intelViolet,
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.auto_awesome,
                  size: 14, color: AppColors.intelViolet),
              const SizedBox(width: 6),
              Text('GEMINI AI',
                  style: AppTypography.label
                      .copyWith(color: AppColors.intelViolet)),
              const Spacer(),
              Text(msg.timeStr, style: AppTypography.bodySmall),
            ]),
            const SizedBox(height: 8),
            Text(msg.content,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.5)),
          ]),
        ),
      );
    }

    // Staff message
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(msg.sender,
              style: AppTypography.bodySmall
                  .copyWith(fontWeight: FontWeight.w600)),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14)),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Text(msg.content,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.4)),
              ),
            ),
            const SizedBox(width: 6),
            Text(msg.timeStr, style: AppTypography.bodySmall),
          ],
        ),
      ]),
    );
  }
}
