import 'package:flutter/material.dart';
import '../models/employee.dart'; // Import Employee model

class ShowMyInfoWidget extends StatelessWidget {
  final Employee employee;

  const ShowMyInfoWidget({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.portrait, size: 60),
                onPressed: () {
                  // Handle portrait button action if needed
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: const TextStyle(
                        fontSize: 24, // Large font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          employee.department,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const VerticalDivider(
                          thickness: 1,
                          width: 20,
                          color: Colors.black54,
                        ),
                        Text(
                          employee.position,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          ListTile(
            title: const Text('전화번호'),
            trailing: Text(
              '${employee.phone.substring(0, 3)}-${employee.phone.substring(3, 7)}-${employee.phone.substring(7, employee.phone.length)}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          ListTile(
            title: const Text('이메일'),
            trailing: Text(employee.email, style: const TextStyle(fontSize: 16)),
          ),
          ListTile(
            title: const Text('입사일'),
            trailing: Text(
              employee.joindate,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          ListTile(
            title: const Text('근무지'),
            trailing: Text(
              employee.workplace,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          ListTile(
            title: const Text('근무시간'),
            trailing: Text(
              employee.workhour,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          ListTile(
            title: const Text('승인자'),
            trailing: Text(
              employee.supervisorName,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
