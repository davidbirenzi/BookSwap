import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../models/book.dart';
import '../services/database_service.dart';
import '../providers/auth_provider.dart';

class AddBookScreen extends StatefulWidget {
  final Book? book;
  
  const AddBookScreen({super.key, this.book});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  
  BookCondition _selectedCondition = BookCondition.Good;
  File? _imageFile;
  String? _base64Image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _selectedCondition = widget.book!.condition;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: Text(widget.book == null ? 'Add Book' : 'Edit Book')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : widget.book?.imageUrl.isNotEmpty == true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildPreviewImage(widget.book!.imageUrl),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 50, color: Colors.black54),
                                Text('Tap to add image', style: TextStyle(color: Colors.black54)),
                              ],
                            ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(labelText: 'Book Title'),
                validator: (value) => value?.isEmpty ?? true ? 'Enter title' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(labelText: 'Author'),
                validator: (value) => value?.isEmpty ?? true ? 'Enter author' : null,
              ),
              SizedBox(height: 16),
              Text('Condition', style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 8),
              ...BookCondition.values.map((condition) {
                return RadioListTile<BookCondition>(
                  title: Text(condition.name, style: TextStyle(color: Colors.white)),
                  value: condition,
                  groupValue: _selectedCondition,
                  onChanged: (value) => setState(() => _selectedCondition = value!),
                  activeColor: Color(0xFFF5C841),
                );
              }).toList(),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _saveBook(authProvider.user!),
                      child: Text(widget.book == null ? 'Add Book' : 'Update Book'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewImage(String imageUrl) {
    try {
      if (imageUrl.startsWith('data:') || !imageUrl.startsWith('http')) {
        final base64String = imageUrl.contains(',') ? imageUrl.split(',')[1] : imageUrl;
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.camera_alt, size: 50, color: Colors.black54);
          },
        );
      } else {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.camera_alt, size: 50, color: Colors.black54);
          },
        );
      }
    } catch (e) {
      return Icon(Icons.camera_alt, size: 50, color: Colors.black54);
    }
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final File file = File(image.path);
      final bytes = await file.readAsBytes();
      setState(() {
        _imageFile = file;
        _base64Image = base64Encode(bytes);
      });
    }
  }

  void _saveBook(user) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        Book book = Book(
          id: widget.book?.id ?? '',
          title: _titleController.text,
          author: _authorController.text,
          condition: _selectedCondition,
          imageUrl: _base64Image ?? widget.book?.imageUrl ?? '',
          ownerId: user.id,
          ownerName: user.name,
          createdAt: widget.book?.createdAt ?? DateTime.now(),
        );
        
        if (widget.book == null) {
          await _databaseService.addBook(book);
        } else {
          await _databaseService.updateBook(widget.book!.id, book);
        }
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.book == null ? 'Book added!' : 'Book updated!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving book')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}