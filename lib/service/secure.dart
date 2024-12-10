import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// Create an instance of SecureStorage
final _storage = FlutterSecureStorage();

// Function to store the JWT
Future<void> storeJwtToken(String token) async {
  await _storage.write(key: 'jwt_token', value: token);
}

// Function to retrieve the JWT
Future<String?> getJwtToken() async {
  return await _storage.read(key: 'jwt_token');
}

Future<void> makeAuthenticatedRequest() async {
  final token = await getJwtToken(); // Retrieve the JWT from secure storage

  final response = await http.get(
    Uri.parse('http://your-flask-backend-url.com/protected-route'),
    headers: {
      'Authorization': 'Bearer $token', // Send JWT as Bearer token
    },
  );

  if (response.statusCode == 200) {
    // Successfully authenticated
    print("Request was successful");
  } else {
    // Handle unauthorized error
    print("Authentication failed");
  }
}
