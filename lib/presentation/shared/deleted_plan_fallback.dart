import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../navigation/app_router.dart';
import 'failure_feedback.dart';

/// F22 A1 (TD-094): the wording when a restored route names a plan that was
/// deleted meanwhile.
const deletedPlanMessage =
    'The plan you had open was deleted. Showing Tonight.';

/// Goes to Tonight and says why (F22 A1): the valid fallback for a restored
/// route whose plan no longer exists. After the current frame, so it may be
/// called while building.
void showDeletedPlanFallback(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    showFailure(context, deletedPlanMessage);
    context.go(AppRouter.tonight);
  });
}
