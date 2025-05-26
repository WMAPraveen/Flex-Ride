// import 'dart:io';
// import 'package:car_rental_app/models/vehicle.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:path/path.dart' as path;

//  // Adjust if your path is different

// class EditVehiclePage extends StatefulWidget {
//   final Vehicle vehicle;
//   final Function(Vehicle) onSave;

//   const EditVehiclePage({Key? key, required this.vehicle, required this.onSave})
//     : super(key: key);

//   @override
//   _EditVehiclePageState createState() => _EditVehiclePageState();
// }

// class _EditVehiclePageState extends State<EditVehiclePage> {
//   final _formKey = GlobalKey<FormState>();

//   late TextEditingController _nameController;
//   late TextEditingController _typeController;
//   late TextEditingController _priceController;
//   late TextEditingController _descriptionController;

//   File? _imageFile;
//   String? _imageUrl;

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.vehicle.name);
//     _typeController = TextEditingController(text: widget.vehicle.type);
//     _priceController = TextEditingController(
//       text: widget.vehicle.pricePerDay.toString(),
//     );
//     _descriptionController = TextEditingController(
//       text: widget.vehicle.description ?? '',
//     );
//     _imageUrl = widget.vehicle.imagePath;
//   }

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }

//   Future<String> _uploadImage(File imageFile, String vehicleId) async {
//     final storageRef = FirebaseStorage.instance
//         .ref()
//         .child('vehicles')
//         .child('$vehicleId-${path.basename(imageFile.path)}');

//     final uploadTask = storageRef.putFile(imageFile);
//     final snapshot = await uploadTask;
//     final downloadUrl = await snapshot.ref.getDownloadURL();
//     return downloadUrl;
//   }

//   Future<void> _saveVehicle() async {
//     if (_formKey.currentState!.validate()) {
//       String imageUrl = _imageUrl ?? '';

//       if (_imageFile != null) {
//         imageUrl = await _uploadImage(_imageFile!, widget.vehicle.id);
//       }

//       final updatedVehicle = Vehicle(
//         id: widget.vehicle.id,
//         name: _nameController.text,
//         type: _typeController.text,
//         pricePerDay: double.parse(_priceController.text),
//         imagePath: imageUrl,
//         isRented: widget.vehicle.isRented,
//         isUnderMaintenance: widget.vehicle.isUnderMaintenance,
//         description: _descriptionController.text,
//       );

//       widget.onSave(updatedVehicle);
//       Navigator.pop(context);
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _typeController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: const Text('Edit Vehicle')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(labelText: 'Vehicle Name'),
//                 validator:
//                     (value) =>
//                         value == null || value.isEmpty
//                             ? 'Please enter vehicle name'
//                             : null,
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _typeController,
//                 decoration: const InputDecoration(labelText: 'Vehicle Type'),
//                 validator:
//                     (value) =>
//                         value == null || value.isEmpty
//                             ? 'Please enter vehicle type'
//                             : null,
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _priceController,
//                 keyboardType: TextInputType.numberWithOptions(decimal: true),
//                 decoration: const InputDecoration(labelText: 'Price Per Day'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) return 'Enter price';
//                   if (double.tryParse(value) == null)
//                     return 'Enter valid number';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _descriptionController,
//                 maxLines: 3,
//                 decoration: const InputDecoration(labelText: 'Description'),
//               ),
//               const SizedBox(height: 20),
//               GestureDetector(
//                 onTap: _pickImage,
//                 child:
//                     _imageFile != null
//                         ? Image.file(
//                           _imageFile!,
//                           height: 150,
//                           fit: BoxFit.cover,
//                         )
//                         : _imageUrl != null
//                         ? Image.network(
//                           _imageUrl!,
//                           height: 150,
//                           fit: BoxFit.cover,
//                         )
//                         : Container(
//                           height: 150,
//                           color: Colors.grey[300],
//                           child: const Center(
//                             child: Text('Tap to select image'),
//                           ),
//                         ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _saveVehicle,
//                 child: const Text('Save Changes'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
