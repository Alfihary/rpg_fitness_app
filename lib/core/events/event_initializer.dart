import 'event_bus.dart';
import '../../features/rpg/game_engine.dart';

void initEventSystem(GameEngine engine) {
  eventBus.stream.listen((event) {
    engine.handle(event);
  });
}
