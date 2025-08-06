// ignore_for_file: deprecated_member_use, use_build_context_synchronously, library_private_types_in_public_api, use_key_in_widget_constructors
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:notes_app_firebase/services/firestore_services.dart';

class NoteEditorScreen extends StatefulWidget {
  final String? noteId;
  final dynamic existingData;

  const NoteEditorScreen({this.noteId, this.existingData});

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  bool isSaving = false;
  late AnimationController _buttonController;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _titleController.text = widget.existingData['title'];
      _contentController.text = widget.existingData['content'];
    }

    _buttonController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.1,
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  void saveNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Title & Content are required")));
      return;
    }

    setState(() => isSaving = true);

    if (widget.noteId != null) {
      await _firestoreService.updateNote(
        widget.noteId!,
        _titleController.text,
        _contentController.text,
      );
    } else {
      await _firestoreService.addNote(
        _titleController.text,
        _contentController.text,
      );
    }

    setState(() => isSaving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.noteId != null ? 'Edit Note' : 'Add Note',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  const Color.fromARGB(255, 252, 252, 252),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.15,
                left: 20,
                right: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        // BoxShadow(
                        //   color: const Color.fromARGB(31, 245, 243, 243),
                        //   blurRadius: 10,
                        //   offset: Offset(0, 4),
                        // ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _titleController,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Title',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _contentController,
                          style: TextStyle(fontSize: 16),
                          maxLines: 10,
                          decoration: InputDecoration(
                            labelText: 'Content',
                            alignLabelWithHint: true,
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        GestureDetector(
                          onTapDown: (_) => _buttonController.forward(),
                          onTapUp: (_) {
                            _buttonController.reverse();
                            if (!isSaving) saveNote();
                          },
                          child: AnimatedBuilder(
                            animation: _buttonController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1 - _buttonController.value,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.black,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: isSaving
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Save',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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
