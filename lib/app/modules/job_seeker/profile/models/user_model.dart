class UserModel {
  final String uid;
  final String email;
  final String role;
  final String name;
  final String title;
  final String university;
  final String location;
  final String about;
  final String profileImage;
  final String coverImage;
  final List<EducationModel> education;
  final List<ExperienceModel> experience;
  final List<String> skills;
  final List<LanguageModel> languages; // ← جديد
  final List<LinkModel> links; // ← جديد

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.name = '',
    this.title = '',
    this.university = '',
    this.location = '',
    this.about = '',
    this.profileImage = '',
    this.coverImage = '',
    this.education = const [],
    this.experience = const [],
    this.skills = const [],
    this.languages = const [], // ← جديد
    this.links = const [], // ← جديد
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'jobSeeker',
      name: map['name'] ?? '',
      title: map['title'] ?? '',
      university: map['university'] ?? '',
      location: map['location'] ?? '',
      about: map['about'] ?? '',
      profileImage: map['profileImage'] ?? '',
      coverImage: map['coverImage'] ?? '',
      education: (map['education'] as List<dynamic>? ?? [])
          .map((e) => EducationModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      experience: (map['experience'] as List<dynamic>? ?? [])
          .map((e) => ExperienceModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      skills: List<String>.from(map['skills'] ?? []),
      languages:
          (map['languages'] as List<dynamic>? ?? []) // ← جديد
              .map((e) => LanguageModel.fromMap(e as Map<String, dynamic>))
              .toList(),
      links:
          (map['links'] as List<dynamic>? ?? []) // ← جديد
              .map((e) => LinkModel.fromMap(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      'title': title,
      'university': university,
      'location': location,
      'about': about,
      'profileImage': profileImage,
      'coverImage': coverImage,
      'education': education.map((e) => e.toMap()).toList(),
      'experience': experience.map((e) => e.toMap()).toList(),
      'skills': skills,
      'languages': languages.map((e) => e.toMap()).toList(), // ← جديد
      'links': links.map((e) => e.toMap()).toList(), // ← جديد
    };
  }

  UserModel copyWith({
    String? name,
    String? title,
    String? university,
    String? location,
    String? about,
    String? profileImage,
    String? coverImage,
    List<EducationModel>? education,
    List<ExperienceModel>? experience,
    List<String>? skills,
    List<LanguageModel>? languages, // ← جديد
    List<LinkModel>? links, // ← جديد
  }) {
    return UserModel(
      uid: uid,
      email: email,
      role: role,
      name: name ?? this.name,
      title: title ?? this.title,
      university: university ?? this.university,
      location: location ?? this.location,
      about: about ?? this.about,
      profileImage: profileImage ?? this.profileImage,
      coverImage: coverImage ?? this.coverImage,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages, // ← جديد
      links: links ?? this.links, // ← جديد
    );
  }
}

// ─── Education Model ──────────────────────────────────────
class EducationModel {
  final String school;
  final String degree;
  final String field;
  final String startYear;
  final String endYear;

  EducationModel({
    required this.school,
    required this.degree,
    required this.field,
    required this.startYear,
    required this.endYear,
  });

  factory EducationModel.fromMap(Map<String, dynamic> map) {
    return EducationModel(
      school: map['school'] ?? '',
      degree: map['degree'] ?? '',
      field: map['field'] ?? '',
      startYear: map['startYear'] ?? '',
      endYear: map['endYear'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'school': school,
    'degree': degree,
    'field': field,
    'startYear': startYear,
    'endYear': endYear,
  };
}

// ─── Experience Model ─────────────────────────────────────
class ExperienceModel {
  final String company;
  final String position;
  final String startDate;
  final String endDate;
  final String description;

  ExperienceModel({
    required this.company,
    required this.position,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  factory ExperienceModel.fromMap(Map<String, dynamic> map) {
    return ExperienceModel(
      company: map['company'] ?? '',
      position: map['position'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'company': company,
    'position': position,
    'startDate': startDate,
    'endDate': endDate,
    'description': description,
  };
}

// ─── Language Model ───────────────────────────────────────
class LanguageModel {
  final String name;
  final String level; // Beginner / Intermediate / Fluent / Native

  LanguageModel({required this.name, required this.level});

  factory LanguageModel.fromMap(Map<String, dynamic> map) {
    return LanguageModel(name: map['name'] ?? '', level: map['level'] ?? '');
  }

  Map<String, dynamic> toMap() => {'name': name, 'level': level};
}

// ─── Link Model ───────────────────────────────────────────
class LinkModel {
  final String type; // LinkedIn / GitHub / Portfolio / Other
  final String url;

  LinkModel({required this.type, required this.url});

  factory LinkModel.fromMap(Map<String, dynamic> map) {
    return LinkModel(type: map['type'] ?? '', url: map['url'] ?? '');
  }

  Map<String, dynamic> toMap() => {'type': type, 'url': url};
}
