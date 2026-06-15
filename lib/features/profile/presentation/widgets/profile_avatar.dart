import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/network/media_url.dart';
import '../../../../core/theme/hospital_theme.dart';

class ProfileAvatar extends StatefulWidget {
  final String? imageUrl;
  final Function(XFile file) onImagePicked;
  final VoidCallback? onRemove;
  final bool isReadOnly;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.onImagePicked,
    this.onRemove,
    this.isReadOnly = false,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (image != null) {
      widget.onImagePicked(image);
    }
  }

  void _showPicker(BuildContext context) {
    if (widget.isReadOnly) return;

    final hasImage = resolveMediaUrl(widget.imageUrl) != null;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(context.l10n.profilePickGallery),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(context.l10n.profilePickCamera),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              if (hasImage && widget.onRemove != null)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: context.colorScheme.error,
                  ),
                  title: Text(
                    context.l10n.profileRemoveAvatarTitle,
                    style: TextStyle(color: context.colorScheme.error),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onRemove!();
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
    final resolvedUrl = resolveMediaUrl(widget.imageUrl);
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: context.colorScheme.primaryContainer,
            backgroundImage: resolvedUrl != null
                ? NetworkImage(resolvedUrl)
                : null,
            child: resolvedUrl == null
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: context.colorScheme.primary,
                  )
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
                    border: Border.all(
                      color: context.colorScheme.surface,
                      width: 2,
                    ),
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
