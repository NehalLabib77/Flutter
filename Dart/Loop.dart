void main() {
  //* For loop
  for (int i = 0; i < 5; i++) {
    print('hello, world! ${i + 1}');
  }
  print(4);

  // * while loop
  var j = 1;
  while (j <= 5) {
    print('Dart is fun! $j');
    j++;
  }

  //* Do while loop
  var k = 1;
  do {
    print('Learning Dart! $k');
    k++;
  } while (k <= 5);
}
