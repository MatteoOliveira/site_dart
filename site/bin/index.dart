import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mustache_template/mustache_template.dart';

void main() async {
  const jsonUrl = 'http://data.atontour.info/patrimoine.json';
  const buildDir = 'build';
  const templatesDir = 'templates';

  try {
    // Fetch JSON data
    final jsonData = await fetchJsonData(jsonUrl);
    print('Fetched JSON Data:');
    print(jsonData); // Debugging step

    // Destroy and recreate build directory
    await recreateBuildDirectory(buildDir);

    // Render each section with its respective Mustache template
    final header = await renderHeader(jsonData, templatesDir);
    final main = await renderMain(jsonData, templatesDir);
    final footer = await renderFooter(templatesDir);

    // Combine sections into a single HTML file
    await renderLayout(header, main, footer, buildDir, templatesDir);

    print('HTML file generated successfully.');
  } catch (e) {
    print('An error occurred: $e');
  }
}

Future<dynamic> fetchJsonData(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load JSON data');
  }
}

Future<void> recreateBuildDirectory(String buildDir) async {
  final directory = Directory(buildDir);
  if (await directory.exists()) {
    await directory.delete(recursive: true);
  }
  await directory.create();
}

Future<String> renderHeader(dynamic jsonData, String templatesDir) async {
  final templateString =
      await File('$templatesDir/header.mustache').readAsString();
  final template = Template(templateString, htmlEscapeValues: false);

  // Extract departments from JSON data
  final departments =
      jsonData.map((site) => site['departement']).toSet().toList();
  final departmentData = departments.map((department) {
    return {'name': department};
  }).toList();

  return template.renderString({'departement': departmentData});
}

Future<String> renderFooter(String templatesDir) async {
  final templateString =
      await File('$templatesDir/footer.mustache').readAsString();
  final template = Template(templateString, htmlEscapeValues: false);
  return template.renderString({});
}

Future<String> renderMain(dynamic jsonData, String templatesDir) async {
  final templateString =
      await File('$templatesDir/main.mustache').readAsString();
  final template = Template(templateString, htmlEscapeValues: false);

  final jsonContent = jsonEncode(jsonData);
  return template.renderString({'jsonContent': jsonContent});
}

Future<void> renderLayout(String header, String main, String footer,
    String buildDir, String templatesDir) async {
  final templateString =
      await File('$templatesDir/layout.mustache').readAsString();
  final template = Template(templateString, htmlEscapeValues: false);

  final output = template.renderString({
    'header': header,
    'main': main,
    'footer': footer,
  });

  final outputFile = File('$buildDir/index.html');
  await outputFile.writeAsString(output);
}
