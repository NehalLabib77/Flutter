void main() {
  printCities("New York", "New Delhi", "Sydney");
  print("");

  printCountries("USA", "Bangladesh");
}

// Required Parameters
void printCities(String name1, String name2, String name3) {
  print("Name 1 is $name1");
  print("Name 2 is $name2");
  print("Name 3 is $name3");
}

// Optional Positional Parameters
void printCountries(String name1, [String? name4, String? name5]) {
  print("Name 1 is $name1");
  print("Name 2 is $name4");
  print("Name 3 is $name5");
}
