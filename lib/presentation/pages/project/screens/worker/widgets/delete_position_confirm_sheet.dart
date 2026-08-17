import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ehisob/infrastructure/models/worker_model.dart';

class DeletePositionConfirmSheet extends StatelessWidget {
  final WorkerPositionModel position;

  const DeletePositionConfirmSheet({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    final bool isDeleted = position.isDeleted;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const Gap(24),

          // Icon and Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isDeleted ? Colors.green : Colors.amber).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isDeleted ? Icons.restore_rounded : Icons.delete_outline_rounded,
                  color: isDeleted ? Colors.green : Colors.amber,
                  size: 32,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDeleted ? 'Lavozimni tiklash' : 'Lavozimni o\'chirish',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      position.name ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(20),

          // Content
          Text(
            isDeleted
                ? 'Ushbu lavozimni tiklashni xohlaysizmi? Lavozim qayta faol holatga qaytadi.'
                : 'Ushbu lavozimni o\'chirmoqchimisiz? Keyinchalik qayta tiklash mumkin.',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
          const Gap(24),

          // Actions
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Bekor qilish',
                    style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDeleted ? Colors.green : Colors.amber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    isDeleted ? 'Tiklash' : 'O\'chirish',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
