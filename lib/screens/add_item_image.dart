import 'package:image_picker/image_picker.dart';

import 'add_item_image_io.dart'
    if (dart.library.html) 'add_item_image_web.dart'
    as add_item_image_impl;

Future<String?> savePickedImageToAppDir(XFile x) =>
    add_item_image_impl.savePickedImageToAppDir(x);
