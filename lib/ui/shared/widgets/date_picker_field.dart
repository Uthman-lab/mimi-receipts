import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/constants.dart';
import 'app_text_field.dart';
import '../../../core/utils/utils.dart';

class DatePickerField extends StatefulWidget {
  final String label;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateSelected;
  final String? Function(String?)? validator;

  const DatePickerField({
    super.key,
    required this.label,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.validator,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late TextEditingController _controller;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _controller = TextEditingController(
      text: _selectedDate != null ? DateFormatter.formatForDisplay(_selectedDate!) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(2000),
      lastDate: widget.lastDate ?? DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controller.text = DateFormatter.formatForDisplay(picked);
      });
      widget.onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: _controller,
      readOnly: true,
      onTap: () => _selectDate(context),
      suffixIcon: const Icon(Icons.calendar_today),
      validator: widget.validator,
    );
  }
}



