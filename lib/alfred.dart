/*
 * Helper functions for Alfred
 *
 * - alf_to_results
 * - alf_invalid_item
 * - alf_valid_item
 */

import 'dart:convert';

String alf_to_results (List<Map> results) {
	return jsonEncode({'items': results});
}

Map<String, dynamic> alf_valid_item (
	String title,
	String subtitle,
	{
		Map? icon,
		Map? arg,
		Map? mods,
		Map? variables,
		Map? text,
		String? quicklookurl
	}
) {
	final Map<String, dynamic> result = {
		'title': title,
		'subtitle': subtitle,
		'valid': true
	};
	if (icon != null) { result['icon'] = icon; }
	if (arg != null)  { result['arg']  = arg;}
	if (mods != null) { result['mods'] = mods; }
	if (text != null) { result['text'] = text; }
	if (variables != null) { result['variables'] = variables; }
	if (quicklookurl != null) { result['quicklookurl'] = quicklookurl; }
	return result;
}

Map<String, dynamic> alf_invalid_item (
	String title,
	String subtitle,
	{
		Map? icon,
		Map? arg,
		Map? mods,
		Map? variables,
		Map? text,
		String? quicklookurl
	}
) {
	final Map<String, dynamic> result = {
		'title': title,
		'subtitle': subtitle,
		'valid': false
	};
	if (icon != null) { result['icon'] = icon; }
	if (arg != null)  { result['arg']  = arg;}
	if (mods != null) { result['mods'] = mods; }
	if (text != null) { result['text'] = text; }
	if (variables != null) { result['variables'] = variables; }
	if (quicklookurl != null) { result['quicklookurl'] = quicklookurl; }
	return result;
}