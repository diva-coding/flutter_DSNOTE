import 'package:flutter/material.dart';
import 'package:my_app/models/customer_service_datas.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_app/endpoints/endpoints.dart';
import 'package:my_app/services/data_service.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

class CustomerSupportDetailScreen extends StatefulWidget {
  const CustomerSupportDetailScreen({Key? key}) : super(key: key);

  @override
  _CustomerSupportDetailScreenState createState() => _CustomerSupportDetailScreenState();
}

class _CustomerSupportDetailScreenState extends State<CustomerSupportDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as CustomerServiceDatas;
    var logger = Logger();

    return Scaffold(
       appBar: AppBar(
        title: const Text("Detail"),
        actions: [ // Add 'actions' for buttons
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () { 
              Navigator.pushNamed(
                context,
                '/form-update-screen',
                arguments: args,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Delete Functionality (with a confirmation dialog)
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Are you sure?'),
                  content: const Text('Do you want to delete this item?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('No'),
                      onPressed: () => Navigator.pop(ctx), // Close dialog
                    ),
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () async { // Make the call asynchronous
                        try {
                          await DataService.deleteCustomerServiceData(args.idDatas);
                          if (context.mounted) {
                            Navigator.pop(ctx);  // Close dialog
                            Navigator.pushReplacementNamed(context, '/cs-screen');
                          }
                        } catch (error) {
                          // Handle the error (e.g., display an error message)
                          logger.e(error);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
       ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card( // Add a Card for structure
            child: Padding( // Introduce internal padding
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Center( // Keep the image centered
                    child: ClipRRect( // Rounded corners
                      borderRadius: BorderRadius.circular(10.0),
                      child: CachedNetworkImage(
                        imageUrl: '${Endpoints.baseURLCustomerSupport}/public/${args.imageUrl ?? ""}',
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        height: 250, 
                        width: double.infinity, // Occupy card width
                        fit: BoxFit.cover, 
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    args.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  Text('By: ${args.nim}'),
                  const SizedBox(height: 8),
                  Row( // Use a Row to display rating, priority, and department
                    children: [
                      Row( // Nested Row for star rating (optional)
                        children: [
                          const Icon(Icons.star, color: Colors.black),
                          Text(' ${args.rating}', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(width: 10), // Add some horizontal spacing
                      Text('Priority: ${args.priority}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(width: 10), // Add some horizontal spacing
                      Text('Department: ${args.divisionDepartment}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Created: ${DateFormat('MMMM dd, yyyy hh:mm:ss a').format(args.createdAt)}', 
                    style: const TextStyle(fontSize: 14, color: Colors.grey)
                  ),
                  Text('Updated: ${DateFormat('MMMM dd, yyyy hh:mm:ss a').format(args.updatedAt)}', 
                    style: const TextStyle(fontSize: 14, color: Colors.grey)
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    args.description,
                    style: const TextStyle(
                      fontSize: 16, 
                      height: 1.4, // Adjust line height here 
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}