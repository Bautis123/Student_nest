class Validators {
  const Validators._();

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? phone(String? value) {
    final requiredMessage = required(value, fieldName: 'Phone number');
    if (requiredMessage != null) return requiredMessage;
    if (value!.trim().length < 9) return 'Enter a valid phone number';
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!text.contains('@') || !text.contains('.')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredMessage = required(value, fieldName: 'Password');
    if (requiredMessage != null) return requiredMessage;
    if (value!.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? number(String? value, {String fieldName = 'Number'}) {
    final requiredMessage = required(value, fieldName: fieldName);
    if (requiredMessage != null) return requiredMessage;
    if (num.tryParse(value!.trim()) == null) return 'Enter a valid number';
    return null;
  }
}
