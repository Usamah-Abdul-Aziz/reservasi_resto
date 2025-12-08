import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/reservation.dart';
import '../providers/reservation_provider.dart';
import '../providers/table_provider.dart';
import '../providers/menu_provider.dart';

class NewReservationScreen extends StatefulWidget {
  final Reservation? reservationToEdit;

  const NewReservationScreen({super.key, this.reservationToEdit});

  @override
  State<NewReservationScreen> createState() => _NewReservationScreenState();
}

class _NewReservationScreenState extends State<NewReservationScreen> {
  late TextEditingController _guestNameController;
  late TextEditingController _guestEmailController;
  late TextEditingController _guestPhoneController;
  late TextEditingController _specialRequestsController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _numberOfGuests = 1;
  List<Map<String, dynamic>> _orderedItems = []; // Menu items yang dipesan

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _guestNameController = TextEditingController(
      text: widget.reservationToEdit?.guestName ?? '',
    );
    _guestEmailController = TextEditingController(
      text: widget.reservationToEdit?.guestEmail ?? '',
    );
    _guestPhoneController = TextEditingController(
      text: widget.reservationToEdit?.guestPhone ?? '',
    );
    _specialRequestsController = TextEditingController(
      text: widget.reservationToEdit?.specialRequests ?? '',
    );

