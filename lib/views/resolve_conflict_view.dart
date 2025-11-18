import 'package:flutter/material.dart';

class ResolveConflictView extends StatelessWidget {
  const ResolveConflictView({super.key});

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
              const SizedBox(height: 10),

              // Drag Bar
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Resolve Schedule Conflict",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "You have 2 overlapping events:",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 25),

              _eventCard(
                title: "Doctor Appointment",
                type: "Personal Event",
                icon: Icons.calendar_today,
                date: "Oct 26, 2:00 PM - 3:00 PM",
                location: "123 Health St, Medville",
                actions: [
                  _redButton("Cancel This Event"),
                ],
                sideColor: Colors.grey,
              ),

              const SizedBox(height: 16),

              _eventCard(
                title: "Family BBQ",
                type: "Circle Event",
                icon: Icons.group,
                date: "Oct 26, 2:30 PM - 5:00 PM",
                location: "Mom's House",
                rsvpTag: "Your RSVP: Maybe",
                rsvpColor: Colors.orange,
                actions: [
                  _outlineButton("Change to Maybe"),
                  const SizedBox(width: 10),
                  _blueButton("Change to Going"),
                ],
                sideColor: Colors.blue,
              ),

              const SizedBox(height: 25),

              // Keep both
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade400),
                    color: Colors.white,
                  ),
                  child: const Text(
                    "Keep Both As-Is",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // View both in calendar
              Center(
                child: Text(
                  "View Both in Calendar",
                  style: TextStyle(fontSize: 16, color: Colors.blue.shade700),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventCard({
    required String title,
    required String type,
    required IconData icon,
    required String date,
    required String location,
    String? rsvpTag,
    Color? rsvpColor,
    required List<Widget> actions,
    required Color sideColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 120,
            decoration: BoxDecoration(
              color: sideColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 22, color: Colors.grey[700]),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(type, style: const TextStyle(color: Colors.black45)),
                const SizedBox(height: 10),

                if (rsvpTag != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: rsvpColor!.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      rsvpTag,
                      style: TextStyle(color: rsvpColor, fontWeight: FontWeight.w600),
                    ),
                  ),

                if (rsvpTag != null) const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18),
                    const SizedBox(width: 8),
                    Text(date),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(location),
                  ],
                ),

                const SizedBox(height: 16),
                Row(children: actions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _redButton(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _blueButton(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF596CFF), Color(0xFF3A58FF)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _outlineButton(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}