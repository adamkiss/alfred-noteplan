import 'package:alfred_noteplan_fts_refresh/config.dart';
import 'package:alfred_noteplan_fts_refresh/refresh.dart';

void main(List<String> arguments) {
	Config.init();

	switch (arguments.isEmpty ? 'top' : arguments[0]) {
	 	case 'refresh':
	  		refresh(force: arguments.length > 1 && arguments[1] == 'force');
			break;
	  	default:
			print('noop.');
	}
}