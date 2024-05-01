import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:my_app/components/bottom_up_transition.dart';
import 'package:my_app/models/customer_service_datas.dart';
import 'package:my_app/endpoints/endpoints.dart';
import 'package:my_app/services/data_service.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({Key? key}) : super(key: key);

  @override
  _CustomerSupportScreenState createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  Future<List<CustomerServiceDatas>>? _customerServiceDatas;

  @override
  void initState() {
    super.initState();
    _customerServiceDatas = DataService.fetchCustomerServiceDatas();
  }

  // Helper function to generate stars based on rating
  String getStarRating(int rating) {
    String stars = '';
    for (int i = 0; i < rating; i++) { 
      stars += '★'; 
    }
    for (int i = 0; i < (5 - rating); i++) { // Add empty stars if needed
      stars += '☆'; 
    }
    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Service List'),
        leading: IconButton(
          icon: const Icon(Icons
              .arrow_back), // Customize icon (optional)// Customize color (optional)
          onPressed: () {
            // Your custom back button functionality here
            Navigator.pushReplacementNamed(
                context, '/'); // Default back button behavior
            // You can add additional actions here (e.g., show confirmation dialog)
          },
        ),
      ),
      body: FutureBuilder<List<CustomerServiceDatas>>(
        future: _customerServiceDatas,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                
                  return ListTile(
                    leading: item.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            fit: BoxFit.cover,
                            width: 100,  // Adjust image width
                            height: 300, // Adjust image height
                            Uri.parse('${Endpoints.baseURLCustomerSupport}/public/${item.imageUrl!}')
                                .toString(),
                            errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.image_not_supported_outlined)), 
                          ),
                        )
                      : null,
                    title: Column( // Place title and priority within a Column
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        Text(item.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: const Color.fromARGB(255, 36, 31, 31),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,),
                        Text(
                          item.nim,
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis, 
                          style: const TextStyle(fontSize: 14)),
                        // Display the black stars based on the rating value
                        Text(getStarRating(item.rating!), style: const TextStyle(color: Colors.black)) 
                      ],
                    ),
                    subtitle: Text(
                      item.description,
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis, 
                      style: const TextStyle(fontSize: 14), 
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/cs-detail-screen',
                        arguments: item, // Pass the CustomerServiceDatas object
                      );
                    },
                  );
                
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        // backgroundColor: const Color.fromARGB(255, 54, 40, 176),
        tooltip: 'Increment',
        onPressed: () {
          Navigator.pushNamed(context, '/form-create-screen');
          // BottomUpRoute(page: const FormScreen());
          //Navigator.push(context, BottomUpRoute(page: const FormScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}