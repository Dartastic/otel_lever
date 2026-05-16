// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_lever_suppression.dart';

const _tracerName = 'dartastic_otel_libs_lever';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class LeverResult {
  const LeverResult({
    this.performAsUserId,
    this.entityKind,
    this.entityId,
    this.opportunityId,
    this.opportunityStage,
    this.opportunityOrigin,
    this.archived,
    this.archiveReason,
    this.postingId,
    this.postingState,
    this.requisitionId,
    this.interviewId,
    this.interviewStatus,
    this.feedbackTemplate,
    this.feedbackRating,
    this.applicationType,
    this.statusCode,
  });

  /// `perform_as` query — the user id Lever should attribute the
  /// write to.
  final String? performAsUserId;

  /// `opportunity` / `posting` / `requisition` / `interview` /
  /// `feedback` / `note` / `referral` / `offer` / `tag` / `user` /
  /// `application` / `eeo` / `archive_reason`.
  final String? entityKind;

  final String? entityId;

  /// Lever's defining unit — an opportunity is one person's
  /// candidacy across postings.
  final String? opportunityId;

  /// `applicant` / `recruiter_screen` / `phone_screen` / `onsite` /
  /// `offer` / `hired` / `archived` (job-defined; these are common
  /// values).
  final String? opportunityStage;

  /// `referred` / `sourced` / `applied` / `university` / `agency`.
  final String? opportunityOrigin;

  /// `true` when the opportunity is in the archive (rejected /
  /// withdrew / hired-elsewhere / etc.).
  final bool? archived;

  /// Lever-defined archive reason ("Underqualified", "Not interested",
  /// "Hired", ...).
  final String? archiveReason;

  final String? postingId;

  /// `published` / `internal` / `closed` / `draft` / `pending` /
  /// `rejected`.
  final String? postingState;

  /// Requisition the posting is filling.
  final String? requisitionId;

  final String? interviewId;

  /// `scheduled` / `completed` / `cancelled` / `pending_feedback`.
  final String? interviewStatus;

  final String? feedbackTemplate;

  /// Free-text rating (template-defined).
  final String? feedbackRating;

  /// `referral` / `submitted_directly` / `university` / `agency` /
  /// `posting_apply` / `manual` — how the candidate entered the
  /// pipeline.
  final String? applicationType;

  final int? statusCode;
}

class LeverCallResult<T> {
  const LeverCallResult({required this.value, this.result});
  final T value;
  final LeverResult? result;
}

/// Wraps a Lever API call in a CLIENT span. [operation] is one of
/// `opportunities.list`, `opportunities.create`, `opportunities.advance`,
/// `opportunities.archive`, `postings.list`, `postings.create`,
/// `requisitions.list`, `interviews.list`, `feedback.create`,
/// `notes.create`, `referrals.create`, `tags.list`,
/// `archive_reasons.list`.
Future<T> tracedLever<T>({
  required String operation,
  required Future<LeverCallResult<T>> Function() invoke,
}) async {
  if (leverInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'lever',
    'rpc.method': operation,
    'lever.operation': operation,
  };

  final span = _tracer().startSpan(
    'lever $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.performAsUserId != null) {
        extras.add(OTel.attributeString(
          'lever.perform_as.user_id',
          r.result!.performAsUserId!,
        ));
      }
      if (r.result!.entityKind != null) {
        extras.add(OTel.attributeString(
          'lever.entity.kind',
          r.result!.entityKind!,
        ));
      }
      if (r.result!.entityId != null) {
        extras.add(OTel.attributeString(
          'lever.entity.id',
          r.result!.entityId!,
        ));
      }
      if (r.result!.opportunityId != null) {
        extras.add(OTel.attributeString(
          'lever.opportunity.id',
          r.result!.opportunityId!,
        ));
      }
      if (r.result!.opportunityStage != null) {
        extras.add(OTel.attributeString(
          'lever.opportunity.stage',
          r.result!.opportunityStage!,
        ));
      }
      if (r.result!.opportunityOrigin != null) {
        extras.add(OTel.attributeString(
          'lever.opportunity.origin',
          r.result!.opportunityOrigin!,
        ));
      }
      if (r.result!.archived != null) {
        extras.add(OTel.attributeBool(
          'lever.opportunity.archived',
          r.result!.archived!,
        ));
      }
      if (r.result!.archiveReason != null) {
        extras.add(OTel.attributeString(
          'lever.archive.reason',
          r.result!.archiveReason!,
        ));
      }
      if (r.result!.postingId != null) {
        extras.add(OTel.attributeString(
          'lever.posting.id',
          r.result!.postingId!,
        ));
      }
      if (r.result!.postingState != null) {
        extras.add(OTel.attributeString(
          'lever.posting.state',
          r.result!.postingState!,
        ));
      }
      if (r.result!.requisitionId != null) {
        extras.add(OTel.attributeString(
          'lever.requisition.id',
          r.result!.requisitionId!,
        ));
      }
      if (r.result!.interviewId != null) {
        extras.add(OTel.attributeString(
          'lever.interview.id',
          r.result!.interviewId!,
        ));
      }
      if (r.result!.interviewStatus != null) {
        extras.add(OTel.attributeString(
          'lever.interview.status',
          r.result!.interviewStatus!,
        ));
      }
      if (r.result!.feedbackTemplate != null) {
        extras.add(OTel.attributeString(
          'lever.feedback.template',
          r.result!.feedbackTemplate!,
        ));
      }
      if (r.result!.feedbackRating != null) {
        extras.add(OTel.attributeString(
          'lever.feedback.rating',
          r.result!.feedbackRating!,
        ));
      }
      if (r.result!.applicationType != null) {
        extras.add(OTel.attributeString(
          'lever.application.type',
          r.result!.applicationType!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Lever HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
