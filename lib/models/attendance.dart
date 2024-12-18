class Attendance {
  final int employeeId;
  final String? checkInTime; // this can be null if toggle never on
  final String? checkOutTime;// this can be null if toggle never on
  final String? checkInStatus;// this can be null if checkintime null
  final String? checkOutStatus;// this can be null if checkintime null
  final List<String> workTypeList;// this can be null if checkintime null
  final bool  status;
  final String date;
  final String? workduration; // Ensure this field exists

  Attendance({
    required this.employeeId,
    required this.checkInTime,
    required this.checkOutTime,
    required this.status,
    required this.checkInStatus,
    required this.checkOutStatus,
    required this.workTypeList,
    required this.date,
    required this.workduration,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      employeeId: json['employeeId'] as int,
      checkInTime: json['checkInTime'] as String?,
      checkOutTime: json['checkOutTime'] as String?,
      checkInStatus: json['checkInStatus'] as String?,
      checkOutStatus: json['checkOutStatus'] as String?,
      workTypeList: (json['workTypeList'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      status: json['status'],
      date: json['date'],
      workduration:json['workduration'] as String?,
    );
  }
}
