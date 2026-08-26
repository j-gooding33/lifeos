import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// §3.4 deep-link aliases that map onto real in-app routes. `/occurrence/:id`
/// isn't here: it needs an `OccurrenceRepository` lookup (occurrence → its
/// parent plan) that doesn't exist until M7, so for now it's its own
/// honest placeholder route rather than a guess. See DECISIONS.md.
String taskDeepLinkRedirect(BuildContext context, GoRouterState state) =>
    '/tasks/${state.pathParameters['id']}';

String planDeepLinkRedirect(BuildContext context, GoRouterState state) =>
    '/plans/${state.pathParameters['id']}';

String dayDeepLinkRedirect(BuildContext context, GoRouterState state) =>
    '/home/day/${state.pathParameters['date']}';
