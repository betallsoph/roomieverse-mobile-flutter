String? _toStringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value.runtimeType.toString() == 'Timestamp') {
    return (value as dynamic).toDate().toIso8601String();
  }
  return value.toString();
}

class LifestylePreferences {
  final List<String>? schedule;
  final List<String>? cleanliness;
  final List<String>? habits;
  final String? otherHabits;

  LifestylePreferences({
    this.schedule,
    this.cleanliness,
    this.habits,
    this.otherHabits,
  });

  factory LifestylePreferences.fromJson(Map<String, dynamic> json) {
    return LifestylePreferences(
      schedule: (json['schedule'] as List?)?.cast<String>(),
      cleanliness: (json['cleanliness'] as List?)?.cast<String>(),
      habits: (json['habits'] as List?)?.cast<String>(),
      otherHabits: json['otherHabits'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (schedule != null) 'schedule': schedule,
        if (cleanliness != null) 'cleanliness': cleanliness,
        if (habits != null) 'habits': habits,
        if (otherHabits != null) 'otherHabits': otherHabits,
      };
}

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String? gender;
  final String? birthYear;
  final String? occupation;
  final LifestylePreferences? lifestyle;
  final String? role;
  final String? createdAt;
  final String? updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.gender,
    this.birthYear,
    this.occupation,
    this.lifestyle,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      photoURL: json['photoURL'] as String?,
      gender: json['gender'] as String?,
      birthYear: json['birthYear'] as String?,
      occupation: json['occupation'] as String?,
      lifestyle: json['lifestyle'] != null
          ? LifestylePreferences.fromJson(
              json['lifestyle'] as Map<String, dynamic>)
          : null,
      role: json['role'] as String?,
      createdAt: _toStringOrNull(json['createdAt']),
      updatedAt: _toStringOrNull(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        if (photoURL != null) 'photoURL': photoURL,
        if (gender != null) 'gender': gender,
        if (birthYear != null) 'birthYear': birthYear,
        if (occupation != null) 'occupation': occupation,
        if (lifestyle != null) 'lifestyle': lifestyle!.toJson(),
        if (role != null) 'role': role,
      };

  UserProfile copyWith({
    String? displayName,
    String? photoURL,
    String? gender,
    String? birthYear,
    String? occupation,
    LifestylePreferences? lifestyle,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
      occupation: occupation ?? this.occupation,
      lifestyle: lifestyle ?? this.lifestyle,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
