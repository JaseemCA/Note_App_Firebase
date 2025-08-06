// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app_firebase/screens/login_screen.dart';
import 'package:notes_app_firebase/screens/note_editor.dart';
import 'package:notes_app_firebase/services/firestore_services.dart';
import 'package:notes_app_firebase/services/auth_service.dart';

class NotesListScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  NotesListScreen({super.key});

  void logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: const Color.fromARGB(255, 81, 81, 81)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _authService.signOut();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logged out successfully!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Notes',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getNotes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No notes found.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            final notes = snapshot.data!.docs;

            return ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 100, 16, 80),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final createdAt = note['createdAt'] as Timestamp?;
                final updatedAt = note['updatedAt'] as Timestamp?;

                return Dismissible(
                  key: Key(note.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    color: Colors.redAccent,
                    child: Icon(
                      Icons.delete,
                      color: const Color.fromARGB(255, 48, 35, 35),
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'Delete Note?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                          'Are you sure you want to delete this note?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 81, 81, 81),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    await _firestoreService.deleteNote(note.id);
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoteEditorScreen(
                            noteId: note.id,
                            existingData: note,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.black12),
                      ),
                      child: ListTile(
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.swipe_left,
                              color: Colors.grey,
                              size: 20,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Swipe left\nto delete',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        title: Text(
                          note['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 6),
                            Text(
                              note['content'],
                              style: TextStyle(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  createdAt != null
                                      ? 'Created: ${formatTimestamp(createdAt)}'
                                      : '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            updatedAt != null
                                ? Row(
                                    children: [
                                      Icon(
                                        Icons.update,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Updated: ${formatTimestamp(updatedAt)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        elevation: 8,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NoteEditorScreen()),
          );
        },
        label: Text(
          'Add Note',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        icon: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
