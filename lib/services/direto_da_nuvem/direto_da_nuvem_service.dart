import 'package:ddnuvem/services/direto_da_nuvem/device_resource.dart';
import 'package:ddnuvem/services/direto_da_nuvem/group_resource.dart';
import 'package:ddnuvem/services/direto_da_nuvem/image_resource.dart';
import 'package:ddnuvem/services/direto_da_nuvem/queue_resource.dart';
import 'package:ddnuvem/services/direto_da_nuvem/user_resource.dart';

class DiretoDaNuvemAPI {
  GroupResource groupResource = GroupResource();
  DeviceResource deviceResource = DeviceResource();
  QueueResource queueResource = QueueResource();
  UserResource userResource = UserResource();
  ImageResource imageResource = ImageResource();
}