import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/enums.dart';
import '../../data/models/installment_item_model.dart';
import 'payment_schedule_event.dart';
import 'payment_schedule_state.dart';

class PaymentScheduleBloc extends Bloc<PaymentScheduleEvent, PaymentScheduleState> {
  final _uuid = const Uuid();

  PaymentScheduleBloc() : super(PaymentScheduleState()) {
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
  }

  void _onStarted(
    PaymentScheduleStarted event,
    Emitter<PaymentScheduleState> emit,
  ) {
    emit(state.copyWith(
      status: PaymentScheduleStatus.initial,
      currentStep: 0,
      selectedPartner: event.initialPartner,
      isPartnerLocked: event.initialPartner != null,
    ));
  }

  void _onPartnerSelected(
    PaymentPartnerSelected event,
    Emitter<PaymentScheduleState> emit,
  ) {
    emit(state.copyWith(
      selectedPartner: event.partner,
      validationErrors: {},
    ));
  }

  void _onTotalAmountChanged(
    PaymentTotalAmountChanged event,
    Emitter<PaymentScheduleState> emit,
  ) {
    emit(state.copyWith(
      totalAmount: event.amount,
      validationErrors: {},
    ));

    // Recalculate if on equal schedule
    if (state.scheduleType == PaymentScheduleType.equal) {
      final calculated = _calculateInstallments(
        totalAmount: event.amount,
        startDate: state.startDate,
        count: state.installmentCount,
        isAdvanceEnabled: state.isAdvanceEnabled,
        advanceAmount: state.advanceAmount,
      );
      emit(state.copyWith(calculatedInstallments: calculated));
    }
  }

  void _onCurrencyChanged(
    PaymentCurrencyChanged event,
    Emitter<PaymentScheduleState> emit,
  ) {
    emit(state.copyWith(currency: event.currency));
  }

  void _onNoteChanged(
    PaymentNoteChanged event,
    Emitter<PaymentScheduleState> emit,
  ) {
    emit(state.copyWith(note: event.note));
  }

  void _onScheduleTypeSelected(
    PaymentScheduleTypeSelected event,
    Emitter<PaymentScheduleState> emit,
  ) {
    emit(state.copyWith(
      scheduleType: event.type,
      validationErrors: {},
    ));

    // Initialize free installments with advance if free type
    if (event.type == PaymentScheduleType.free) {
      final advanceItem = InstallmentItemModel(
        id: _uuid.v4(),
        index: 0,
        label: 'Avans',
        amount: 0.0,
        dueDate: DateTime.now(),
        isAdvance: true,
        status: InstallmentStatus.pending,
      );
      emit(state.copyWith(freeInstallments: [advanceItem]));
    }
  }

  void _onStartDateChanged(
    PaymentStartDateChanged event,
    Emitter<PaymentScheduleState> emit,
  ) {
    emit(state.copyWith(startDate: event.date));

    // Recalculate installments
    final calculated = _calculateInstallments(
      totalAmount: state.totalAmount,
      startDate: event.date,
      count: state.installmentCount,
      isAdvanceEnabled: state.isAdvanceEnabled,
      advanceAmount: state.advanceAmount,
    );
    emit(state.copyWith(calculatedInstallments: calculated));
  }

  void _onInstallmentCountChanged(
    PaymentInstallmentCountChanged event,
    Emitter<PaymentScheduleState> emit,
  ) {
    emit(state.copyWith(installmentCount: event.count));

    // Recalculate installments
    final calculated = _calculateInstallments(
      totalAmount: state.totalAmount,
      startDate: state.startDate,
      count: event.count,
      isAdvanceEnabled: state.isAdvanceEnabled,
      advanceAmount: state.advanceAmount,
    );
    emit(state.copyWith(calculatedInstallments: calculated));
  }

  void _onAdvanceToggled(
    PaymentAdvanceToggled event,
    Emitter<PaymentScheduleState> emit,
  ) {
    emit(state.copyWith(
      isAdvanceEnabled: event.isEnabled,
      advanceAmount: event.isEnabled ? state.advanceAmount : 0.0,
    ));

    // Recalculate installments
    final calculated = _calculateInstallments(
      totalAmount: state.totalAmount,
      startDate: state.startDate,
      count: state.installmentCount,
      isAdvanceEnabled: event.isEnabled,
      advanceAmount: event.isEnabled ? state.advanceAmount : 0.0,
    );
    emit(state.copyWith(calculatedInstallments: calculated));
  }

  void _onAdvanceAmountChanged(
    PaymentAdvanceAmountChanged event,
    Emitter<PaymentScheduleState> emit,
  ) {
    emit(state.copyWith(advanceAmount: event.amount));

    // Recalculate installments
    final calculated = _calculateInstallments(
      totalAmount: state.totalAmount,
      startDate: state.startDate,
      count: state.installmentCount,
      isAdvanceEnabled: state.isAdvanceEnabled,
      advanceAmount: event.amount,
    );
    emit(state.copyWith(calculatedInstallments: calculated));
  }

