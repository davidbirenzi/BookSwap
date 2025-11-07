import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : widget.book?.imageUrl.isNotEmpty == true
                          ? Image.network(widget.book!.imageUrl, fit: BoxFit.cover)
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
                decoration: InputDecoration(labelText: 'Book Title'),
                validator: (value) => value?.isEmpty ?? true ? 'Enter title' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
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

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() => _imageFile = File(image.path));
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
          imageUrl: widget.book?.imageUrl ?? '',
          ownerId: user.id,
          ownerName: user.name,
          createdAt: widget.book?.createdAt ?? DateTime.now(),
        );
        
        if (widget.book == null) {
          await _databaseService.addBook(book, _imageFile);
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