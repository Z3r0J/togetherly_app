import 'package:flutter/foundation.dart';
import '../models/circle_event_models.dart';
import '../models/personal_event_models.dart';
import '../models/api_error.dart';
import '../services/event_service.dart';
import '../models/unified_calendar_models.dart';
import '../widgets/rsvp_widgets.dart';

class EventDetailViewModel extends ChangeNotifier {
  final EventService _eventService;

  EventDetailViewModel({EventService? eventService})
      : _eventService = eventService ?? EventService();

  bool _isLoading = false;
  bool _isActionLoading = false;
  ApiError? _error;
  CircleEventDetail? _circleEvent;
  PersonalEvent? _personalEvent;
  UnifiedEvent? _lastEvent;

  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  ApiError? get error => _error;
  CircleEventDetail? get circleEvent => _circleEvent;
  PersonalEvent? get personalEvent => _personalEvent;

  Future<void> load(UnifiedEvent event) async {
    _isLoading = true;
    _lastEvent = event;
    _error = null;
    notifyListeners();

    try {
      if (event is CircleUnifiedEvent) {
        _circleEvent = await _eventService.getCircleEventDetail(event.id);
        _personalEvent = null;
      } else if (event is PersonalUnifiedEvent) {
        _personalEvent = await _eventService.getPersonalEventDetail(event.id);
        _circleEvent = null;
      }
    } on ApiError catch (e) {
      _error = e;
    } catch (e) {
      _error = ApiError.unknownError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRsvp(String eventId, RsvpStatus status) async {
    _isActionLoading = true;
    notifyListeners();
    try {
      await _eventService.updateRsvp(eventId, status);
      if (_lastEvent != null) {
        await load(_lastEvent!);
      }
    } catch (e) {
      _error = e is ApiError ? e : ApiError.unknownError(e.toString());
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> voteTimeOption(String eventId, String optionId) async {
    _isActionLoading = true;
    notifyListeners();
    try {
      await _eventService.voteEventTime(eventId, optionId);
      if (_lastEvent != null) {
        await load(_lastEvent!);
      }
    } catch (e) {
      _error = e is ApiError ? e : ApiError.unknownError(e.toString());
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }
}
