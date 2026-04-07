import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../presentation/assets/asset_index.dart';
import '../../data/models/enums.dart';
import '../../data/models/installment_item_model.dart';
import '../../data/models/installment_plan_model.dart';
import '../../data/models/payment_document_model.dart';
import '../../data/repositories/document_upload_repository.dart';
import '../../data/repositories/installment_repository.dart';
import 'payment_schedule_event.dart';
import 'payment_schedule_state.dart';

class PaymentScheduleBloc extends Bloc<PaymentScheduleEvent, PaymentScheduleState> {
  final InstallmentRepository _repository;
  final DocumentUploadRepository _docRepository;

  PaymentScheduleBloc({InstallmentRepository? repository, DocumentUploadRepository? docRepository})
    : _repository = repository ?? InstallmentRepository(),
      _docRepository = docRepository ?? DocumentUploadRepository(),
      super(PaymentScheduleState()) {
    on<PaymentScheduleStarted>(_onStarted);
    on<PaymentPartnerSelected>(_onPartnerSelected);
    on<PaymentTotalAmountChanged>(_onTotalAmountChanged);
    on<PaymentCurrencyChanged>(_onCurrencyChanged);
    on<PaymentNoteChanged>(_onNoteChanged);
    on<PaymentScheduleTypeSelected>(_onScheduleTypeSelected);
    on<PaymentStartDateChanged>(_onStartDateChanged);
    on<PaymentInstallmentCountChanged>(_onInstallmentCountChanged);
    on<PaymentAdvanceToggled>(_onAdvanceToggled);
    on<PaymentAdvanceAmountChanged>(_onAdvanceAmountChanged);
    on<PaymentFreeInstallmentAdded>(_onFreeInstallmentAdded);
    on<PaymentFreeInstallmentRemoved>(_onFreeInstallmentRemoved);
    on<PaymentFreeInstallmentUpdated>(_onFreeInstallmentUpdated);
    on<PaymentScheduleSubmitted>(_onScheduleSubmitted);
    on<PaymentStepChanged>(_onStepChanged);
    on<PaymentStepBack>(_onStepBack);
    // Documents
    on<PaymentDocumentAdded>(_onDocumentAdded);
    on<PaymentDocumentProgressUpdated>(_onDocumentProgress);
    on<PaymentDocumentUploadSucceeded>(_onDocumentSucceeded);
    on<PaymentDocumentUploadFailed>(_onDocumentFailed);
    on<PaymentDocumentRemoved>(_onDocumentRemoved);
  }

  // ─── Start ────────────────────────────────────────────────────────────────

  void _onStarted(PaymentScheduleStarted event, Emitter<PaymentScheduleState> emit) {
    emit(state.copyWith(status: PaymentScheduleStatus.initial, currentStep: 0, selectedPartner: event.initialPartner, isPartnerLocked: event.initialPartner != null));
  }

  // ─── Step 1 ───────────────────────────────────────────────────────────────

  void _onPartnerSelected(PaymentPartnerSelected event, Emitter<PaymentScheduleState> emit) {
    emit(state.copyWith(selectedPartner: event.partner, validationErrors: {}));
  }

  void _onTotalAmountChanged(PaymentTotalAmountChanged event, Emitter<PaymentScheduleState> emit) {
    emit(state.copyWith(totalAmount: event.amount, validationErrors: {}));
    if (state.scheduleType == PaymentScheduleType.equal) {
      emit(
        state.copyWith(
          totalAmount: event.amount,
          calculatedInstallments: _calculateEqual(total: event.amount, startDate: state.startDate, count: state.installmentCount, hasAdvance: state.isAdvanceEnabled, advance: state.advanceAmount),
        ),
      );
    }
  }

  void _onCurrencyChanged(PaymentCurrencyChanged event, Emitter<PaymentScheduleState> emit) {
    emit(state.copyWith(currency: event.currency));
  }

  void _onNoteChanged(PaymentNoteChanged event, Emitter<PaymentScheduleState> emit) {
    emit(state.copyWith(note: event.note));
  }

  // ─── Step 2 ───────────────────────────────────────────────────────────────

  void _onScheduleTypeSelected(PaymentScheduleTypeSelected event, Emitter<PaymentScheduleState> emit) {
    // Type o'zgarganda avans holatini reset qilamiz
    emit(state.copyWith(scheduleType: event.type, validationErrors: {}, isAdvanceEnabled: false, advanceAmount: 0.0));

    if (event.type == PaymentScheduleType.custom) {
      // Erkin grafik: avans toggle off — faqat 2 ta bo'sh qism bilan boshlaymiz
      final today = DateTime.now();
      final items = <InstallmentItemModel>[
        InstallmentItemModel.preview(itemNumber: 1, isAdvance: false, amount: 0, dueDate: DateFormat('yyyy-MM-dd').format(DateTime(today.year, today.month + 1, today.day))),
        InstallmentItemModel.preview(itemNumber: 2, isAdvance: false, amount: 0, dueDate: DateFormat('yyyy-MM-dd').format(DateTime(today.year, today.month + 2, today.day))),
      ];
      emit(state.copyWith(freeInstallments: items));
    }
  }

