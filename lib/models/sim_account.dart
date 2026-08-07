// lib/models/sim_account.dart
//
// One call-capable SIM / phone account, as reported by the native Telecom
// bridge (`MainActivity.getSimAccounts`). Read-only; never persisted.
//
// [phoneAccountId] is the key that ties everything together: it's what we pass
// back to route a call over this SIM, and it matches the device call log's
// PHONE_ACCOUNT_ID (so [CallEventLogger]/reconcile can map a logged call to its
// SIM label).
class SimAccount {
  /// The `PhoneAccountHandle` id — the subscription id as a string on stock
  /// Android. Used to place calls and to match device-call-log rows.
  final String phoneAccountId;

  /// Flattened `ComponentName` of the account's connection service; needed to
  /// rebuild the handle natively when placing a call.
  final String componentName;

  /// The `PhoneAccount` label (e.g. the carrier), when available.
  final String? label;

  final int? subscriptionId;

  /// 0-based SIM slot, when a matching subscription was found.
  final int? slotIndex;

  /// The user-facing subscription name (often the carrier or a custom name).
  final String? displayName;

  final String? carrierName;

  const SimAccount({
    required this.phoneAccountId,
    required this.componentName,
    this.label,
    this.subscriptionId,
    this.slotIndex,
    this.displayName,
    this.carrierName,
  });

  /// Best human label for the SIM: the subscription display name, else the
  /// account/carrier label, else a slot-based fallback ("SIM 1").
  String get displayLabel {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final lbl = label?.trim();
    if (lbl != null && lbl.isNotEmpty) return lbl;
    final carrier = carrierName?.trim();
    if (carrier != null && carrier.isNotEmpty) return carrier;
    if (slotIndex != null) return 'SIM ${slotIndex! + 1}';
    return 'SIM';
  }

  factory SimAccount.fromMap(Map<dynamic, dynamic> map) {
    return SimAccount(
      phoneAccountId: (map['phoneAccountId'] as String?) ?? '',
      componentName: (map['componentName'] as String?) ?? '',
      label: map['label'] as String?,
      subscriptionId: (map['subscriptionId'] as num?)?.toInt(),
      slotIndex: (map['slotIndex'] as num?)?.toInt(),
      displayName: map['displayName'] as String?,
      carrierName: map['carrierName'] as String?,
    );
  }
}
