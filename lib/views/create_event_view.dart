import 'package:flutter/material.dart';

class CreateEventView extends StatelessWidget {
  const CreateEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    "Create Event",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 50),
                ],
              ),
              const SizedBox(height: 20),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "Personal Event",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.group, size: 18),
                              SizedBox(width: 6),
                              Text("Circle Event"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Event title field
              TextField(
                decoration: InputDecoration(
                  labelText: "Event Title",
                  hintText: "e.g., Team Lunch",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _buildSelector(title: "Date", value: "May 28, 2024"),
              _buildSelector(title: "Start time", value: "2:00 PM"),
              _buildSelector(title: "End time", value: "3:00 PM"),

              const SizedBox(height: 10),

              // All day toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "All-day",
                    style: TextStyle(fontSize: 16),
                  ),
                  Switch(value: false, onChanged: (_) {}),
                ],
              ),

              const SizedBox(height: 20),

              // Conflict Warning box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFC98B)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "This event overlaps with 'Design Sync' (2:30 PM - 3:30 PM). Your RSVP for that event will be set to 'Not Going'.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildInputTile(icon: Icons.location_on_outlined, label: "Add location"),
              const SizedBox(height: 10),
              _buildInputTile(icon: Icons.note_outlined, label: "Add notes"),

              const SizedBox(height: 20),

              // Color tag selector
              const Text(
                "Color Tag",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _colorCircle(Colors.red, selected: true),
                  _colorCircle(Colors.blue),
                  _colorCircle(Colors.green),
                  _colorCircle(Colors.yellow),
                  _colorCircle(Colors.purple),
                ],
              ),

              const SizedBox(height: 20),

              _buildSelector(title: "Reminder", value: "15 min before"),

              const SizedBox(height: 30),

              // Create button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Create Event",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelector({required String title, required String value}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              Text(value, style: const TextStyle(color: Colors.blue)),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputTile({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _colorCircle(Color color, {bool selected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: selected ? const EdgeInsets.all(3) : EdgeInsets.zero,
      decoration: selected
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
            )
          : null,
      child: CircleAvatar(radius: 12, backgroundColor: color),
    );
  }
}