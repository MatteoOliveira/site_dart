import 'package:mustache_template/mustache.dart';

main() {
  var source = '''
	  {{# names }}
            <div>{{ lastname }}, {{ firstname }}</div>
	  {{/ names }}
	  {{^ names }}
	    <div>No names.</div>
	  {{/ names }}
	  {{! I am a comment. }}
	''';

  var template = new Template(source, name: 'header.html');

  var output = template.renderString({
    'names': [
      {'firstname': 'Greg', 'lastname': 'Lowe'},
      {'firstname': 'Bob', 'lastname': 'Johnson'}
    ]
  });

  print(output);
}