  // ─── Step 3 (equal) ──────────────────────────────────────────────────────

  void _onStartDateChanged(PaymentStartDateChanged event, Emitter<PaymentScheduleState> emit) {
    emit(
      state.copyWith(
        startDate: event.date,
        calculatedInstallments: _calculateEqual(total: state.totalAmount, startDate: event.date, count: state.installmentCount, hasAdvance: state.isAdvanceEnabled, advance: state.advanceAmount),
      ),
    );
  }

  void _onInstallmentCountChanged(PaymentInstallmentCountChanged event, Emitter<PaymentScheduleState> emit) {
    emit(
      state.copyWith(
        installmentCount: event.count,
        calculatedInstallments: _calculateEqual(total: state.totalAmount, startDate: state.startDate, count: event.count, hasAdvance: state.isAdvanceEnabled, advance: state.advanceAmount),
      ),
    );
  }

  void _onAdvanceToggled(PaymentAdvanceToggled event, Emitter<PaymentScheduleState> emit) {
    final advance = event.isEnabled ? state.advanceAmount : 0.0;

    if (state.scheduleType == PaymentScheduleType.custom) {
      // ── Erkin grafik: avans item ni qo'shish / olib tashlash ──────────────
      List<InstallmentItemModel> updatedFree;
      if (event.isEnabled) {
        // Avans item birinchiga qo'shamiz (agar yo'q bo'lsa)
        final alreadyHas = state.freeInstallments.any((i) => i.isAdvance);
        if (!alreadyHas) {
          final today = DateTime.now();
          final advanceItem = InstallmentItemModel.preview(itemNumber: 0, isAdvance: true, amount: 0, dueDate: DateFormat('yyyy-MM-dd').format(today));
          updatedFree = [advanceItem, ...state.freeInstallments];
        } else {
          updatedFree = state.freeInstallments;
        }
      } else {
        // Avans itemni olib tashlaymiz
        updatedFree = state.freeInstallments.where((i) => !i.isAdvance).toList();
      }
      emit(state.copyWith(isAdvanceEnabled: event.isEnabled, advanceAmount: advance, freeInstallments: updatedFree));
    } else {
      // ── Teng jadval: calculated installments ni qayta hisoblaymiz ─────────
      emit(
        state.copyWith(
          isAdvanceEnabled: event.isEnabled,
          advanceAmount: advance,
          calculatedInstallments: _calculateEqual(total: state.totalAmount, startDate: state.startDate, count: state.installmentCount, hasAdvance: event.isEnabled, advance: advance),
        ),
      );
    }
  }

  void _onAdvanceAmountChanged(PaymentAdvanceAmountChanged event, Emitter<PaymentScheduleState> emit) {
    emit(
      state.copyWith(
        advanceAmount: event.amount,
        calculatedInstallments: _calculateEqual(total: state.totalAmount, startDate: state.startDate, count: state.installmentCount, hasAdvance: state.isAdvanceEnabled, advance: event.amount),
      ),
    );
  }

  // ─── Step 3 (custom / free) ───────────────────────────────────────────────

  void _onFreeInstallmentAdded(PaymentFreeInstallmentAdded event, Emitter<PaymentScheduleState> emit) {
    final nonAdvance = state.freeInstallments.where((i) => !i.isAdvance).length;
    final today = DateTime.now();
    final newDate = DateTime(today.year, today.month + nonAdvance + 1, today.day);

    final newItem = InstallmentItemModel.preview(itemNumber: nonAdvance + 1, isAdvance: false, amount: 0, dueDate: DateFormat('yyyy-MM-dd').format(newDate));
    emit(state.copyWith(freeInstallments: [...state.freeInstallments, newItem]));
  }

  void _onFreeInstallmentRemoved(PaymentFreeInstallmentRemoved event, Emitter<PaymentScheduleState> emit) {
    final updated = state.freeInstallments.where((i) => i.id != event.id).toList();
    emit(state.copyWith(freeInstallments: updated));
  }

  void _onFreeInstallmentUpdated(PaymentFreeInstallmentUpdated event, Emitter<PaymentScheduleState> emit) {
    final updated = state.freeInstallments.map((i) => i.id == event.item.id ? event.item : i).toList();
    emit(state.copyWith(freeInstallments: updated));
  }

