// models/medical_record.dart
class MedicalRecord {
  final int? recordId;
  final int patientUserId;
  final int nutritionistUserId;
  final int appointmentId;
  final String healthcareFacility;
  final DateTime serviceDate;
  final String residenceLocation;
  final String familyNucleus;
  final String occupation;
  final String educationLevel;
  final String maritalStatus;
  final String religion;
  final String idNumber;
  final String previousDiagnosis;
  final String illnessDuration;
  final String recentDiagnosis;
  final String familyHistory;
  final DateTime creationDate;

  MedicalRecord({
    this.recordId,
    required this.patientUserId,
    required this.nutritionistUserId,
    required this.appointmentId,
    required this.healthcareFacility,
    required this.serviceDate,
    required this.residenceLocation,
    required this.familyNucleus,
    required this.occupation,
    required this.educationLevel,
    required this.maritalStatus,
    required this.religion,
    required this.idNumber,
    required this.previousDiagnosis,
    required this.illnessDuration,
    required this.recentDiagnosis,
    required this.familyHistory,
    required this.creationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'record_id': recordId,
      'patients_users_user_id': patientUserId,
      'nutritionists_users_user_id': nutritionistUserId,
      'appointments_appointments_id': appointmentId,
      'healthcare_facility': healthcareFacility,
      'service_date': serviceDate.toIso8601String(),
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
      'creation_date': creationDate.toIso8601String(),
    };
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      recordId: map['record_id'],
      patientUserId: map['patients_users_user_id'],
      nutritionistUserId: map['nutritionists_users_user_id'],
      appointmentId: map['appointments_appointments_id'],
      healthcareFacility: map['healthcare_facility'],
      serviceDate: DateTime.parse(map['service_date']),
      residenceLocation: map['residence_location'],
      familyNucleus: map['family_nucleus'],
      occupation: map['occupation'],
      educationLevel: map['education_level'],
      maritalStatus: map['marital_status'],
      religion: map['religion'],
      idNumber: map['id_number'],
      previousDiagnosis: map['previous_diagnosis'],
      illnessDuration: map['illness_duration'],
      recentDiagnosis: map['recent_diagnosis'],
      familyHistory: map['family_history'],
      creationDate: DateTime.parse(map['creation_date']),
    );
  }
}
