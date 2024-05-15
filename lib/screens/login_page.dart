import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  File? _imageFile;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        print(_imageFile);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _registerUser() async {
    final url = Uri.parse('http://10.0.2.2:3000/auth/register');
    final request = http.MultipartRequest('POST', url)
      ..fields['name'] = _nameController.text
      ..fields['email'] = _emailController.text
      ..fields['password'] = _passwordController.text
      ..files.add(http.MultipartFile(
        'image',
        _imageFile!.readAsBytes().asStream(),
        _imageFile!.lengthSync(),
        filename: _imageFile!.path.split('/').last,
      ));

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 200) {
      print('User registered successfully');
    } else {
      print('Failed to register user: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                // Expanded(
                //   child: ElevatedButton(
                //     onPressed: () {},
                //     child: Text('Login'),
                //   ),
                // ),
                SizedBox(width: 10.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _registerUser();
                    },
                    child: Text('Sign Up'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Center(
              child: GestureDetector(
                onTap: _getImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : AssetImage('assets/Vector (1).png') as ImageProvider,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