  // ─── Navigation ────────────────────────────────��─────────────────────────

  void _onStepChanged(PaymentStepChanged event, Emitter<PaymentScheduleState> emit) {
    final errors = _validateStep(state.currentStep);
    if (errors.isNotEmpty) {
      emit(state.copyWith(validationErrors: errors));
      return;
    }

    if (event.step == 2 && state.scheduleType == PaymentScheduleType.equal) {
      emit(
        state.copyWith(
          currentStep: event.step,
          validationErrors: {},
          calculatedInstallments: _calculateEqual(
            total: state.totalAmount,
            startDate: state.startDate,
            count: state.installmentCount,
            hasAdvance: state.isAdvanceEnabled,
            advance: state.advanceAmount,
          ),
        ),
      );
    } else {
      emit(state.copyWith(currentStep: event.step, validationErrors: {}));
    }
  }

  void _onStepBack(PaymentStepBack event, Emitter<PaymentScheduleState> emit) {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1, validationErrors: {}));
    }
  }

  // ─── Documents ───────────────────────────────────────────────────────────

  Future<void> _onDocumentAdded(PaymentDocumentAdded event, Emitter<PaymentScheduleState> emit) async {
    // Ro'yxatga qo'shamiz, status = uploading
    final doc = event.document.copyWith(status: DocumentUploadStatus.uploading, progress: 0);
    emit(state.copyWith(documents: [...state.documents, doc]));

    try {
      final result = await _docRepository.upload(
        file: File(doc.localPath),
        type: 'installment',
        // type: doc.isImage ? 'image' : 'file',
        onProgress: (percent) {
          add(PaymentDocumentProgressUpdated(localPath: doc.localPath, progress: percent));
        },
      );
      add(PaymentDocumentUploadSucceeded(localPath: doc.localPath, serverId: result.id, serverUrl: result.url));
    } catch (e) {
      add(PaymentDocumentUploadFailed(localPath: doc.localPath, error: e.toString()));
    }
  }

  void _onDocumentProgress(PaymentDocumentProgressUpdated event, Emitter<PaymentScheduleState> emit) {
    final updated = state.documents.map((d) {
      if (d.localPath != event.localPath) return d;
      return d.copyWith(progress: event.progress);
    }).toList();
    emit(state.copyWith(documents: updated));
  }

  void _onDocumentSucceeded(PaymentDocumentUploadSucceeded event, Emitter<PaymentScheduleState> emit) {
    final updated = state.documents.map((d) {
      if (d.localPath != event.localPath) return d;
      return d.copyWith(status: DocumentUploadStatus.success, progress: 100, serverId: event.serverId, serverUrl: event.serverUrl);
    }).toList();
    emit(state.copyWith(documents: updated));
  }

  void _onDocumentFailed(PaymentDocumentUploadFailed event, Emitter<PaymentScheduleState> emit) {
    final updated = state.documents.map((d) {
      if (d.localPath != event.localPath) return d;
      return d.copyWith(status: DocumentUploadStatus.failure, errorMessage: event.error);
    }).toList();
    emit(state.copyWith(documents: updated));
  }

  void _onDocumentRemoved(PaymentDocumentRemoved event, Emitter<PaymentScheduleState> emit) {
    final updated = state.documents.where((d) => d.localPath != event.localPath).toList();
    emit(state.copyWith(documents: updated));
  }

  // ─── Submit (real API) ────────────────────────────────────────────────────

  Future<void> _onScheduleSubmitted(PaymentScheduleSubmitted event, Emitter<PaymentScheduleState> emit) async {
    if (state.selectedPartner == null) return;

    emit(state.copyWith(status: PaymentScheduleStatus.loading));

    try {
      final partnerId = int.tryParse(state.selectedPartner!.id) ?? 0;
      final currencyTypeId = state.currency == PaymentCurrency.uzs ? 1 : 2;
      final globalNote = state.note.isNotEmpty ? state.note : null;
      final uploadedFileIds = state.documents.where((d) => d.isUploaded && d.serverId != null).map((d) => d.serverId!).toList();

      InstallmentPlanModel result;

      if (state.scheduleType == PaymentScheduleType.equal) {
        // Equal: backend items ni o'zi hisoblaydi.
        // Agar avans bo'lsa — advance_amount beriladi + items[0] sifatida ham avans qo'shiladi.
        final hasAdvance = state.isAdvanceEnabled && state.advanceAmount > 0;

        // Equal uchun items: avans (agar bor bo'lsa) + calculatedInstallments dan oddiy qismlar
        final equalItems = <Map<String, dynamic>>[];
        if (hasAdvance) {
          equalItems.add({'amount': state.advanceAmount, 'due_date': state.startDate.toIso8601String()});
        }
        for (final item in state.calculatedInstallments.where((i) => !i.isAdvance)) {
          equalItems.add({'amount': item.amount, 'due_date': _toIso(item.dueDate)});
        }

        result = await _repository.createInstallment(
          partnerId: partnerId,
          currencyTypeId: currencyTypeId,
          totalAmount: state.totalAmount,
          scheduleType: 'equal',
          hasAdvance: hasAdvance,
          advanceAmount: hasAdvance ? state.advanceAmount : null,
          startDate: state.startDate.toIso8601String(),
          installmentCount: state.installmentCount,
          items: equalItems.isNotEmpty ? equalItems : null,
          note: globalNote,
          fileIds: uploadedFileIds.isNotEmpty ? uploadedFileIds : null,
        );
      } else {
        // Custom (erkin grafik):
        // Avans item ham items[0] sifatida yuboriladi + advance_amount alohida beriladi.
        final advanceItem = state.freeInstallments.where((i) => i.isAdvance).firstOrNull;
        final regularItems = state.freeInstallments.where((i) => !i.isAdvance).toList();

        final hasAdvance = advanceItem != null;
        final advanceAmount = hasAdvance ? advanceItem.amount : null;

        // items: avans birinchi, keyin oddiy qismlar
        final items = <Map<String, dynamic>>[
          if (hasAdvance) {'amount': advanceItem.amount, 'due_date': _toIso(advanceItem.dueDate), if (advanceItem.note != null && advanceItem.note!.isNotEmpty) 'note': advanceItem.note},
          ...regularItems.map((item) => <String, dynamic>{'amount': item.amount, 'due_date': _toIso(item.dueDate), if (item.note != null && item.note!.isNotEmpty) 'note': item.note}),
        ];

        result = await _repository.createInstallment(
          partnerId: partnerId,
          currencyTypeId: currencyTypeId,
          totalAmount: state.totalAmount,
          scheduleType: 'custom',
          hasAdvance: hasAdvance,
          advanceAmount: advanceAmount,
          items: items,
          note: globalNote,
          fileIds: uploadedFileIds.isNotEmpty ? uploadedFileIds : null,
        );
      }

      emit(state.copyWith(status: PaymentScheduleStatus.success, createdPlan: result, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(status: PaymentScheduleStatus.failure, errorMessage: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// "yyyy-MM-dd" → ISO 8601 ("yyyy-MM-ddT00:00:00.000Z")
  String _toIso(String dateStr) {
    final d = DateTime.tryParse(dateStr);
    return (d ?? DateTime.now()).toIso8601String();
  }

  // ─── Validation ──────────────────────────────────────────────────────────

  Map<String, String> _validateStep(int step) {
    final errors = <String, String>{};
    switch (step) {
      case 0:
        if (state.selectedPartner == null) errors['partner'] = 'Hamkorni tanlang';
        if (state.totalAmount <= 0) errors['amount'] = 'Summani kiriting';
        break;
      case 1:
        if (state.scheduleType == null) errors['type'] = 'Grafik turini tanlang';
        break;
    }
    return errors;
  }

  // ─── Equal schedule calculator (API algoritmi bilan mos) ─────────────────

  List<InstallmentItemModel> _calculateEqual({required double total, required DateTime startDate, required int count, required bool hasAdvance, required double advance}) {
    if (total <= 0 || count <= 0) return [];

    final items = <InstallmentItemModel>[];
    final fmt = DateFormat('yyyy-MM-dd');
    int itemNum = 1;

    if (hasAdvance && advance > 0) {
      items.add(InstallmentItemModel.preview(itemNumber: 0, isAdvance: true, amount: _round2(advance), dueDate: fmt.format(startDate)));
    }

    final remaining = hasAdvance ? _round2(total - advance) : total;
    if (remaining <= 0 || count <= 0) return items;

    final perItem = _round2(remaining / count);
    final distributed = _round2(perItem * (count - 1));
    final lastAmount = _round2(remaining - distributed);

    for (int i = 0; i < count; i++) {
      final monthOffset = i + (hasAdvance ? 1 : 0);
      final dueDate = DateTime(startDate.year, startDate.month + monthOffset, startDate.day);
      final amount = (i == count - 1) ? lastAmount : perItem;

      items.add(InstallmentItemModel.preview(itemNumber: itemNum++, isAdvance: false, amount: amount, dueDate: fmt.format(dueDate)));
    }

    return items;
  }

  double _round2(double v) => double.parse(v.toStringAsFixed(2));
}
