import 'package:flutter/material.dart';
import 'dart:math';
import 'package:product/Widget/customCliper.dart'; // Assuming you already have customClipper
import 'package:product/controllers/product_controller.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductController _productController =
      ProductController(); // Create ProductController instance
  String productName = '';
  String productType = '';
  double price = 0.00;
  String unit = '';

  // Function to add new product
  void _addNewProduct() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      _productController.InsertProduct(
        context,
        productName,
        productType,
        price,
        unit,
      ).then((response) {
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เพิ่มสินค้าเรียบร้อยแล้ว')),
          );
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (response.statusCode == 401) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Refresh token expired. Please login again.')),
          );
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("เพิ่มสินค้าใหม่"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'เพิ่ม',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w900,
                    color: Color(0xffC7253E),
                  ),
                  children: [
                    TextSpan(
                      text: 'สินค้าใหม่',
                      style: TextStyle(
                          color: Color(0xffE85C0D), fontSize: 35),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildRoundedTextField(
                      label: 'ชื่อสินค้า',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกชื่อสินค้า';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        productName = value!;
                      },
                    ),
                    SizedBox(height: 16),
                    _buildRoundedTextField(
                      label: 'ประเภทสินค้า',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกประเภทสินค้า';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        productType = value!;
                      },
                    ),
                    SizedBox(height: 16),
                    _buildRoundedTextField(
                      label: 'ราคา',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกราคา';
                        }
                        if (int.tryParse(value) == null) {
                          return 'กรุณากรอกจำนวนเต็มที่ถูกต้อง';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        price = double.parse(value!);
                      },
                    ),
                    SizedBox(height: 16),
                    _buildRoundedTextField(
                      label: 'หน่วย',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกหน่วย';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        unit = value!;
                      },
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _addNewProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedTextField({
    required String label,
    TextInputType? keyboardType,
    required FormFieldValidator<String> validator,
    required FormFieldSetter<String> onSaved,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.lightBlue[100], // Background color
        borderRadius: BorderRadius.circular(25), // Rounded corners
      ),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.transparent, // Transparent to inherit container color
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
