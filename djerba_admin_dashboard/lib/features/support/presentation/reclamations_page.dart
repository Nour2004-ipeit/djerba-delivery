import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class ReclamationsPage extends StatelessWidget {
  const ReclamationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Support Tickets", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
                label: const Text("Filter Open"),
              ),
            ],
          ),
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
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        _buildTicketTable([
                          "Ticket ID",
                          "Date",
                          "User",
                          "Role",
                          "Subject",
                          "Status",
                          "Action",
                        ], [
                          _buildDataRow(["#1042", "Oct 12, 10:30", "John Doe", "Client", "Order never arrived"], DjerbaTheme.danger, "Open"),
                          _buildDataRow(["#1041", "Oct 12, 09:15", "Ahmed T.", "Driver", "App crashed on delivery"], DjerbaTheme.warning, "Pending"),
                          _buildDataRow(["#1040", "Oct 11, 20:00", "Pizza Express", "Restaurant", "Payment delayed"], DjerbaTheme.success, "Resolved"),
                          _buildDataRow(["#1039", "Oct 11, 14:20", "Emma Davis", "Client", "Missing drink"], DjerbaTheme.success, "Resolved"),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketTable(List<String> headers, List<DataRow> rows) {
    return DataTable(
      headingTextStyle: const TextStyle(color: DjerbaTheme.textSecondary, fontWeight: FontWeight.bold),
      dataRowMinHeight: 60,
      dataRowMaxHeight: 60,
      columns: headers.map((h) => DataColumn(label: Text(h))).toList(),
      rows: rows,
    );
  }

  DataRow _buildDataRow(List<String> cells, Color statusColor, String statusText) {
    final List<DataCell> rowCells = cells.map((val) => DataCell(Text(val, style: const TextStyle(fontWeight: FontWeight.w500)))).toList();
    
    // Status Badge
    rowCells.add(
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );

    // Action Button
    rowCells.add(
      DataCell(
        TextButton(
          onPressed: () {},
          child: const Text("View Ticket"),
        ),
      ),
    );

    return DataRow(cells: rowCells);
  }
}