    if (widget.reservationToEdit != null) {
      _selectedDate = widget.reservationToEdit!.reservationDate;
      _selectedTime = widget.reservationToEdit!.reservationTime;
      _numberOfGuests = widget.reservationToEdit!.numberOfGuests;
    }
  }

  @override
  void dispose() {
    _guestNameController.dispose();
    _guestEmailController.dispose();
    _guestPhoneController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitReservation() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tanggal reservasi')),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih waktu reservasi')),
      );
      return;
    }

    // Cari dan assign tabel otomatis
    final tableProvider = context.read<TableProvider>();
    
    // Pastikan TableProvider sudah diinisialisasi
    if (!tableProvider.isInitialized) {
      // Tunggu beberapa saat untuk inisialisasi
      Future.delayed(const Duration(milliseconds: 500), () {
        // Cek lagi setelah delay
        if (!tableProvider.isInitialized) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sistem sedang memuat data meja, silakan coba lagi')),
          );
          return;
        }
        // Coba submit lagi
        _submitReservation();
      });
      return;
    }
    
    final availableTable = tableProvider.findAvailableTable(_numberOfGuests);

    if (availableTable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada meja yang tersedia untuk jumlah tamu ini')),
      );
      return;
    }

    final reservation = Reservation(
      id: widget.reservationToEdit?.id,
      guestName: _guestNameController.text,
      guestEmail: _guestEmailController.text,
      guestPhone: _guestPhoneController.text,
      reservationDate: _selectedDate!,
      reservationTime: _selectedTime!,
      numberOfGuests: _numberOfGuests,
      specialRequests: _specialRequestsController.text,
      status: widget.reservationToEdit?.status ?? ReservationStatus.pending,
      tableId: availableTable.id, // Assign tabel ke reservasi
      orderedItems: _orderedItems, // Simpan menu items yang dipesan
    );

    final provider = context.read<ReservationProvider>();

    if (widget.reservationToEdit != null) {
      // Jika edit, lepas tabel lama jika ada dan assign yang baru
      if (widget.reservationToEdit!.tableId != null &&
          widget.reservationToEdit!.tableId != availableTable.id) {
        tableProvider.releaseTable(widget.reservationToEdit!.tableId!);
      }
      provider.updateReservation(reservation);
      // Reserve table baru jika belum
      if (widget.reservationToEdit!.tableId != availableTable.id) {
        tableProvider.reserveTable(availableTable.id, reservation.id);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservasi berhasil diperbarui')),
      );
    } else {
      // Jika baru, simpan reservasi dan ubah status tabel
      provider.addReservation(reservation);
      // Reserve table untuk reservasi ini
      tableProvider.reserveTable(availableTable.id, reservation.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reservasi berhasil dibuat - Meja ${availableTable.tableNumber}'),
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: Text(
          widget.reservationToEdit != null
              ? 'Edit Reservasi'
              : 'Reservasi Baru',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informasi Tamu'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _guestNameController,
                label: 'Nama Tamu',
                icon: Icons.person,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Nama tamu tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _guestEmailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value!.contains('@')) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _guestPhoneController,
                label: 'Nomor Telepon',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Detail Reservasi'),
              const SizedBox(height: 12),
              _buildDateTimeField(context),
              const SizedBox(height: 12),
              _buildGuestCountField(),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _specialRequestsController,
                label: 'Permintaan Khusus (Opsional)',
                icon: Icons.notes,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Pilih Menu (Opsional)'),
              const SizedBox(height: 12),
              _buildMenuSelectionField(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitReservation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.reservationToEdit != null
                        ? 'Perbarui Reservasi'
                        : 'Buat Reservasi',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildDateTimeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.deepPurple),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDate != null
                              ? DateFormat('dd MMMM yyyy', 'id_ID')
                                  .format(_selectedDate!)
                              : 'Pilih Tanggal',
                          style: TextStyle(
                            color: _selectedDate != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.deepPurple),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedTime != null
                              ? _selectedTime!.format(context)
                              : 'Pilih Jam',
                          style: TextStyle(
                            color: _selectedTime != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGuestCountField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Row(
        children: [
          const Icon(Icons.people, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Jumlah Tamu: $_numberOfGuests',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: _numberOfGuests > 1
                      ? () {
                          setState(() {
                            _numberOfGuests--;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.remove),
                  iconSize: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    _numberOfGuests.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _numberOfGuests < 20
                      ? () {
                          setState(() {
                            _numberOfGuests++;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.add),
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSelectionField() {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_orderedItems.isEmpty)
                Row(
                  children: [
                    const Icon(Icons.restaurant_menu, color: Colors.deepPurple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Menu yang dipesan: Belum ada',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showMenuSelectionDialog(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: const Text(
                        'Pilih',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Menu yang dipesan: ${_orderedItems.length} item',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _showMenuSelectionDialog(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            backgroundColor: Colors.deepPurple,
                          ),
                          child: const Text(
                            'Ubah',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...(_orderedItems.map((item) {
                      final itemName = item['name'] as String? ?? 'Unknown';
                      final itemPrice = item['price'] as num? ?? 0;
                      final quantity = item['quantity'] as int? ?? 1;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '$itemName x$quantity',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Text(
                              'Rp${(itemPrice * quantity).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  void _showMenuSelectionDialog(BuildContext context) {
    final menuProvider = context.read<MenuProvider>();
    final tempSelectedItems = Map<String, dynamic>.from(
      Map.fromEntries(
        _orderedItems.map((item) {
          final name = item['name'] as String;
          return MapEntry(name, item['quantity'] as int? ?? 1);
        }),
      ),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Pilih Menu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<MenuProvider>(
                  builder: (context, provider, _) {
                    return Column(
                      children: provider.menuItems.map((item) {
                        final quantity = tempSelectedItems[item.name] ?? 0;
                        final isSelected = quantity > 0;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  isSelected ? Colors.deepPurple : Colors.grey,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      'Rp${item.price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: isSelected
                                          ? () {
                                              setDialogState(() {
                                                if (quantity > 1) {
                                                  tempSelectedItems[
                                                      item.name] = quantity - 1;
                                                } else {
                                                  tempSelectedItems
                                                      .remove(item.name);
                                                }
                                              });
                                            }
                                          : null,
                                      icon: const Icon(Icons.remove),
                                      iconSize: 16,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    if (isSelected)
                                      SizedBox(
                                        width: 24,
                                        child: Center(
                                          child: Text(
                                            quantity.toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    IconButton(
                                      onPressed: () {
                                        setDialogState(() {
                                          tempSelectedItems[item.name] =
                                              (tempSelectedItems[
                                                      item.name] as int? ??
                                                  0) +
                                              1;
                                        });
                                      },
                                      icon: const Icon(Icons.add),
                                      iconSize: 16,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _orderedItems = [];
                  for (final entry in tempSelectedItems.entries) {
                    final item = menuProvider.getMenuItemByName(entry.key);
                    if (item != null) {
                      _orderedItems.add({
                        'id': item.id,
                        'name': item.name,
                        'price': item.price,
                        'quantity': entry.value,
                      });
                    }
                  }
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
