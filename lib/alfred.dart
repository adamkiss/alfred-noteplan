/*
 * Helper functions for Alfred
 *
 * - alf_to_results
 * - alf_invalid_item
 * - alf_valid_item
 */

import 'dart:convert';
import 'dart:io';

import 'package:alfred_noteplan/strings.dart';

String alf_to_results (List<Map> results) {
	return jsonEncode({'items': results});
}

void alf_exit(List<Map> results) {
	print(alf_to_results(results));
	exit(0);
}

Map<String, dynamic> alf_item (
	String title,
	String subtitle,
	{
		String? uid,
		Map? icon,
		String? arg,
		Map? mods,
		Map? variables,
		Map? text,
		String? quicklookurl,
		bool valid = true
	}
) {
	final Map<String, dynamic> result = {
		'title': title,
		'subtitle': subtitle,
		'valid': valid
	};
	if (uid != null)  { result['uid'] = uid; }
	if (icon != null) { result['icon'] = icon; }
	if (arg != null)  { result['arg']  = arg;}
	if (mods != null) { result['mods'] = mods; }
	if (text != null) { result['text'] = text; }
	if (variables != null) { result['variables'] = variables; }
	if (quicklookurl != null) { result['quicklookurl'] = quicklookurl; }
	return result;
}

Map<String, dynamic> alf_create_item(String query) => alf_item(
	'Create "${query}"',
	str_create_result_subtitle,
	icon: {'path': 'icons/icon-create.icns'},
	arg: query,
	variables: {'action': 'create'}
);