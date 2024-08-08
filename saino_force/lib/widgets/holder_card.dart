import 'package:flutter/material.dart';
import '../models/holder.dart';

class HolderCard extends StatefulWidget {
  final Holder holder;

  HolderCard(this.holder);

  @override
  _HolderCardState createState() => _HolderCardState();
}

class _HolderCardState extends State<HolderCard> {
  final _formKey = GlobalKey<FormState>();
  bool _isExpanded = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNoController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.holder.name);
    _emailController = TextEditingController(text: widget.holder.email);
    _phoneNoController = TextEditingController(text: widget.holder.phoneNo);
    _descriptionController =
        TextEditingController(text: widget.holder.description);
    _addressController = TextEditingController(text: widget.holder.address);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNoController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
                widget.holder.name.isEmpty ? 'No Name' : widget.holder.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.holder.email.isEmpty
                    ? 'No Email'
                    : widget.holder.email),
                Text(widget.holder.description.isEmpty
                    ? 'No Description'
                    : widget.holder.description),
              ],
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 300, // Adjust the height as needed
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            errorStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter Holder's name";
                            }
                            final nameRegex = RegExp(r"^[a-zA-Z\s'-]+$");
                            if (!nameRegex.hasMatch(value)) {
                              return 'Please enter valid Name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            errorStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter Holder's Email";
                            }
                            final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _phoneNoController,
                          decoration: const InputDecoration(
                            labelText: 'Phone No',
                            errorStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter Holder's phone No";
                            }
                            final phoneregex = RegExp(r'^(\+6)?01[0-9]{8,9}$');
                            if (!phoneregex.hasMatch(value)) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            errorStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some description';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Wallet Address',
                            errorStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter Holder's address";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                widget.holder.name = _nameController.text;
                                widget.holder.email = _emailController.text;
                                widget.holder.phoneNo = _phoneNoController.text;
                                widget.holder.description =
                                    _descriptionController.text;
                                widget.holder.address = _addressController.text;
                                _isExpanded = false;
                              });
                            }
                          },
                          child: Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}