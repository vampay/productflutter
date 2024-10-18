import 'package:flutter/material.dart';
import 'dart:math';
import 'package:product/Widget/customCliper.dart'; // Assuming you already have customClipper
import 'package:product/controllers/product_controller.dart';
import 'package:product/models/product_model.dart';

class EditProductPage extends StatefulWidget {
  final ProductModel product; // ProductModel for editing

  const EditProductPage({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String productName;
  late String productType;
  late double price;
  late String unit;

  @override
  void initState() {
    super.initState();
    // Fetch product details to pre-fill the form fields
    productName = widget.product.productName;
    productType = widget.product.productType;
    price = widget.product.price;
    unit = widget.product.unit;
  }

  // Function to update the product
  Future<void> _updateProduct(BuildContext context, String productId) async {
    final productController = ProductController();
    try {
      final response = await productController.updateProduct(
        context,
        productId,
        productName,
        productType,
        price,
        unit,
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/admin');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('แก้ไขสินค้าเรียบร้อยแล้ว')),
        );
      } else if (response.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Refresh token expired. Please login again.')),
        );
      }
    } catch (error) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("แก้ไขสินค้า"),
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
                  text: 'แก้ไข',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w900,
                    color: Color(0xffC7253E),
                  ),
                  children: [
                    TextSpan(
                      text: 'สินค้า',
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
                      initialValue: productName,
                      onSaved: (value) => productName = value!,
                    ),
                    SizedBox(height: 16),
                    _buildRoundedTextField(
                      label: 'ประเภทสินค้า',
                      initialValue: productType,
                      onSaved: (value) => productType = value!,
                    ),
                    SizedBox(height: 16),
                    _buildRoundedTextField(
                      label: 'ราคา',
                      initialValue: price.toString(),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => price = double.parse(value!),
                    ),
                    SizedBox(height: 16),
                    _buildRoundedTextField(
                      label: 'หน่วย',
                      initialValue: unit,
                      onSaved: (value) => unit = value!,
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              _updateProduct(context, widget.product.id);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff821131),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 12.0),
                            child: Text(
                              'แก้ไข้',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/admin'); // Go back to product listing
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Color.fromRGBO(103, 103, 103, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 12.0),
                            child: Text(
                              'ยกเลิก',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // Function to create rounded text fields
  Widget _buildRoundedTextField({
    required String label,
    required String initialValue,
    TextInputType? keyboardType,
    required FormFieldSetter<String> onSaved,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.lightBlue[100], // Light blue background
        borderRadius: BorderRadius.circular(25), // Rounded corners
      ),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.transparent, // Inherit container color
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        initialValue: initialValue,
        keyboardType: keyboardType,
        onSaved: onSaved,
      ),
    );
  }
}
