import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/reservation.dart';
import '../providers/reservation_provider.dart';
import 'reservation_detail_screen.dart';
import '../widgets/reservation_card.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Kalender Reservasi',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, child) {
          if (!provider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final reservationsForSelectedDate =
              provider.getReservationsByDate(_selectedDate);

          return Column(
            children: [
              _buildCalendar(provider),
              Expanded(
                child: _buildReservationsList(
                  reservationsForSelectedDate,
                  context,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendar(ReservationProvider provider) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _getDaysInMonth(_selectedDate.year, _selectedDate.month),
            itemBuilder: (context, index) {
              final day = index + 1;
              final date = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                day,
              );
              final hasReservations =
                  provider.getReservationsByDate(date).isNotEmpty;
              final isSelected = _isSameDay(_selectedDate, date);
              final isToday = _isSameDay(DateTime.now(), date);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.deepPurple
                        : hasReservations
                            ? Colors.deepPurple.withOpacity(0.3)
                            : Colors.white,
                    border: isToday
                        ? Border.all(color: Colors.red, width: 2)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          day.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      if (hasReservations && !isSelected)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList(
    List<Reservation> reservations,
    BuildContext context,
  ) {
    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada reservasi pada\n${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ReservationDetailScreen(reservation: reservation),
              ),
            );
          },
          child: ReservationCard(reservation: reservation),
        );
      },
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  int _getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonth[month - 1];
  }
}
