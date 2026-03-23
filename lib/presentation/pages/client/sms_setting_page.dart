import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/partner/partner_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';

class SmsSettingPage extends StatefulWidget {
  final int partnerId;

  const SmsSettingPage({super.key, required this.partnerId});

  @override
  State<SmsSettingPage> createState() => _SmsSettingPageState();
}

class _SmsSettingPageState extends State<SmsSettingPage> {
  // ── current values ──────────────────────────────────────────────────────────
  bool _enabled = false;
  bool _sendOnDueDate = false;
  bool _sendOnKirim = false;
  bool _sendOnChiqim = false;
  int _remindBeforeDays = 0;
  int _sendAfterDueDays = 0;
  String? _sendDate;

  // ── snapshot from server (change-detection baseline) ────────────────────────
  bool _initialEnabled = false;
  bool _initialSendOnDueDate = false;
  bool _initialSendOnKirim = false;
  bool _initialSendOnChiqim = false;
  int _initialRemindBeforeDays = 0;
  int _initialSendAfterDueDays = 0;

  // ── misc state ───────────────────────────────────────────────────────────────
  bool _isInitialized = false;
  bool _isExiting = false;

  List<int> _beforeOptions = [];
  List<int> _afterOptions = [];

  // ── lifecycle ────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    context.read<PartnerBloc>().add(GetSmsSettingsEvent(id: widget.partnerId));
  }

  // ── helpers ──────────────────────────────────────────────────────────────────

  void _initializeSettings(Map<String, dynamic> data) {
    final Map<String, dynamic> root =
    data.containsKey('result') ? data['result'] : data;

    if (root.containsKey('body')) {
      final body = root['body'] as Map<String, dynamic>;
      final enabled = body['enabled'] as bool? ?? false;
      final sendOnDueDate = body['send_on_due_date'] as bool? ?? false;
      final sendOnKirim = body['send_on_kirim'] as bool? ?? false;
      final sendOnChiqim = body['send_on_chiqim'] as bool? ?? false;
      final remindBeforeDays = body['remind_before_days'] as int? ?? 0;
      final sendAfterDueDays = body['send_after_due_days'] as int? ?? 0;
      final sendDate = body['send_date'] as String?;

      setState(() {
        _enabled = enabled;
        _sendOnDueDate = sendOnDueDate;
        _sendOnKirim = sendOnKirim;
        _sendOnChiqim = sendOnChiqim;
        _remindBeforeDays = remindBeforeDays;
        _sendAfterDueDays = sendAfterDueDays;
        _sendDate = sendDate;

        // Baseline – set only once per fetch cycle
        if (!_isInitialized) {
          _initialEnabled = enabled;
          _initialSendOnDueDate = sendOnDueDate;
          _initialSendOnKirim = sendOnKirim;
          _initialSendOnChiqim = sendOnChiqim;
          _initialRemindBeforeDays = remindBeforeDays;
          _initialSendAfterDueDays = sendAfterDueDays;
          _isInitialized = true;
        }
      });
    }

    if (root.containsKey('options')) {
      final options = root['options'] as Map<String, dynamic>;
      setState(() {
        _beforeOptions =
        List<int>.from(options['remind_before_days'] as List? ?? []);
        _afterOptions =
        List<int>.from(options['send_after_due_days'] as List? ?? []);
      });
    }
  }

  bool _hasChanges() {
    if (!_isInitialized) return false;
    return _enabled != _initialEnabled ||
        _sendOnDueDate != _initialSendOnDueDate ||
        _sendOnKirim != _initialSendOnKirim ||
        _sendOnChiqim != _initialSendOnChiqim ||
        _remindBeforeDays != _initialRemindBeforeDays ||
        _sendAfterDueDays != _initialSendAfterDueDays;
  }

  /// Single exit-point for every "go back" action (AppBar button, system swipe,
  /// Android hardware back).  This guarantees the dialog always fires.
  Future<void> _handleBackRequest() async {
    if (_isExiting) return;

    if (_hasChanges()) {
      final result = await _showUnsavedChangesDialog(context);
      // 'save'    → _saveSettings() was called inside the dialog; stay on page
      // 'discard' → leave without saving
      // 'cancel'  → do nothing
      if (result == 'discard' && mounted) {
        _isExiting = true;
        Navigator.of(context).pop();
      }
    } else {
      _isExiting = true;
      Navigator.of(context).pop();
    }
  }

  void _saveSettings() {
    context.read<PartnerBloc>().add(
      UpdateSmsSettingsEvent(
        id: widget.partnerId,
        data: {
          'enabled': _enabled,
          'send_on_due_date': _sendOnDueDate,
          'send_on_kirim': _sendOnKirim,
          'send_on_chiqim': _sendOnChiqim,
          'remind_before_days': _remindBeforeDays,
          'send_after_due_days': _sendAfterDueDays,
        },
      ),
    );
  }

  void _syncWithBloc(Map<String, dynamic> update) {
    context.read<PartnerBloc>().add(UpdateSmsSettingsLocalEvent(data: update));
  }

  // ── build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PartnerBloc, PartnerState>(
      listenWhen: (prev, cur) =>
      prev.statusGetSmsSettings != cur.statusGetSmsSettings ||
          prev.statusUpdateSmsSettings != cur.statusUpdateSmsSettings,
      listener: (context, state) {
        // Reset baseline flag whenever a fresh fetch starts
        if (state.statusGetSmsSettings == Status.loading) {
          _isInitialized = false;
        }

        if (state.statusGetSmsSettings == Status.success &&
            state.smsSettingsMap != null) {
          _initializeSettings(state.smsSettingsMap!);
        }

        if (state.statusUpdateSmsSettings == Status.success) {
          _isExiting = true;
          _showSnackBar(context, 'Sozlamalar muvaffaqiyatli saqlandi',
              const Color(0xFF10B981));
          Navigator.of(context).pop();
        }

        if (state.statusUpdateSmsSettings == Status.error ||
            state.statusGetSmsSettings == Status.error) {
          _showSnackBar(
              context, state.errorMessage ?? 'Xatolik yuz berdi',
              const Color(0xFFEF4444));
        }
      },
      builder: (context, state) {
        final isFetching = state.statusGetSmsSettings == Status.loading;
        final isUpdating = state.statusUpdateSmsSettings == Status.loading;

        return PopScope(
          // Never let the framework auto-pop; we always decide ourselves.
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return; // framework already popped – shouldn't happen
            _handleBackRequest();
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: _buildAppBar(),
            body: isFetching
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoActivityIndicator(radius: 12),
                  Gap(16),
                  Text(
                    'Sozlamalar yuklanmoqda...',
                    style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
                : Stack(
              children: [
                SingleChildScrollView(
                  padding:
                  const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  child: Column(
                    children: [
                      _buildStatusCard(),
                      const Gap(12),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _enabled ? 1.0 : 0.5,
                        child: IgnorePointer(
                          ignoring: !_enabled,
                          child: _buildDetailedSettings(),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildBottomActionButton(isUpdating),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── app bar ──────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Center(
        child: InkWell(
          // ✅ FIX: calls _handleBackRequest instead of Navigator.pop directly
          onTap: _handleBackRequest,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1E293B), size: 18),
          ),
        ),
      ),
      centerTitle: true,
      title: const Text(
        'SMS Sozlamalari',
        style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w800),
      ),
    );
  }

  // ── cards ────────────────────────────────────────────────────────────────────

  Widget _buildStatusCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              AppTheme.colors.primary,
              AppTheme.colors.primary.withValues(alpha: 1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: (_enabled
                  ? AppTheme.colors.primary
                  : const Color(0xFF94A3B8))
                  .withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle),
            child: SvgPicture.asset(AppIcons.sms,
                colorFilter: const ColorFilter.mode(
                    Colors.white, BlendMode.srcIn)),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xabarnoma holati',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
                Text(
                  _enabled
                      ? 'SMS xizmati yoqilgan'
                      : "SMS xizmati o'chirilgan",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: _enabled,
            onChanged: (val) {
              setState(() => _enabled = val);
              _syncWithBloc({'enabled': val});
            },
            activeTrackColor: Colors.white.withValues(alpha: 0.3),
            inactiveTrackColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedSettings() {
    return Column(
      key: const ValueKey('enabled'),
      children: [
        _buildToggleCard2(
          title: 'Mijozdan pul olinganda sms yuborilsinmi (Kirim)',
          subtitle: 'Kirim qilingan zaxoti SMS yuboriladi',
          icon: AppIcons.income,
          iconColor: const Color(0xFF10B981),
          value: _sendOnKirim,
          onChanged: (val) {
            setState(() => _sendOnKirim = val);
            _syncWithBloc({'send_on_kirim': val});
          },
        ),
        const Gap(10),
        _buildToggleCard2(
          title: 'Mijozga qarz berilganda sms yuborilsinmi (Chiqim)',
          subtitle: 'Chiqim qilingan zaxoti SMS yuboriladi',
          icon: AppIcons.chiqim,
          iconColor: const Color(0xFFF43F5E),
          value: _sendOnChiqim,
          onChanged: (val) {
            setState(() => _sendOnChiqim = val);
            _syncWithBloc({'send_on_chiqim': val});
          },
        ),
        const Gap(10),
        _buildConfigSection(
          title: "Eslatma SMS (muddatdan oldin)",
          subtitle:
          "To'lov muddatidan necha kun oldin xabar yuborish boshlansin?",
          icon: Icons.event_note_outlined,
          iconColor: const Color(0xFF0EA5E9),
          options: _beforeOptions,
          selectedValue: _remindBeforeDays,
          onSelect: (val) {
            setState(() => _remindBeforeDays = val);
            _syncWithBloc({'remind_before_days': val});
          },
        ),
        const Gap(10),
        _buildConfigSection(
          title: "Eslatma SMS (muddatidan keyin)",
          subtitle:
          "To'lov muddati o'tgandan keyin necha kungacha yuborilsin?",
          icon: Icons.error_outline_rounded,
          iconColor: Colors.red,
          options: _afterOptions,
          selectedValue: _sendAfterDueDays,
          onSelect: (val) {
            setState(() => _sendAfterDueDays = val);
            _syncWithBloc({'send_after_due_days': val});
          },
        ),
        const Gap(10),
        _buildToggleCard(
          title: 'Muddat kuni yuborish',
          subtitle: "To'lov muddati kelgan kuni SMS yuboriladi",
          icon: Icons.notifications_active_outlined,
          iconColor: const Color(0xFFF59E0B),
          value: _sendOnDueDate,
          onChanged: (val) {
            setState(() => _sendOnDueDate = val);
            _syncWithBloc({'send_on_due_date': val});
          },
        ),
        if (_sendDate != null) ...[
          const Gap(10),
          _buildInfoCard(
              title: 'Yuborish vaqti',
              value: _sendDate!,
              icon: Icons.access_time_filled_rounded,
              iconColor: Colors.purple),
        ],
        Gap(MediaQuery.of(context).padding.bottom - 50),
      ],
    );
  }

  // ── reusable widgets ─────────────────────────────────────────────────────────

  Widget _buildConfigSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<int> options,
    required int selectedValue,
    required void Function(int) onSelect,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const Gap(12),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B))),
              ),
            ],
          ),
          const Gap(4),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF94A3B8))),
          const Gap(16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildModernChip(0, 'Hech qachon',
                  selectedValue == 0, onSelect),
              ...options.map((opt) => _buildModernChip(
                  opt, '$opt', selectedValue == opt, onSelect)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernChip(
      int value, String label, bool isSelected, void Function(int) onSelect) {
    return InkWell(
      onTap: () => onSelect(value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.colors.primary
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected
                  ? AppTheme.colors.primary
                  : Colors.transparent,
              width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF475569),
              fontWeight: isSelected
                  ? FontWeight.w700
                  : FontWeight.w600,
              fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B))),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppTheme.colors.primary),
        ],
      ),
    );
  }

  Widget _buildToggleCard2({
    required String title,
    required String subtitle,
    required String icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14)),
            child: SvgPicture.asset(icon,
                colorFilter: ColorFilter.mode(
                    AppTheme.colors.primary, BlendMode.srcIn)),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B))),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppTheme.colors.primary),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const Gap(12),
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B))),
          const Spacer(),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: iconColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButton(bool isLoading) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 5 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                const Color(0xFFF8FAFC).withValues(alpha: 0),
                const Color(0xFFF8FAFC)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.colors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            shadowColor: AppTheme.colors.primary.withValues(alpha: 0.4),
          ),
          child: isLoading
              ? const CupertinoActivityIndicator(color: Colors.white)
              : const Text('Saqlash',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5)),
        ),
      ),
    );
  }

  // ── dialog & snackbar ────────────────────────────────────────────────────────

  /// Returns 'save' | 'discard' | 'cancel'
  Future<String?> _showUnsavedChangesDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.save_as_rounded,
                  color: AppTheme.colors.primary,
                  size: 32,
                ),
              ),
              const Gap(20),
              const Text(
                "O'zgarishlar saqlansinmi?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const Gap(12),
              const Text(
                "Sizda saqlanmagan o'zgarishlar mavjud. Sahifadan chiqishdan oldin ularni saqlashni xohlaysizmi?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(32),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx, 'save');
                        _saveSettings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Ha, Saqlansin",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, 'discard'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        foregroundColor: const Color(0xFFF43F5E),
                      ),
                      child: const Text(
                        "Yo'q, Bekor qilinsin",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, 'cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF94A3B8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Sahifada qolish",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        margin: const EdgeInsets.all(20),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}