  void _onFreeInstallmentAdded(
    PaymentFreeInstallmentAdded event,
    Emitter<PaymentScheduleState> emit,
  ) {
    final newItem = InstallmentItemModel(
      id: _uuid.v4(),
      index: state.freeInstallments.length,
      label: '${state.freeInstallments.length}-qism',
      amount: 0.0,
      dueDate: DateTime.now(),
      isAdvance: false,
      status: InstallmentStatus.pending,
    );

    emit(state.copyWith(
      freeInstallments: [...state.freeInstallments, newItem],
    ));
  }

  void _onFreeInstallmentRemoved(
    PaymentFreeInstallmentRemoved event,
    Emitter<PaymentScheduleState> emit,
  ) {
    final updated = state.freeInstallments
        .where((item) => item.id != event.id)
        .toList();

    emit(state.copyWith(freeInstallments: updated));
  }

  void _onFreeInstallmentUpdated(
    PaymentFreeInstallmentUpdated event,
    Emitter<PaymentScheduleState> emit,
  ) {
    final updated = state.freeInstallments.map((item) {
      return item.id == event.item.id ? event.item : item;
    }).toList();

    emit(state.copyWith(freeInstallments: updated));
  }

  void _onScheduleSubmitted(
    PaymentScheduleSubmitted event,
    Emitter<PaymentScheduleState> emit,
  ) async {
    // Validate based on schedule type
    if (state.scheduleType == PaymentScheduleType.equal) {
      if (state.calculatedInstallments.isEmpty) {
        emit(state.copyWith(
          status: PaymentScheduleStatus.failure,
          errorMessage: 'Hisoblangan qismlar topilmadi',
        ));
        return;
      }
    } else if (state.scheduleType == PaymentScheduleType.free) {
      final totalFree = state.freeInstallments.fold<double>(
        0.0,
        (sum, item) => sum + item.amount,
      );

      if ((totalFree - state.totalAmount).abs() > 0.01) {
        emit(state.copyWith(
          status: PaymentScheduleStatus.failure,
          errorMessage: 'Qismlar yig\'indisi jami summaga teng emas',
        ));
        return;
      }
    }

    emit(state.copyWith(status: PaymentScheduleStatus.loading));

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(
      status: PaymentScheduleStatus.success,
      errorMessage: null,
    ));
  }

  void _onStepChanged(
    PaymentStepChanged event,
    Emitter<PaymentScheduleState> emit,
  ) {
    // Validate current step before proceeding
    final errors = _validateCurrentStep();

    if (errors.isNotEmpty) {
      emit(state.copyWith(validationErrors: errors));
      return;
    }

    // Calculate installments if moving to step 2 with equal type
    if (event.step == 2 && state.scheduleType == PaymentScheduleType.equal) {
      final calculated = _calculateInstallments(
        totalAmount: state.totalAmount,
        startDate: state.startDate,
        count: state.installmentCount,
        isAdvanceEnabled: state.isAdvanceEnabled,
        advanceAmount: state.advanceAmount,
      );
      emit(state.copyWith(
        currentStep: event.step,
        calculatedInstallments: calculated,
        validationErrors: {},
      ));
    } else {
      emit(state.copyWith(
        currentStep: event.step,
        validationErrors: {},
      ));
    }
  }

  void _onStepBack(
    PaymentStepBack event,
    Emitter<PaymentScheduleState> emit,
  ) {
    if (state.currentStep > 0) {
      emit(state.copyWith(
        currentStep: state.currentStep - 1,
        validationErrors: {},
      ));
    }
  }

  Map<String, String> _validateCurrentStep() {
    final errors = <String, String>{};

    switch (state.currentStep) {
      case 0: // Step 1: Basic info
        if (state.selectedPartner == null) {
          errors['partner'] = 'Hamkorni tanlang';
        }
        if (state.totalAmount <= 0) {
          errors['amount'] = 'Summani kiriting';
        }
        break;
      case 1: // Step 2: Schedule type
        if (state.scheduleType == null) {
          errors['type'] = 'Grafik turini tanlang';
        }
        break;
      case 2: // Step 3: Details (validated on submit)
        break;
    }

    return errors;
  }

  List<InstallmentItemModel> _calculateInstallments({
    required double totalAmount,
    required DateTime startDate,
    required int count,
    required bool isAdvanceEnabled,
    required double advanceAmount,
  }) {
    if (totalAmount <= 0) return [];

    final installments = <InstallmentItemModel>[];
    final remaining = totalAmount - (isAdvanceEnabled ? advanceAmount : 0.0);
    final installmentAmount = remaining / (isAdvanceEnabled ? count : count);

    // Add advance if enabled
    if (isAdvanceEnabled && advanceAmount > 0) {
      installments.add(
        InstallmentItemModel(
          id: _uuid.v4(),
          index: 0,
          label: 'Avans',
          amount: advanceAmount,
          dueDate: startDate,
          isAdvance: true,
          status: InstallmentStatus.pending,
        ),
      );
    }

    // Add regular installments
    for (int i = 0; i < count; i++) {
      final dueDate = DateTime(
        startDate.year,
        startDate.month + i + (isAdvanceEnabled ? 1 : 0),
        startDate.day,
      );

      installments.add(
        InstallmentItemModel(
          id: _uuid.v4(),
          index: isAdvanceEnabled ? i + 1 : i,
          label: '${i + 1}-qism',
          amount: installmentAmount,
          dueDate: dueDate,
          isAdvance: false,
          status: InstallmentStatus.pending,
        ),
      );
    }

    return installments;
  }
}
