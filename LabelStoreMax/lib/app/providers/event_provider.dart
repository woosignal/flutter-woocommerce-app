import '/bootstrap/events.dart';
import 'package:nylo_framework/nylo_framework.dart';

class EventProvider implements NyProvider {
  @override
  setup(Nylo nylo) async {
    nylo.addEvents(events);

    return nylo;
  }

  @override
  boot(Nylo nylo) async {
    nylo.addEventBus();
  }
}
