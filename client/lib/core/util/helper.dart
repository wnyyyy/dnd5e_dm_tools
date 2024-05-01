int getModifier(int value) {
  return (value - 10) ~/ 2;
}

int getProfBonus(int level) {
  return ((level - 1) ~/ 4) + 2;
}
