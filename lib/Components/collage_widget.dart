import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class TwitterStyleCollage extends StatelessWidget {
  final List<String> imageUrls;

  const TwitterStyleCollage({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    int itemCount =
        imageUrls.length > 5 ? 5 : imageUrls.length; // Limit to 5 images

    return StaggeredGrid.count(
      crossAxisCount: 4, // Grid will always have 4 columns
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: _buildGridItems(itemCount), // Dynamically build grid items
    );
  }

  List<Widget> _buildGridItems(int itemCount) {
    List<Widget> gridItems = [];

    switch (itemCount) {
      case 1:
        gridItems
            .add(_buildImageTile(imageUrls[0], 4, 4)); // Single large image
        break;
      case 2:
        gridItems.add(
            _buildImageTile(imageUrls[0], 2, 4)); // Two side-by-side images
        gridItems.add(_buildImageTile(imageUrls[1], 2, 4));
        break;
      case 3:
        gridItems
            .add(_buildImageTile(imageUrls[0], 2, 3)); // One large image on top
        gridItems.add(
            _buildImageTile(imageUrls[1], 2, 2)); // Two smaller images below
        gridItems.add(_buildImageTile(imageUrls[2], 2, 1));
        break;
      case 4:
        gridItems.add(_buildImageTile(imageUrls[0], 2, 3));
        gridItems.add(_buildImageTile(imageUrls[1], 2, 2));
        for (int i = 1; i < 4; i++) {
          gridItems.add(
              _buildImageTile(imageUrls[i], 1, 1)); // Four equal-sized images
        }
        break;
      case 5:
        gridItems
            .add(_buildImageTile(imageUrls[0], 4, 2)); // One large image on top
        for (int i = 1; i < 5; i++) {
          gridItems.add(
              _buildImageTile(imageUrls[i], 1, 1)); // Four smaller images below
        }
        break;
    }

    return gridItems;
  }

  Widget _buildImageTile(
      String imageUrl, int crossAxisCount, int mainAxisCount) {
    return StaggeredGridTile.count(
      crossAxisCellCount: crossAxisCount,
      mainAxisCellCount: mainAxisCount,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
