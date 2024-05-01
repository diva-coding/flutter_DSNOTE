import 'package:flutter/material.dart';
import 'package:my_app/screens/customer_support/cs_screen.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/screens/api_screen.dart';
import 'package:my_app/screens/datas_screen.dart';
//import 'package:my_app/screens/splash_screen.dart';
import 'package:my_app/screens/setting_screen.dart';
import 'package:my_app/screens/folder_screen.dart';
//import 'package:my_app/utils/themes.dart';
import 'package:my_app/screens/FormScreen/form_screen.dart';
import 'package:my_app/screens/customer_support/cs_detail_screen.dart';
import 'package:my_app/screens/customer_support/form_create_screen.dart';
import 'package:my_app/screens/customer_support/form_update_screen.dart';
import 'package:my_app/models/customer_service_datas.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snote',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      //home: const SplashScreen(),
     routes: {
        //'/splash':(context) => const SplashScreen(),
        '/':(context) => const MyHomePage(title: "Home Screen",),
        '/home':(context) => const HomeScreen(),
        '/folder-screen': (context) => const FolderScreen(),
        '/setting-screen': (context) => const SettingScreen(),
        '/api':(context) => const APIScreen(),
        '/form-screen':(context) => const FormScreen(),
        '/cs-screen':(context) => const CustomerSupportScreen(),
        '/datas-screen':(context) => const DatasScreen(),
        '/cs-detail-screen': (context) => const CustomerSupportDetailScreen(),
        '/form-create-screen': (context) => const CustomerSupportCreateFormScreen(),
        '/form-update-screen': (context) => CustomerSupportUpdateFormScreen(
            dataToUpdate: ModalRoute.of(context)!.settings.arguments as CustomerServiceDatas,
          ),
      },
      initialRoute: '/cs-screen',
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const FolderScreen(),
    const SettingScreen(),
    const APIScreen(),
    const DatasScreen(),
  ];

  final List<String> _appBarTitles = const [
    'DSNOTE',
    'DSNOTE',
    'DSNOTE',
    'DSNOTE',
  ]; // List of titles corresponding to each screen

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void navigateAndCloseDrawer(BuildContext context, String routeName) {
    if (Scaffold.of(context).isDrawerOpen) {
      Navigator.pop(context); // Close the drawer first
    }
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex], textAlign: TextAlign.center, style: const TextStyle(
            fontWeight: FontWeight.bold, // Make the text bold
          ),), centerTitle: true, 
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF0F0F0F),
              ),
               child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50, // Adjust the radius as per your requirement
                      backgroundImage: AssetImage('assets/images/splash_screen_image.jpg'), // Replace with your image asset
                    ),
                    SizedBox(height: 10), // Add some space between the image and text
                    Text(
                      'DSNOTE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF5F5F5),
                      ),
                    ),
                  ],
                ),
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('My Note'),
              selected: _selectedIndex == 0,
              onTap: () {
                // Update the state of the app
                _onItemTapped(0);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Note Folder'),
              selected: _selectedIndex == 1,
              onTap: () {
                // Update the state of the app
                _onItemTapped(1);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Setting'),
              selected: _selectedIndex == 2,
              onTap: () {
                // Update the state of the app
                _onItemTapped(2);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.api),
              title: const Text('News Screen'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const APIScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.api),
              title: const Text('Datas Screen'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DatasScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Customer Support'),
              onTap: () {
                /* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DatasScreen()),
                ); */
                Navigator.pushNamed(context, '/cs-screen');
              },
            )
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF5F5F5),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Note',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Folder',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        onTap: _onItemTapped,
      ),
    );
  }
}
