import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/partner/partner_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import '../../assets/asset_index.dart';

class SmsSettingPage extends StatefulWidget {
  final int partnerId;

  const SmsSettingPage({super.key, required this.partnerId});

  @override
  State<SmsSettingPage> createState() => _SmsSettingPageState();
}

class _SmsSettingPageState extends State<SmsSettingPage> {
  bool _enabled = false;
  bool _sendOnDueDate = false;
  int _remindBeforeDays = 0;
  int _sendAfterDueDays = 0;
  String? _sendDate;

  List<int> _beforeOptions = [];
  List<int> _afterOptions = [];

  @override
  void initState() {
    super.initState();
    context.read<PartnerBloc>().add(GetSmsSettingsEvent(id: widget.partnerId));
  }

  void _initializeSettings(Map<String, dynamic> data) {
    if (data.containsKey('body')) {
      final body = data['body'];
      _enabled = body['enabled'] ?? false;
      _sendOnDueDate = body['send_on_due_date'] ?? false;
      _remindBeforeDays = body['remind_before_days'] ?? 0;
      _sendAfterDueDays = body['send_after_due_days'] ?? 0;
      _sendDate = body['send_date'];
    }
    if (data.containsKey('options')) {
      final options = data['options'];
      _beforeOptions = List<int>.from(options['remind_before_days'] ?? []);
      _afterOptions = List<int>.from(options['send_after_due_days'] ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PartnerBloc, PartnerState>(
      listenWhen: (previous, current) => previous.statusGetSmsSettings != current.statusGetSmsSettings || previous.statusUpdateSmsSettings != current.statusUpdateSmsSettings,
      listener: (context, state) {
        if (state.statusGetSmsSettings == Status.success && state.smsSettingsMap != null) {
          _initializeSettings(state.smsSettingsMap!);
        }
        if (state.statusUpdateSmsSettings == Status.success) {
          // Success update -> Go back
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Sozlamalar muvaffaqiyatli saqlandi'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              elevation: 4,
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.pop(context);
        }
        if (state.statusUpdateSmsSettings == Status.error || state.statusGetSmsSettings == Status.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Xatolik yuz berdi'),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              elevation: 4,
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      builder: (context, state) {
        final isFetching = state.statusGetSmsSettings == Status.loading;
        final isUpdating = state.statusUpdateSmsSettings == Status.loading;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: _buildAppBar(context),
          body: isFetching
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(radius: 12),
                      Gap(16),
                      Text(
                        'Sozlamalar yuklanmoqda...',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                      child: Column(
                        children: [
                          _buildStatusCard(),
                          const Gap(12),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _enabled ? 1.0 : 0.5,
                            child: IgnorePointer(ignoring: !_enabled, child: _buildDetailedSettings()),
                          ),
                        ],
                      ),
                    ),
                    _buildBottomActionButton(isUpdating),
                  ],
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: BackArrowButton(),
      centerTitle: true,
      title: const Text(
        'SMS Sozlamalari',
        style: TextStyle(color: Color(0xFF1E293B),
            fontSize: 18, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.colors.primary, AppTheme.colors.primary.withValues(alpha: 1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: (_enabled ? AppTheme.colors.primary : const Color(0xFF94A3B8)).withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: SvgPicture.asset(AppIcons.sms,colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Xabarnoma holati',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    Text(
                      _enabled ? 'SMS xizmati yoqilgan' : 'SMS xizmati o\'chirilgan',
                      style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
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
        ],
      ),
    );
  }

  Widget _buildDetailedSettings() {
    return Column(
      key: const ValueKey('enabled'),
      children: [
        _buildConfigSection(
          title: 'Eslatma SMS (muddatdan oldin)',
          subtitle: 'To\'lov muddatidan necha kun oldin xabar yuborish boshlansin?',
          icon: Icons.event_note_outlined,
          iconColor: Color(0xFF0EA5E9),
          options: _beforeOptions,
          selectedValue: _remindBeforeDays,
          onSelect: (val) {
            setState(() => _remindBeforeDays = val);
            _syncWithBloc({'remind_before_days': val});
          },
        ),
        const Gap(10),
        _buildConfigSection(
          title: 'Eslatma SMS (muddatidan keyin)',
          subtitle: 'To\'lov muddati o\'tgandan keyin necha kungacha yuborilsin?',
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
          subtitle: 'To\'lov muddati kelgan kuni SMS yuboriladi',
          icon: Icons.notifications_active_outlined,
          iconColor: Color(0xFFF59E0B),
          value: _sendOnDueDate,
          onChanged: (val) {
            setState(() => _sendOnDueDate = val);
            _syncWithBloc({'send_on_due_date': val});
          },
        ),
        if (_sendDate != null) ...[const Gap(10), _buildInfoCard(title: 'Yuborish vaqti', value: _sendDate!, icon: Icons.access_time_filled_rounded, iconColor: Colors.purple)],
        Gap(MediaQuery.of(context).padding.bottom - 50),
      ],
    );
  }

  void _syncWithBloc(Map<String, dynamic> update) {
    context.read<PartnerBloc>().add(UpdateSmsSettingsLocalEvent(data: update));
  }

  Widget _buildConfigSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<int> options,
    required int selectedValue,
    required Function(int) onSelect,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const Gap(12),
              Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const Gap(4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          const Gap(16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [_buildModernChip(0, 'Hech qachon', selectedValue == 0, onSelect), ...options.map((opt) => _buildModernChip(opt, '$opt', selectedValue == opt, onSelect))],
          ),
        ],
      ),
    );
  }

  Widget _buildModernChip(int value, String label, bool isSelected, Function(int) onSelect) {
    return InkWell(
      onTap: () => onSelect(value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.colors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.colors.primary : Colors.transparent, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF475569), fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildToggleCard({required String title, required String subtitle, required IconData icon, required Color iconColor, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged, activeTrackColor: AppTheme.colors.primary),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String value, required IconData icon, required Color iconColor}) {
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
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: iconColor),
            ),
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
        padding: EdgeInsets.fromLTRB(20, 20, 20, 5 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [const Color(0xFFF8FAFC).withValues(alpha: 0), const Color(0xFFF8FAFC)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.colors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            shadowColor: AppTheme.colors.primary.withValues(alpha: 0.4),
          ),
          child: isLoading ? const CupertinoActivityIndicator(color: Colors.white) : Text('Saqlash', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        ),
      ),
    );
  }

  void _saveSettings() {
    final data = {'remind_before_days': _remindBeforeDays, 'send_on_due_date': _sendOnDueDate, 'send_after_due_days': _sendAfterDueDays, 'enabled': _enabled};
    context.read<PartnerBloc>().add(UpdateSmsSettingsEvent(id: widget.partnerId, data: data));
  }
}
