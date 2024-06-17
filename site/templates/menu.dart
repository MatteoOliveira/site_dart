import 'package:mustache_template/mustache.dart';
import 'package:http/http.dart' as http;

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

  var template = new Template(source, name: 'index.html');

  var output = template.renderString({
    'names': [
      {'firstname': 'Greg', 'lastname': 'Lowe'},
      {'firstname': 'Bob', 'lastname': 'Johnson'}
    ]
  });

  print(output);
}
