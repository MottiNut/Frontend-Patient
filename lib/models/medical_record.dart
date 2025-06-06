// lib/models/medical_record.dart
class MedicalRecord {
  final int recordId;
  final int patientsUsersUserId;
  final int nutritionistsUsersUserId;
  final int appointmentsAppointmentsId;
  final String healthcareFacility;
  final String serviceDate;
  final String residenceLocation;
  final String familyNucleus;
  final String occupation;
  final String educationLevel;
  final String maritalStatus;
  final String religion;
  final String idNumber;
  final String? previousDiagnosis;
  final String? illnessDuration;
  final String? recentDiagnosis;
  final String? familyHistory;
  final String creationDate;

  MedicalRecord({
    required this.recordId,
    required this.patientsUsersUserId,
    required this.nutritionistsUsersUserId,
    required this.appointmentsAppointmentsId,
    required this.healthcareFacility,
    required this.serviceDate,
    required this.residenceLocation,
    required this.familyNucleus,
    required this.occupation,
    required this.educationLevel,
    required this.maritalStatus,
    required this.religion,
    required this.idNumber,
    this.previousDiagnosis,
    this.illnessDuration,
    this.recentDiagnosis,
    this.familyHistory,
    required this.creationDate,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      recordId: json['record_id'] ?? 0,
      patientsUsersUserId: json['patients_users_user_id'] ?? 0,
      nutritionistsUsersUserId: json['nutritionists_users_user_id'] ?? 0,
      appointmentsAppointmentsId: json['appointments_appointments_id'] ?? 0,
      healthcareFacility: json['healthcare_facility'] ?? '',
      serviceDate: json['service_date'] ?? '',
      residenceLocation: json['residence_location'] ?? '',
      familyNucleus: json['family_nucleus'] ?? '',
      occupation: json['occupation'] ?? '',
      educationLevel: json['education_level'] ?? '',
      maritalStatus: json['marital_status'] ?? '',
      religion: json['religion'] ?? '',
      idNumber: json['id_number'] ?? '',
      previousDiagnosis: json['previous_diagnosis'],
      illnessDuration: json['illness_duration'],
      recentDiagnosis: json['recent_diagnosis'],
      familyHistory: json['family_history'],
      creationDate: json['creation_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'record_id': recordId,
      'patients_users_user_id': patientsUsersUserId,
      'nutritionists_users_user_id': nutritionistsUsersUserId,
      'appointments_appointments_id': appointmentsAppointmentsId,
      'healthcare_facility': healthcareFacility,
      'service_date': serviceDate,
      'residence_location': residenceLocation,
      'family_nucleus': familyNucleus,
      'occupation': occupation,
      'education_level': educationLevel,
      'marital_status': maritalStatus,
      'religion': religion,
      'id_number': idNumber,
      'previous_diagnosis': previousDiagnosis,
      'illness_duration': illnessDuration,
      'recent_diagnosis': recentDiagnosis,
      'family_history': familyHistory,
      'creation_date': creationDate,
    };
  }
}

class MedicalRecordCreate {
  final int patientsUsersUserId;
  final int nutritionistsUsersUserId;
  final int appointmentsAppointmentsId;
  final String healthcareFacility;
  final String serviceDate;
  final String residenceLocation;
  final String familyNucleus;
  final String occupation;
  final String educationLevel;
  final String maritalStatus;
  final String religion;
  final String idNumber;
  final String? previousDiagnosis;
  final String? illnessDuration;
  final String? recentDiagnosis;
  final String? familyHistory;

  MedicalRecordCreate({
    required this.patientsUsersUserId,
    required this.nutritionistsUsersUserId,
    required this.appointmentsAppointmentsId,
    required this.healthcareFacility,
    required this.serviceDate,
    required this.residenceLocation,
    required this.familyNucleus,
    required this.occupation,
    required this.educationLevel,
    required this.maritalStatus,
    required this.religion,
    required this.idNumber,
    this.previousDiagnosis,
    this.illnessDuration,
    this.recentDiagnosis,
    this.familyHistory,
  });

  Map<String, dynamic> toJson() {
    return {
      'patients_users_user_id': patientsUsersUserId,
      'nutritionists_users_user_id': nutritionistsUsersUserId,
      'appointments_appointments_id': appointmentsAppointmentsId,
      'healthcare_facility': healthcareFacility,
      'service_date': serviceDate,
      'residence_location': residenceLocation,
      'family_nucleus': familyNucleus,
      'occupation': occupation,
      'education_level': educationLevel,
      'marital_status': maritalStatus,
      'religion': religion,
      'id_number': idNumber,
      'previous_diagnosis': previousDiagnosis,
      'illness_duration': illnessDuration,
      'recent_diagnosis': recentDiagnosis,
      'family_history': familyHistory,
    };
  }
}