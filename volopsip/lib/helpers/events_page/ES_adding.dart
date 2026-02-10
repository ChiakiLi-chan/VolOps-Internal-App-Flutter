// file: helpers/esadd_helper.dart
import 'log_manager.dart';
import 'package:volopsip/repo/volunteer_repo.dart';
import 'package:volopsip/repo/events_repo.dart';

class ESAdding {
  static final VolunteerRepository volunteerRepo = VolunteerRepository();
  static final EventRepository eventRepo = EventRepository();

  /// Send a raw message to the log (used internally)
  static void sendInfoToLog(String message) {
    LogManager().addLog(message);
  }

  /// Process QR data and send volunteer info to log
  static Future<void> processQr({
    required String qrData,
    required String eventAttr,
    required String eventId, // keep as String for backward compatibility
  }) async {
    try {
      // Lookup volunteer by UUID
      final volunteer = await volunteerRepo.getVolunteerByUuid(qrData);

      if (volunteer == null) {
        sendInfoToLog('⚠️ Unknown QR Data: $qrData');
        return;
      }

      if (volunteer.id == null) {
        sendInfoToLog('⚠️ Volunteer ${volunteer.firstName} ${volunteer.lastName} has no ID');
        return;
      }

      // Convert eventId to int
      final parsedEventId = int.tryParse(eventId);
      if (parsedEventId == null) {
        sendInfoToLog('⚠️ Invalid Event ID: $eventId');
        return;
      }

      // Lookup event by ID
      final event = await eventRepo.getEventById(parsedEventId);
      final eventName = event?.name ?? 'Unknown Event';

      // Check if volunteer already assigned to this event
      final assignedVolunteers = await eventRepo.getAssignedVolunteersWithAttribute(parsedEventId);
      final alreadyAssigned = assignedVolunteers.any((v) => v['volunteer_id'] == volunteer.id);

      // Add or update volunteer in event (repo unchanged)
      await eventRepo.addVolunteerToEventWithAttribute(
        volunteer.id!, 
        parsedEventId,
        eventAttr,
      );

      // Build log message based on whether new or updated
      final message = alreadyAssigned
          ? 'Updated ${volunteer.firstName} ${volunteer.lastName} to $eventAttr in $eventName'
          : 'Added ${volunteer.firstName} ${volunteer.lastName} as $eventAttr to $eventName';

      sendInfoToLog(message);

    } catch (e) {
      sendInfoToLog('Error processing QR Data $qrData: $e');
    }
  }


}
