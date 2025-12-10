import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'constants/app_constants.dart';
import 'screens/role_selection_screen.dart';
import 'providers/reservation_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/table_provider.dart';
import 'providers/supabase_reservation_provider.dart';
import 'providers/notification_provider.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  
  // Initialize Supabase
  try {
    await SupabaseConfig.initialize();
    print('Supabase initialized successfully');
  } catch (e) {
    print('Error initializing Supabase: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ReservationProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => SupabaseReservationProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => MenuProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => TableProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider()..init(),
        ),
      ],
      child: MaterialApp(
        title: RESTAURANT_NAME,
        locale: const Locale('id', 'ID'),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textTertiary,
          ),
        ),
        home: const RoleSelectionScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
