import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  final List<Map<String, dynamic>> _dummyUsers = [
    {"name": "Nour B.", "email": "nour@example.com", "role": "Admin", "status": "Active"},
    {"name": "Ahmed M.", "email": "ahmed@djerba.com", "role": "Delivery", "status": "Active"},
    {"name": "Fatma K.", "email": "fatma@resto.com", "role": "Restaurant", "status": "Suspended"},
    {"name": "Sami R.", "email": "sami@customer.com", "role": "Customer", "status": "Active"},
    {"name": "Leila T.", "email": "leila@customer.com", "role": "Customer", "status": "Offline"},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Users Management", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                IconButton(
                  icon: const Icon(Icons.person_add, color: DjerbaTheme.primaryColor),
                  onPressed: () {},
                )
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: "Search users by name or email...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: ListView.separated(
                  itemCount: _dummyUsers.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey.withOpacity(0.1)),
                  itemBuilder: (context, index) {
                    final user = _dummyUsers[index];
                    final isSuspended = user['status'] == 'Suspended';
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: DjerbaTheme.primaryLight,
                        child: Text(user['name'][0], style: const TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${user['role']} • ${user['email']}", style: const TextStyle(fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSuspended ? DjerbaTheme.danger.withOpacity(0.1) : DjerbaTheme.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user['status'],
                              style: TextStyle(
                                color: isSuspended ? DjerbaTheme.danger : DjerbaTheme.success,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.more_vert, color: Colors.grey[400]),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
