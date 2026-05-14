import 'item_image_ref_io.dart'
    if (dart.library.html) 'item_image_ref_web.dart'
    as impl;

bool itemImageRefIsDisplayable(String? ref) =>
    impl.itemImageRefIsDisplayable(ref);
