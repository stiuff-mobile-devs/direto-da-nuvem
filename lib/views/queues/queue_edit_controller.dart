import 'package:ddnuvem/controllers/queue_controller.dart';
import 'package:ddnuvem/controllers/user_controller.dart';
import 'package:ddnuvem/models/image.dart';
import 'package:ddnuvem/models/queue.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart' hide Image;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/widgets.dart' hide Image;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class QueueEditController extends ChangeNotifier {
  late String currentUserId;
  late QueueController queueController;
  BuildContext context;
  Queue queue;
  Uint8List? imageBytes;
  bool hasChanged = false;
  final ImagePicker _picker = ImagePicker();
  bool disposed = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  bool imagesLoaded = false;

  QueueEditController({required this.context, required this.queue}) {
    currentUserId = context.read<UserController>().currentUser!.id;
    queueController = context.read<QueueController>();

    nameController.text = queue.name;
    durationController.text = queue.duration.toString();
    queue.updatedBy = currentUserId;
    queue.id.isEmpty ? queue.createdBy = currentUserId
        : queue.updatedAt = DateTime.now();

    fetchImages();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex--;
    }
    final item = queue.images.removeAt(oldIndex);
    queue.images.insert(newIndex, item);
    notifyListeners();
  }
  selectOrientation(String? direction) {
    queue.orientation = direction ?? "Horizontal";
    notifyListeners();
  }


  @override
  void dispose() {
    disposed = true;
    debugPrint("QueueEditController disposed");
    super.dispose();
  }

  void fetchImages() async {
    imagesLoaded = false;
    notifyListeners();
    queue = await queueController.fetchQueueImages(queue);
    if (disposed) return;
    imagesLoaded = true;
    notifyListeners();
  }

  pickImage() {
    return kIsWeb ? _pickImageOnWeb() : _pickImageOnMobile();
  }

  _pickImageOnMobile() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    imageBytes = await pickedFile.readAsBytes();
    queue.images.add(Image(
        path: pickedFile.name,
        data: imageBytes,
        createdAt: DateTime.now(),
        createdBy: currentUserId)
    );
    if (disposed) return;
    notifyListeners();
  }

  _pickImageOnWeb() async {
    final pickedFile = await FilePicker
        .platform.pickFiles(type: FileType.image);

    if (pickedFile != null) {
      queue.images.add(Image(
          path: pickedFile.files.first.name,
          data: pickedFile.files.first.bytes,
          createdAt: DateTime.now(),
          createdBy: currentUserId)
      );
      if (disposed) return;
      notifyListeners();
    }
  }

  void removeQueueImage(Image image) {
    queue.images.remove(image);
    notifyListeners();
  }
}
