// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_lever/otel_lever.dart';

/// Traces Lever calls with OpenTelemetry.
///
/// `otel_lever` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Lever call in
/// [tracedLever]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'lever-example');

  // Wraps a Lever API call in a CLIENT span.
  final leverId = await tracedLever<String>(
    operation: 'opportunities.create',
    invoke: () async {
      // Make the Lever call here, then report what it returned.
      const id = 'lever_8f3a2c';
      return const LeverCallResult(
          value: id,
          result: LeverResult(
              performAsUserId: 'perform_as',
              entityKind: 'opportunity',
              entityId: 'entity_8f3a2c',
              opportunityId: 'opportunity_8f3a2c',
              opportunityStage: 'applicant',
              opportunityOrigin: 'referred',
              archived: true,
              archiveReason: 'example',
              postingId: 'posting_8f3a2c',
              postingState: 'published',
              requisitionId: 'requisition_8f3a2c',
              interviewId: 'interview_8f3a2c',
              interviewStatus: 'scheduled',
              feedbackTemplate: 'example',
              feedbackRating: 'example',
              applicationType: 'referral',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedLever opportunities.create returned $leverId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutLeverInstrumentationAsync.
  await runWithoutLeverInstrumentationAsync(
    () => tracedLever<String>(
      operation: 'opportunities.create',
      invoke: () async {
        const id = 'lever_8f3a2c';
        return const LeverCallResult(
            value: id,
            result: LeverResult(
                performAsUserId: 'perform_as',
                entityKind: 'opportunity',
                entityId: 'entity_8f3a2c',
                opportunityId: 'opportunity_8f3a2c',
                opportunityStage: 'applicant',
                opportunityOrigin: 'referred',
                archived: true,
                archiveReason: 'example',
                postingId: 'posting_8f3a2c',
                postingState: 'published',
                requisitionId: 'requisition_8f3a2c',
                interviewId: 'interview_8f3a2c',
                interviewStatus: 'scheduled',
                feedbackTemplate: 'example',
                feedbackRating: 'example',
                applicationType: 'referral',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
