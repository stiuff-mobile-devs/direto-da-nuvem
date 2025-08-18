import 'package:ddnuvem/controllers/device_controller.dart';
import 'package:ddnuvem/controllers/group_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/services/direto_da_nuvem/direto_da_nuvem_service.dart';
import 'package:ddnuvem/services/local_storage/booleans.dart';
import 'package:ddnuvem/services/local_storage/local_storage_service.dart';
import 'package:ddnuvem/views/intro_page.dart';
import 'package:ddnuvem/views/redirection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

void main() {
  group(
    "RedirectionPage tests",
    () {
      final userController = MockUserController();
      final localStorageService = MockLocalStorageService();
      final deviceController = MockDeviceController();
      final groupController = MockGroupController();
      final diretoDaNuvemAPI = MockDiretoDaNuvemAPI();

      testWidgets(
        "When: firstTime - Then: Intro Page",
        (widgetTester) async {
          // const testSize = Size(375, 812);
          const testSize = Size(812, 375);
          widgetTester.view.physicalSize = testSize;

          when(() => userController.loadingInitialState).thenReturn(false);
          when(() => userController.isLoggedIn).thenReturn(false);
          when(() => userController.currentUser!.privileges.isInstaller).thenReturn(false);
          when(() => userController.currentUser!.privileges.isSuperAdmin).thenReturn(false);

          when(() =>
                  localStorageService.readBool(LocalStorageBooleans.firstTime))
              .thenAnswer((_) async => true);
          when(() => localStorageService.saveBool(
                  LocalStorageBooleans.firstTime, any()))
              .thenAnswer((_) async => true);

          when(() => deviceController.isRegistered).thenReturn(false);
          when(() => deviceController.loadingInitialState).thenReturn(false);

          when(() => groupController.isAdmin).thenReturn(false);

          when(() => deviceController.isRegistered).thenReturn(false);
          when(() => deviceController.loadingInitialState).thenReturn(false);

          when(() => groupController.isAdmin).thenReturn(false);

          await widgetTester.pumpWidget(
            MaterialApp(
              home: MultiProvider(
                providers: [
                  ChangeNotifierProvider<GroupController>(
                    create: (_) => groupController,
                  ),
                  Provider<LocalStorageService>.value(
                    value: localStorageService,
                  ),
                  Provider<DiretoDaNuvemAPI>.value(
                    value: diretoDaNuvemAPI,
                  ),
                  ChangeNotifierProvider<UserController>(
                    create: (_) => userController,
                  ),
                  ChangeNotifierProvider<DeviceController>(
                      create: (_) => deviceController),
                ],
                child: const RedirectionPage(),
              ),
            ),
          );

          await widgetTester.pumpAndSettle();

          expect(find.byType(IntroPage), findsOneWidget);
        },
      );
    },
  );
}

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockGroupController extends Mock implements GroupController {}

class MockDiretoDaNuvemAPI extends Mock implements DiretoDaNuvemAPI {}

class MockUserController extends Mock implements UserController {}

class MockDeviceController extends Mock implements DeviceController {}
