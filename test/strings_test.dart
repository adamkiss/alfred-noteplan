import 'package:alfred_noteplan/strings.dart';
import 'package:test/test.dart';

void main() {
	String edgy = "ThiS iS vEry edGY!";
	test('Capitalized (sentence) case', () {
		expect(edgy.toCapitalized(), "This is very edgy!");
	});
	test('Title case', () {
		expect(edgy.toTitleCase(), "This Is Very Edgy!");
	});
	test('Split format and capitalize', (){
		// noop
	});

	String markdown = '''
		# Header 1

		- item 1
		- item 2
		- item 3

		* item 1
		* item 2
		* **bold item 3**
	''';
	test("Unindent", () {
		expect(markdown.unindent(), '''
# Header 1

- item 1
- item 2
- item 3

* item 1
* item 2
* **bold item 3**
	''');
	});


	test("FTS Cleaning", () {
		expect(markdown.unindent().cleanForFts(), '''Header 1
item 1
item 2
item 3
item 1
item 2
bold item 3''');
	});
}
