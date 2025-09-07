import 'package:ddnuvem/services/connection_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:ddnuvem/models/user_privileges.dart';
import 'package:hive/hive.dart';

class UserResource {
  static String collection = "users";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<User> _hiveBox = Hive.box<User>(collection);

  Future<List<User>> getAll() async {
    List<User> users = [];

    try {
      if (await ConnectionService.isConnected()) {
        final list = await _firestore.collection(collection).get();

        for (var doc in list.docs) {
          UserPrivileges privileges = await _getUserPrivileges(doc.id);
          User user = User.fromMap(doc.data(), doc.id, privileges);
          users.add(user);
          _saveToLocalDB(user);
        }
      } else {
        users = _getAllFromLocalDB();
      }
      return users;
    } catch (e) {
      debugPrint("Error on list all users: $e");
      return [];
    }
  }

  Stream<List<User>> getAllStream() {
    final snapshots = _firestore.collection(collection).snapshots();

    return snapshots.asyncMap((event) async {
      try {
        List<User> users = [];
        for (var doc in event.docs) {
          try {
            var privileges = await _getUserPrivileges(doc.id);
            User user = User.fromMap(doc.data(), doc.id, privileges);
            users.add(user);
            _saveToLocalDB(user);
          } catch (e) {
            debugPrint("Error on user doc ${doc.id}: $e");
          }
        }
        return users;
      } catch (e) {
        debugPrint("Error on list all users stream: $e");
        return [];
      }
    });
  }

  create(User user) async {
    try {
      if (await get(user.email) != null) {
        throw Exception("Usuário já existe.");
      }

      var doc = await _firestore.collection(collection).add(user.toMap());
      await _firestore
          .doc("$collection/${doc.id}/privileges/privileges")
          .set(user.privileges.toMap());
    } on Exception catch (e) {
      if (e.toString().contains("Usuário já existe.")) {
        rethrow;
      } else {
        debugPrint("Error on create user: $e");
        throw Exception("Erro ao criar usuário.");
      }
    }
  }

  createAuthenticatedUser(User user) async {
    try {
      await _firestore.doc("$collection/${user.id}").set(user.toMap());
      await _firestore
          .doc("$collection/${user.id}/privileges/privileges")
          .set(user.privileges.toMap());
    } catch (e) {
      debugPrint("Error on create authenticated user: $e");
    }
  }

  delete(User user) async {
    try {
      await _firestore
          .doc("$collection/${user.id}/privileges/privileges")
          .delete();

      await _firestore.doc("$collection/${user.id}").delete();
      _deleteFromLocalDB(user.id);
    } catch (e) {
      debugPrint("Error on delete user: $e");
      throw Exception("Erro ao excluir usuário.");
    }
  }

  Future<User?> get(String email) async {
    User? user;

    try {
      if (await ConnectionService.isConnected()) {
        final query = await _firestore
            .collection(collection)
            .where('email', isEqualTo: email)
            .get();

        if (query.docs.isEmpty) {
          return null;
        }

        final doc = query.docs.first;
        UserPrivileges privileges = await _getUserPrivileges(doc.id);
        user = User.fromMap(doc.data(), doc.id, privileges);
        _saveToLocalDB(user);
      } else {
        user = _getFromLocalDB(email);
      }
      return user;
    } catch (e) {
      debugPrint("Error on get user: $e");
      return null;
    }
  }

  update(User user) async {
    try {
      var doc = await _firestore.doc("$collection/${user.id}").get();

      if (!doc.exists) {
        return;
      }

      await _firestore.doc("$collection/${user.id}").update(user.toMap());
      await _firestore
          .doc("$collection/${user.id}/privileges/privileges")
          .update(user.privileges.toMap());
      _saveToLocalDB(user);
    } catch (e) {
      debugPrint("Error on update user: $e");
      throw Exception("Erro ao atualizar usuário.");
    }
  }

  Future<UserPrivileges> _getUserPrivileges(String id) async {
    try {
      final doc =
          await _firestore.doc('$collection/$id/privileges/privileges').get();

      if (doc.exists) {
        return UserPrivileges.fromMap(doc.data()!);
      }

      throw Exception("Privilégios não encontrados ou não definidos.");
    } catch (e) {
      debugPrint("Error on get privileges: $e");
      return UserPrivileges(
          isAdmin: false,
          isSuperAdmin: false,
          isInstaller: false
      );
    }
  }

  // Hive
  _saveToLocalDB(User user) {
    try {
      _hiveBox.put(user.id, user);
    } catch (e) {
      debugPrint("Error on save user ${user.id} to Hive: $e.");
    }
  }

  _deleteFromLocalDB(String id) {
    try {
      _hiveBox.delete(id);
    } catch (e) {
      debugPrint("Error on delete user $id from Hive: $e.");
    }
  }

  User? _getFromLocalDB(String email) {
    try {
      return _hiveBox.values.firstWhere((u) => u.email == email);
    } catch (e) {
      debugPrint("Error on get user $email from Hive: $e.");
      return null;
    }
  }

  List<User> _getAllFromLocalDB() {
    try {
      return _hiveBox.values.toList();
    } catch (e) {
      debugPrint("Error on list all users from Hive: $e.");
      return [];
    }
  }
}
