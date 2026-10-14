import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/providers/admin_provider.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("User Management", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: DjerbaTheme.primaryColor,
                      unselectedLabelColor: DjerbaTheme.textSecondary,
                      indicatorColor: DjerbaTheme.primaryColor,
                      tabs: [
                        Tab(text: "Clients"),
                        Tab(text: "Drivers"),
                        Tab(text: "Restaurants"),
                      ],
                    ),
                    Expanded(
                      child: usersAsync.when(
                        data: (users) {
                          final clients = users.where((u) => u['role'] == 'client').toList();
                          final drivers = users.where((u) => u['role'] == 'driver').toList();
                          final restaurants = users.where((u) => u['role'] == 'admin').toList();

                          return TabBarView(
                            children: [
                              _buildUsersTable(
                                ["Name", "Email", "Role", "Status"],
                                clients.map((c) => _buildDataRow([c['name'] ?? 'Unknown', c['email'] ?? 'Unknown', c['role'], "Active"], DjerbaTheme.success)).toList(),
                              ),
                              _buildUsersTable(
                                ["Name", "Email", "Role", "Status"],
                                drivers.map((d) => _buildDataRow([d['name'] ?? 'Unknown', d['email'] ?? 'Unknown', d['role'], "Active"], DjerbaTheme.success)).toList(),
                              ),
                              _buildUsersTable(
                                ["Restaurant Name", "Email", "Role", "Status"],
                                restaurants.map((r) => _buildDataRow([r['name'] ?? 'Unknown', r['email'] ?? 'Unknown', r['role'], "Active"], DjerbaTheme.success)).toList(),
                              ),
                            ],
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Center(child: Text('Error: \$err')),
                      ),
                    ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTable(List<String> headers, List<DataRow> rows) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        DataTable(
          headingTextStyle: const TextStyle(color: DjerbaTheme.textSecondary, fontWeight: FontWeight.bold),
          dataRowMinHeight: 60,
          dataRowMaxHeight: 60,
          columns: headers.map((h) => DataColumn(label: Text(h))).toList()..add(const DataColumn(label: Text('Actions'))),
          rows: rows,
        ),
      ],
    );
  }

  DataRow _buildDataRow(List<String> cells, Color statusColor) {
    final List<DataCell> rowCells = cells.asMap().entries.map((entry) {
      int idx = entry.key;
      String val = entry.value;
      if (idx == cells.length - 1) {
        return DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              val,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        );
      }
      return DataCell(Text(val, style: idx == 0 ? const TextStyle(fontWeight: FontWeight.bold) : null));
    }).toList();

    // Actions cell
    rowCells.add(
      DataCell(
        Row(
          children: [
            IconButton(icon: const Icon(Icons.edit, color: DjerbaTheme.textSecondary), onPressed: () {}),
            IconButton(icon: const Icon(Icons.block, color: DjerbaTheme.danger), onPressed: () {}),
          ],
        ),
      ),
    );

    return DataRow(cells: rowCells);
  }
}
