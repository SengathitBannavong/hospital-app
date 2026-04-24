import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/hospital_theme.dart';

class ProfileAvatar extends StatefulWidget {
  final String? imageUrl;
  final Function(String path) onImagePicked;
  final bool isReadOnly;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.onImagePicked,
    this.isReadOnly = false,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      widget.onImagePicked(image.path);
    }
  }

  void _showPicker(BuildContext context) {
    if (widget.isReadOnly) return;
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Thư viện'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Máy ảnh'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: context.colorScheme.primaryContainer,
            backgroundImage: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                ? NetworkImage(widget.imageUrl!)
                : null,
            child: widget.imageUrl == null || widget.imageUrl!.isEmpty
                ? Icon(Icons.person, size: 60, color: context.colorScheme.primary)
                : null,
          ),
          if (!widget.isReadOnly)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showPicker(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colorScheme.surface, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: context.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
