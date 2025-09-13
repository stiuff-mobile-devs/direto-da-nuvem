import 'package:hive/hive.dart';

part 'user_privileges.g.dart';

@HiveType(typeId: 5)
class UserPrivileges extends HiveObject {
  @HiveField(0)
  bool isAdmin;
  @HiveField(1)
  bool isSuperAdmin;
  @HiveField(2)
  bool isInstaller;

  UserPrivileges({
    required this.isAdmin,
    required this.isSuperAdmin,
    required this.isInstaller,
  });

  @override
  String toString() {
    String string = [
      if (isSuperAdmin) "Superadmin",
      if (isAdmin) "Admin",
      if (isInstaller) "Instalador",
    ].join(", ");

    return string;
  }

  factory UserPrivileges.fromMap(Map<String, dynamic> map) {
    return UserPrivileges(
        isAdmin: map['admin'] ?? false,
        isSuperAdmin: map['super_admin'] ?? false,
        isInstaller: map['installer'] ?? false
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "installer": isInstaller,
      "admin": isAdmin,
      "super_admin": isSuperAdmin,
    };
  }
}