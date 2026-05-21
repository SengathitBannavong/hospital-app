double baseSpeedFor(String modeId) {
  return switch (modeId) {
    'wheelchair' => 4,
    'stretcher' => 3,
    'hospital_cart' => 3,
    _ => 6,
  };
}

double modeCostMultiplier(String modeId) {
  return switch (modeId) {
    'wheelchair' => 1.15,
    'stretcher' => 1.35,
    'hospital_cart' => 1.2,
    _ => 1,
  };
}
