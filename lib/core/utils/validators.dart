import '../constants/app_strings.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.emailRequired;
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.emailInvalid;
    }
    
    return null;
  }

  // Institutional email validation
  static String? validateInstitutionalEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.emailRequired;
    }
    
    final emailValidation = validateEmail(value);
    if (emailValidation != null) {
      return emailValidation;
    }
    
    // List of common educational domains
    final educationalDomains = [
      '.edu',
      '.edu.mx',
      '.edu.co',
      '.edu.ar',
      '.ac.uk',
      '.edu.pe',
      '.edu.cl',
      '.edu.br',
      // Add more educational domains as needed
    ];
    
    final hasEducationalDomain = educationalDomains.any(
      (domain) => value.toLowerCase().contains(domain),
    );
    
    if (!hasEducationalDomain) {
      return AppStrings.institutionalEmailRequired;
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    
    if (value != password) {
      return AppStrings.passwordsNotMatch;
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'El nombre solo puede contener letras';
    }
    
    return null;
  }

  // Age validation
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'La edad es requerida';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'Ingresa una edad válida';
    }
    
    if (age < 16 || age > 65) {
      return 'La edad debe estar entre 16 y 65 años';
    }
    
    return null;
  }

  // Career validation
  static String? validateCareer(String? value) {
    if (value == null || value.isEmpty) {
      return 'La carrera es requerida';
    }
    
    if (value.trim().length < 3) {
      return 'La carrera debe tener al menos 3 caracteres';
    }
    
    return null;
  }

  // Semester validation
  static String? validateSemester(String? value) {
    if (value == null || value.isEmpty) {
      return 'El semestre es requerido';
    }
    
    final semester = int.tryParse(value);
    if (semester == null) {
      return 'Ingresa un semestre válido';
    }
    
    if (semester < 1 || semester > 20) {
      return 'El semestre debe estar entre 1 y 20';
    }
    
    return null;
  }

  // Bio validation
  static String? validateBio(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Bio is optional
    }
    
    if (value.length > 500) {
      return 'La biografía no puede exceder 500 caracteres';
    }
    
    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Ingresa un número de teléfono válido';
    }
    
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 10) {
      return 'El número de teléfono debe tener al menos 10 dígitos';
    }
    
    return null;
  }

  // Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  // Generic min length validation
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    
    if (value.length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }
    
    return null;
  }

  // Generic max length validation
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName no puede exceder $maxLength caracteres';
    }
    
    return null;
  }
}