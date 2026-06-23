class MapAsset {
  final String png;
  final int rows;
  final int cols;
  const MapAsset({
    required this.png,
    required this.rows,
    required this.cols,
  });
}

// Keyed by mapId — the id the backend assigns and that the asset files
// (assets/map/{id}.png) are named after. Only ids with a bundled base image
// belong here; any other map falls back to the cell renderer.
const Map<int, MapAsset> kMapAssets = {
  1: MapAsset(png: 'assets/map/1.png', rows: 33, cols: 57),
  2: MapAsset(png: 'assets/map/2.png', rows: 140, cols: 500),
  5: MapAsset(png: 'assets/map/5.png', rows: 300, cols: 500),
};
