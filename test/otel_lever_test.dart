// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_lever/otel_lever.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_lever-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('opportunities.create records origin + stage + posting', () async {
    await tracedLever<String>(
      operation: 'opportunities.create',
      invoke: () async => const LeverCallResult(
        value: 'ok',
        result: LeverResult(
          performAsUserId: 'u_1',
          opportunityId: 'opp_1',
          opportunityStage: 'phone_screen',
          opportunityOrigin: 'referred',
          archived: false,
          postingId: 'post_1',
          postingState: 'published',
          requisitionId: 'req_1',
          applicationType: 'referral',
          statusCode: 201,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('lever opportunities.create')!);
    expect(a['lever.perform_as.user_id'], 'u_1');
    expect(a['lever.opportunity.stage'], 'phone_screen');
    expect(a['lever.opportunity.origin'], 'referred');
    expect(a['lever.posting.state'], 'published');
    expect(a['lever.application.type'], 'referral');
  });

  test('archived opportunity captures reason without span error', () async {
    await tracedLever<String>(
      operation: 'opportunities.archive',
      invoke: () async => const LeverCallResult(
        value: 'ok',
        result: LeverResult(
          opportunityId: 'opp_2',
          archived: true,
          archiveReason: 'Underqualified',
        ),
      ),
    );
    final s = spans.findSpanByName('lever opportunities.archive')!;
    expect(s.status, isNot(SpanStatusCode.Error));
    expect(attrsOf(s)['lever.archive.reason'], 'Underqualified');
  });

  test('feedback.create records template + rating', () async {
    await tracedLever<String>(
      operation: 'feedback.create',
      invoke: () async => const LeverCallResult(
        value: 'ok',
        result: LeverResult(
          interviewId: 'int_1',
          feedbackTemplate: 'Engineering Onsite',
          feedbackRating: 'strong_yes',
          statusCode: 201,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('lever feedback.create')!);
    expect(a['lever.feedback.template'], 'Engineering Onsite');
    expect(a['lever.feedback.rating'], 'strong_yes');
  });

  test('suppression skips spans', () async {
    await runWithoutLeverInstrumentationAsync(() async {
      await tracedLever<String>(
        operation: 'postings.list',
        invoke: () async => const LeverCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('lever '), isEmpty);
  });
}
