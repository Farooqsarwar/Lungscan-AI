// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import 'home screen.dart';
//
// class SuccessfulLoginScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.white, Color(0xFFE0E0E0)],
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Center(child: Image.asset('assets/logo.png', height: 40)),
//                 SizedBox(height: 30),
//                 Container(
//                   width: 100,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     color: Color(0xFF8BC34A).withOpacity(0.3),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(Icons.check, color: Color(0xFF8BC34A), size: 60),
//                 ),
//                 SizedBox(height: 20),
//                 Text(
//                   'Login successfully',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 30),
//                 TextField(
//                   enabled: false,
//                   decoration: InputDecoration(
//                     labelText: 'E-mail',
//                     hintText: 'abcdef@gmail.com',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 30),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => HomeScreen(username: 'User'),
//                       ),
//                     );
//                   },
//                   child: Text('SUBMIT'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFFFF5722),
//                     foregroundColor: Colors.white,
//                     minimumSize: Size(double.infinity, 50),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
