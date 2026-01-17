int x = 23;
double y = 23.5;
String name = "Dart Programming";
bool isDartFun = true;

List<int> numbers = [1, 2, 3, 4, 5];
Map<String, String> capitals = {
  'USA': 'Washington, D.C.',
  'France': 'Paris',
  'Japan': 'Tokyo',
};
Set<String> fruits = {'apple', 'banana', 'orange'};

var dynamicVariable = 'I can be anything';
const pi = 3.14159;
final currentTime = DateTime.now();

// $ - It allows you to insert variables or expressions directly inside a string.
void main() {
  print('Integer: $x');
  print('Double: $y');
  print('String: $name');
  print('Boolean: $isDartFun');
  print('List: $numbers');
  print('Map: $capitals');
  print('Set: $fruits');
  print('Dynamic Variable: $dynamicVariable');
  print('Constant pi: $pi');
  print('Final currentTime: $currentTime');
}
