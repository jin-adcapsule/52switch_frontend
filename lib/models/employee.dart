//Employee model can handle the response from the GraphQL API.
class Employee {
  final int employeeId;
  final String name;
  final String position;
  final String department;
  final String email; // Ensure this field exists
  final String phone; // Ensure this field exists
  final String joindate; // Ensure this field exists
  final String workplace; // Ensure this field exists
  final String workhour; // Ensure this field exists
  final String supervisorName;
  final int? dayoffRemaining;// Make nullable

  Employee({
    required this.employeeId,
    required this.name,
    required this.position,
    required this.department,
    required this.email, // Optional field
    required this.phone, // Optional field
    required this.joindate, // Optional field
    required this.workplace, // Optional field
    required this.workhour, // Optional field
    required this.supervisorName, // Optional field
    this.dayoffRemaining,// Handle nullable field
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employeeId'] as int,
      name: json['name'],
      position: json['position'],
      email: json['email'], // Ensure this is parsed
      phone: json['phone'], // Ensure this is parsed
      joindate: json['joindate'], // Ensure this is parsed

      department: json['department'],
      supervisorName: json['supervisorName'], // Ensure this is parsed

      workplace: json['workplace'], // Ensure this is parsed
      workhour: json['workhour'], // Ensure this is parsed

      dayoffRemaining: json['dayoffRemaining'] as int?,

    );
  }
}
