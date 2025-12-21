import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

bool checkFormBuilder({required GlobalKey<FormBuilderState> formKey, required Map<String, dynamic> initialValues}) {
  formKey.currentState!.save();

  final currentValues = formKey.currentState?.value ??{};

  bool isCurrentValuesEmpty = currentValues.values.every((value) => value == null || value == "" || (value is List && value.isEmpty));
  final normalizedCurrentValues = isCurrentValuesEmpty ? {} : currentValues;
  final bool hasChanged = !const DeepCollectionEquality().equals(initialValues, normalizedCurrentValues);
  return hasChanged;
}
