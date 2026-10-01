// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionBlock => 'Block';

  @override
  String get titleBlockedNumbers => 'Blocked numbers';

  @override
  String get titleBlockNumber => 'Block a number';

  @override
  String get labelPhoneNumber => 'Phone number';

  @override
  String get hintPhoneNumberExample => 'e.g. +91 98765 43210';

  @override
  String get errorNotAPhoneNumber => 'That doesn’t look like a number';

  @override
  String msgNumberUnblocked(String number) {
    return '$number unblocked';
  }

  @override
  String get labelBlockUnknownCallers => 'Block unknown';

  @override
  String get descBlockUnknownCallers =>
      'Reject calls that don’t show a number (hidden or private callers)';

  @override
  String get descBlockedNumbersInfo =>
      'Blocked numbers never ring. Blocking works while SreerajP Contacts Sphere is your default phone app and matches the exact number.';

  @override
  String get actionAddNumber => 'Add a number';

  @override
  String get descAddNumber => 'Calls from it will be rejected before ringing';

  @override
  String get emptyBlockedNumbers => 'No blocked numbers yet.';

  @override
  String labelBlockedCount(int count) {
    return 'Blocked ($count)';
  }

  @override
  String labelBlockedOn(String date) {
    return 'Blocked $date';
  }

  @override
  String get tooltipUnblock => 'Unblock';

  @override
  String get titleLanguage => 'Language';

  @override
  String get labelSystemDefault => 'System default';

  @override
  String get descLanguageSystemDefault =>
      'Use the phone’s language when it is English, Malayalam or Sanskrit';

  @override
  String semanticsLanguageSetting(String language) {
    return 'Language, currently $language';
  }

  @override
  String get languageNameEn => 'English';

  @override
  String get languageNameMl => 'മലയാളം';

  @override
  String get languageNameSa => 'संस्कृतम्';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionClose => 'Close';

  @override
  String get actionDone => 'Done';

  @override
  String get actionTryAgain => 'Try again';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionChange => 'Change';

  @override
  String get navContacts => 'Contacts';

  @override
  String get navDialer => 'Dialer';

  @override
  String get navRecents => 'Recents';

  @override
  String get navTags => 'Tags';

  @override
  String get msgSwipeAgainToExit => 'Swipe right again to exit';

  @override
  String get tooltipReturnToCall => 'Return to call';

  @override
  String get msgAddingCallToOngoing => 'Adding call to ongoing call…';

  @override
  String labelContactCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts',
      one: '1 contact',
    );
    return '$_temp0';
  }

  @override
  String msgTagMerged(String tag, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts moved',
      one: '1 contact moved',
    );
    return 'Merged into #$tag ($_temp0)';
  }

  @override
  String msgTagRenamed(String tag) {
    return 'Renamed to #$tag';
  }

  @override
  String errorCouldNotRename(String error) {
    return 'Could not rename: $error';
  }

  @override
  String errorCouldNotMerge(String error) {
    return 'Could not merge: $error';
  }

  @override
  String errorCouldNotDelete(String error) {
    return 'Could not delete: $error';
  }

  @override
  String titleDeleteTagConfirm(String tag) {
    return 'Delete #$tag?';
  }

  @override
  String get descDeleteUnusedTag =>
      'No contact uses this tag, so nothing else changes.';

  @override
  String get errorTagInUseAgain =>
      'Tag is in use again — remove its contacts first';

  @override
  String msgTagDeleted(String tag) {
    return 'Deleted #$tag';
  }

  @override
  String get actionRenameTag => 'Rename tag';

  @override
  String get actionMergeInto => 'Merge into…';

  @override
  String get descNoOtherTags => 'No other tags to merge into';

  @override
  String get actionDeleteTag => 'Delete tag';

  @override
  String descRemoveContactsFirst(int count) {
    return 'Remove its contacts first ($count)';
  }

  @override
  String titleRenameTag(String tag) {
    return 'Rename #$tag';
  }

  @override
  String get labelTagName => 'Tag name';

  @override
  String descTagAlreadyExists(String tag) {
    return '#$tag already exists. Both tags become one.';
  }

  @override
  String actionMergeIntoTag(String tag) {
    return 'Merge into #$tag';
  }

  @override
  String get actionRename => 'Rename';

  @override
  String titleMergeTagInto(String tag) {
    return 'Merge #$tag into';
  }

  @override
  String get labelToneGreat => 'Great';

  @override
  String get labelToneOkay => 'Okay';

  @override
  String get labelToneRough => 'Rough';

  @override
  String get labelIntentCatchUp => 'Catch-up';

  @override
  String get labelIntentWork => 'Work';

  @override
  String get labelIntentScheduling => 'Scheduling';

  @override
  String get labelIntentFollowUp => 'Follow-up';

  @override
  String get labelIntentFamily => 'Family';

  @override
  String get labelIntentUrgent => 'Urgent';

  @override
  String get titleHowDidItGo => 'How did it go?';

  @override
  String labelCallWith(String name) {
    return 'Call with $name';
  }

  @override
  String get labelWhatWasItAbout => 'What was it about?';

  @override
  String get labelNotes => 'Notes';

  @override
  String get hintAnythingWorthRemembering => 'Anything worth remembering?';

  @override
  String get labelAddFollowUpReminder => 'Follow-up reminder';

  @override
  String get descFollowUpSavedForReference =>
      'Saved for reference — notifications coming soon';

  @override
  String get hintFollowUpExample => 'e.g. Send the contract';

  @override
  String get hintPickFollowUpTime => 'Pick date & time (optional)';

  @override
  String titleSendContacts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Send $count contacts',
      one: 'Send 1 contact',
    );
    return '$_temp0';
  }

  @override
  String get errorBluetoothOff => 'Bluetooth is off. Turn it on and try again.';

  @override
  String get errorBleUnsupported =>
      'This phone can\'t share over Bluetooth LE.';

  @override
  String get errorBluetoothPermissionDenied =>
      'Bluetooth permission was denied.';

  @override
  String get errorCouldNotStartBleShare => 'Could not start Bluetooth sharing.';

  @override
  String get errorBleShareFailed => 'Bluetooth sharing failed.';

  @override
  String get actionReceiveViaBluetooth => 'Get via Bluetooth';

  @override
  String descBleReceiveHowTo(String menuItem) {
    return 'On the other phone, open SreerajP Contacts Sphere and choose “$menuItem” from the contacts menu.';
  }

  @override
  String get labelIncludePhotos => 'Include photos';

  @override
  String get msgStartingBleShare => 'Starting Bluetooth sharing…';

  @override
  String get msgWaitingForNearbyPhone => 'Waiting for a nearby phone…';

  @override
  String get msgSending => 'Sending…';

  @override
  String msgSendingPercent(int percent) {
    return 'Sending… $percent%';
  }

  @override
  String get msgSent => 'Sent.';

  @override
  String get errorBlePermissionNeeded =>
      'Bluetooth permission is needed to share. Allow Nearby devices for SreerajP Contacts Sphere and try again.';

  @override
  String get errorNoPhoneConnected =>
      'No phone connected. Try again when the receiver is ready.';

  @override
  String get titleIncomingTransfer => 'Incoming transfer';

  @override
  String get descNearbyDeviceWantsToSend =>
      'A nearby device wants to send you contacts.';

  @override
  String get descReceiveThisTransfer => 'Do you want to receive this transfer?';

  @override
  String get actionDecline => 'Decline';

  @override
  String get actionAccept => 'Accept';

  @override
  String get descAuthReasonBleReceive =>
      'Authenticate to receive a Bluetooth transfer';

  @override
  String get titleAuthenticateToReceive => 'Verify to receive';

  @override
  String get errorAuthFailedBle =>
      'Authentication failed. Try again or decline the transfer.';

  @override
  String get descVerifyIdentityBle =>
      'Verify your identity to accept this Bluetooth transfer.';

  @override
  String get labelVerifying => 'Verifying…';

  @override
  String get titleEnterPinToReceive => 'Enter PIN to receive';

  @override
  String get errorWrongPinTryAgain => 'Wrong PIN — try again';

  @override
  String get descEnterPinBle =>
      'Enter your app PIN to accept this Bluetooth transfer.';

  @override
  String get errorCouldNotScheduleRetry => 'Could not schedule auto-retry';

  @override
  String msgAutoRetryAt(String time, String name) {
    return 'Auto-retry at $time for $name';
  }

  @override
  String get actionView => 'View';

  @override
  String get titleAllowAlarmsReminders => 'Allow alarms';

  @override
  String get descAlarmsPermission =>
      'Auto-Retry needs the \"Alarms & reminders\" permission so it can call back on schedule even if this app is closed. Enable it for SreerajP Contacts Sphere in the settings screen that opens next.';

  @override
  String get actionOpenSettings => 'Open settings';

  @override
  String get errorCouldNotLaunchMessaging => 'Could not launch messaging app';

  @override
  String get titleCallUnanswered => 'Call Unanswered';

  @override
  String get labelOptionAutoRetry => '1. Auto-retry';

  @override
  String get labelOptionReachMe => '2. Reach-me message';

  @override
  String actionAutoRetryIn(int minutes) {
    return 'Auto-Retry in $minutes min';
  }

  @override
  String get tooltipEditMessage => 'Edit message';

  @override
  String get hintReachMeMessage => 'Type your reach me message...';

  @override
  String get actionSendReachMeSms => 'Send reach-me SMS';

  @override
  String get actionDismiss => 'Dismiss';

  @override
  String labelMinutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get labelDefaultSim => 'Default SIM';

  @override
  String get labelSimToDial => 'SIM to dial:';

  @override
  String get titleSelectSimForRetry => 'SIM for auto-retry';

  @override
  String get labelFieldName => 'Name';

  @override
  String get labelFieldPhone => 'Phone';

  @override
  String get labelFieldEmail => 'Email';

  @override
  String get labelFieldDesignation => 'Designation';

  @override
  String get labelFieldCompany => 'Company';

  @override
  String get labelFieldStreet => 'Street';

  @override
  String get labelFieldCity => 'City';

  @override
  String get labelFieldState => 'State';

  @override
  String get labelFieldPostalCode => 'Postal code';

  @override
  String get labelFieldCountry => 'Country';

  @override
  String get labelFieldLink => 'Link';

  @override
  String get titleReadFromCard => 'Read from the card';

  @override
  String get descUntickWrongFields =>
      'Untick anything that came out wrong. You can still edit everything on the next screen.';

  @override
  String get emptyNoFieldsRead => 'No fields could be read from this card.';

  @override
  String descNotPlacedInField(String lines) {
    return 'Not placed in a field: $lines';
  }

  @override
  String get actionHideScannedText => 'Hide scanned text';

  @override
  String get actionShowScannedText => 'Show scanned text';

  @override
  String get emptyNothingRecognized => 'Nothing was recognized.';

  @override
  String get actionRetake => 'Retake';

  @override
  String get labelRelationshipLabel => 'Relationship label';

  @override
  String get hintRelationshipExample => 'e.g. Father';

  @override
  String get titlePickCategory => 'Pick a category';

  @override
  String titleHowIsRelated(String name) {
    return 'How is $name related?';
  }

  @override
  String get titleLinkContact => 'Link a contact';

  @override
  String get hintSearchContacts => 'Search contacts';

  @override
  String get emptyNoContactsAvailable => 'No contacts available';

  @override
  String titleWhereBelongs(String name) {
    return 'Where does $name belong?';
  }

  @override
  String get errorAirQrPayload =>
      'Could not generate AirQR payload for this contact.';

  @override
  String get labelFrameParity => 'Fountain Parity';

  @override
  String get labelFrameSystematic => 'Systematic Block';

  @override
  String descAirGapStream(int count) {
    return 'Optical Air-Gap Stream ($count frames)';
  }

  @override
  String get errorFrameRender => 'Frame rendering error';

  @override
  String labelFrameProgress(int current, int total, String type) {
    return 'Frame $current / $total • $type';
  }

  @override
  String get tooltipPauseStream => 'Pause stream';

  @override
  String get tooltipResumeStream => 'Resume stream';

  @override
  String errorCouldNotShareQr(String error) {
    return 'Could not share QR: $error';
  }

  @override
  String get descScanToAddContact =>
      'Scan with any phone camera to add this contact.';

  @override
  String get errorContactTooBigForQr =>
      'This contact has too much detail to fit in a QR code.';

  @override
  String get tooltipAirGapStream => 'Full-contact QR';

  @override
  String get actionShare => 'Share';

  @override
  String get titleScannedContact => 'Scanned Contact';

  @override
  String get titleSecurityCheck => 'Security Check';

  @override
  String labelContactsToImport(int count) {
    return 'To import ($count):';
  }

  @override
  String get labelUnnamedContact => 'Unnamed Contact';

  @override
  String labelPhonesList(String numbers) {
    return 'Phones: $numbers';
  }

  @override
  String labelEmailsList(String emails) {
    return 'Emails: $emails';
  }

  @override
  String labelWebLinksList(String links) {
    return 'Web Links: $links';
  }

  @override
  String get actionImportSafeOnly => 'Import Safe Only';

  @override
  String get actionImport => 'Import';

  @override
  String get actionImportAll => 'Import All';

  @override
  String get titleChooseContact => 'Choose a contact';

  @override
  String errorCouldNotLoadContacts(String error) {
    return 'Could not load contacts: $error';
  }

  @override
  String get tooltipClearSearch => 'Clear search';

  @override
  String get emptyNoContactsWithNumber => 'No contacts with a number yet.';

  @override
  String get emptyNoContactsYet => 'No contacts yet.';

  @override
  String emptyNoContactsMatch(String query) {
    return 'No contacts match “$query”.';
  }

  @override
  String get labelNoName => '(No name)';

  @override
  String get emptyNoContactsFound => 'No contacts found';

  @override
  String get actionAdd => 'Add';

  @override
  String get labelSuggested => 'Suggested';

  @override
  String get labelAllContacts => 'All contacts';

  @override
  String get labelAlreadyAdded => 'Already added';

  @override
  String get tooltipVoiceSearch => 'Voice search';

  @override
  String get errorVoiceUnavailable =>
      'Voice input is not available — check the microphone permission.';

  @override
  String get tooltipStopListening => 'Stop listening';

  @override
  String get labelDefaultPhoneApp => 'Default phone app';

  @override
  String get descHandlesYourCalls =>
      'SreerajP Contacts Sphere handles your calls';

  @override
  String get descSetAsDefaultDialer =>
      'Set SreerajP Contacts Sphere as your default dialer';

  @override
  String get errorCallPermissionDenied => 'Call permission denied';

  @override
  String errorCouldNotPlaceCall(String error) {
    return 'Could not place call: $error';
  }

  @override
  String get labelUsualSimForCall => 'Usual SIM';

  @override
  String get titleCallWith => 'Call with';

  @override
  String get descChooseSimForCall => 'Choose the SIM for this call';

  @override
  String titleCallName(String name) {
    return 'Call $name';
  }

  @override
  String get descChooseNumber => 'Choose a number';

  @override
  String get actionYes => 'Yes';

  @override
  String get actionNo => 'No';

  @override
  String get tooltipSettings => 'Settings';

  @override
  String get labelToday => 'Today';

  @override
  String get labelYesterday => 'Yesterday';

  @override
  String labelDurationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String labelDurationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String labelDurationMinutesSeconds(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String get labelOutcomeMissed => 'Missed';

  @override
  String get labelOutcomeNoAnswer => 'No answer';

  @override
  String get labelOutcomeBusy => 'Busy';

  @override
  String get labelOutcomeDeclined => 'Declined';

  @override
  String get labelOutcomeCancelled => 'Cancelled';

  @override
  String get labelOutcomeFailed => 'Failed';

  @override
  String get labelBlocked => 'Blocked';

  @override
  String get titleClearCallHistory => 'Clear call history?';

  @override
  String get descClearCallHistory =>
      'This removes all logged calls from SreerajP Contacts Sphere.';

  @override
  String get tooltipClearHistory => 'Clear history';

  @override
  String get hintSearchCalls => 'Search calls';

  @override
  String get emptyNoCallsYet => 'No calls yet. Calls you place show up here.';

  @override
  String get emptyNoCallsMatch => 'No calls match that search.';

  @override
  String get tooltipCallBack => 'Call back';

  @override
  String get actionBlockNumber => 'Block number';

  @override
  String get actionUnblockNumber => 'Unblock number';

  @override
  String get actionMarkAsSpam => 'Mark as spam';

  @override
  String get actionNotSpam => 'Not spam';

  @override
  String get actionSmartRedialReachMe => 'Smart Redial & Reach Me';

  @override
  String get actionCopyNumber => 'Copy number';

  @override
  String get actionShareNumber => 'Share number';

  @override
  String get actionRemoveFromHistory => 'Remove from history';

  @override
  String msgNumberBlocked(String number) {
    return '$number blocked — it can no longer ring you';
  }

  @override
  String msgMarkedAsSpam(String number) {
    return '$number marked as spam';
  }

  @override
  String msgNoLongerSpam(String number) {
    return '$number is no longer marked as spam';
  }

  @override
  String msgCopiedNumber(String number) {
    return 'Copied $number to clipboard';
  }

  @override
  String msgSpeedDialAssigned(String slot, String name) {
    return 'Key $slot now calls $name';
  }

  @override
  String msgCallingName(String name) {
    return 'Calling $name…';
  }

  @override
  String get actionHideKeypad => 'Hide keypad';

  @override
  String get tooltipBack => 'Back';

  @override
  String get titleKeypadDtmf => 'Keypad (DTMF)';

  @override
  String get titleAddCall => 'Add call';

  @override
  String get tooltipMore => 'More';

  @override
  String get titleSettings => 'Settings';

  @override
  String get hintStartTypingToFind => 'Start typing to find a contact';

  @override
  String get tooltipVoiceDialing => 'Voice dialing';

  @override
  String labelMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
    );
    return '$_temp0';
  }

  @override
  String get emptyNoContactForNumber => 'No saved contact for this number yet.';

  @override
  String emptyNoVoiceMatch(String query) {
    return 'No contact matches “$query”.';
  }

  @override
  String labelHeardQuery(String query) {
    return 'Heard “$query”';
  }

  @override
  String get emptyStarContact => 'Star a contact to see it here';

  @override
  String get labelFavorites => 'Favorites';

  @override
  String get labelFamilyFriends => 'Family & friends';

  @override
  String get labelLikelyToAnswer => 'Likely to answer now';

  @override
  String get labelTopContacts => 'Top contacts';

  @override
  String get actionAddToContacts => 'Add to contacts';

  @override
  String get tooltipCall => 'Call';

  @override
  String get tooltipBackspace => 'Backspace (hold to delete continuously)';

  @override
  String get labelUnknownCaller => 'Unknown';

  @override
  String get labelIncomingCall => 'Incoming call';

  @override
  String get labelCalling => 'Calling…';

  @override
  String get labelOnHold => 'On hold';

  @override
  String get labelCallEnded => 'Call ended';

  @override
  String get labelConnected => 'Connected';

  @override
  String get labelSecondCall => 'Second call';

  @override
  String get tooltipTapToSwitchCall => 'Tap to switch call';

  @override
  String labelNameOnHold(String name) {
    return '$name — on hold';
  }

  @override
  String get labelAboutThisContact => 'ABOUT THIS CONTACT';

  @override
  String get labelWhyCalling => 'WHY THEY ARE CALLING';

  @override
  String get labelCallerIdNotVerified => 'Caller ID not verified';

  @override
  String get labelReply => 'Reply';

  @override
  String get labelMute => 'Mute';

  @override
  String get labelHold => 'Hold';

  @override
  String get labelSpeaker => 'Speaker';

  @override
  String get labelKeypad => 'Keypad';

  @override
  String get labelMerge => 'Merge';

  @override
  String get labelSwap => 'Swap';

  @override
  String get labelConferenceCall => 'Conference call';

  @override
  String labelConferencePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get labelManage => 'Manage';

  @override
  String get titlePeopleOnCall => 'People on this call';

  @override
  String get actionPrivate => 'Private';

  @override
  String get actionDrop => 'Drop';

  @override
  String get tooltipPrivateTalk => 'Talk to them alone';

  @override
  String get tooltipDropFromCall => 'Remove from call';

  @override
  String get labelBlock => 'Block';

  @override
  String get titleUnblockThisNumber => 'Unblock this number?';

  @override
  String get titleBlockThisNumber => 'Block this number?';

  @override
  String descUnblockNumber(String number) {
    return 'Calls from $number will ring normally again.';
  }

  @override
  String descBlockNumberFuture(String number) {
    return 'Future calls from $number will be rejected before your phone rings.';
  }

  @override
  String get descCallWillDisconnect =>
      'This call will be disconnected immediately.';

  @override
  String get descManageBlockedNumbers =>
      'You can manage blocked numbers in Settings → Contacts → Blocked numbers.';

  @override
  String get actionUnblock => 'Unblock';

  @override
  String get titleReplyWithMessage => 'Reply with a message';

  @override
  String get descDeclinesAndTexts => 'Declines the call and texts the caller';

  @override
  String get actionWriteYourOwn => 'Write your own…';

  @override
  String get titleReplyWith => 'Reply with…';

  @override
  String get labelMessage => 'Message';

  @override
  String get hintTypeMessageToSend => 'Type a message to send';

  @override
  String get actionSend => 'Send';

  @override
  String get actionHide => 'Hide';

  @override
  String get errorRingtoneMissing =>
      'This ringtone is no longer available — pick a new one in Edit.';

  @override
  String get errorRingVolumeMuted =>
      'Ring volume is muted — turn it up to hear the preview.';

  @override
  String get actionShareVcard => 'Share as vCard (.vcf)';

  @override
  String get descShareVcard => 'Send the contact card to WhatsApp or any app';

  @override
  String get actionShareAsText => 'Share as Text';

  @override
  String get descShareAsText => 'Send name & phone numbers as a text message';

  @override
  String get actionCopyNamePhone => 'Copy Name & Phone';

  @override
  String get descCopyContactDetails => 'Copy contact details to clipboard';

  @override
  String get actionShareAsQr => 'Share as QR code';

  @override
  String get descShareAsQr => 'Show a scannable code or send it as an image';

  @override
  String get actionShareViaBluetooth => 'Share via Bluetooth';

  @override
  String get descSendToNearbyPhone => 'Send directly to a nearby phone';

  @override
  String errorCouldNotShareContact(String error) {
    return 'Could not share contact: $error';
  }

  @override
  String errorCouldNotShareText(String error) {
    return 'Could not share text: $error';
  }

  @override
  String get msgContactDetailsCopied => 'Contact details copied to clipboard';

  @override
  String errorCouldNotCopyDetails(String error) {
    return 'Could not copy contact details: $error';
  }

  @override
  String errorCouldNotCopyNumber(String error) {
    return 'Could not copy number: $error';
  }

  @override
  String errorFailedToLoadContact(String error) {
    return 'Failed to load contact: $error';
  }

  @override
  String get errorCouldNotOpenApp => 'Could not open this app.';

  @override
  String errorCouldNotUpdateFavorite(String error) {
    return 'Could not update favorite: $error';
  }

  @override
  String titleDeleteContactConfirm(String name) {
    return 'Delete $name?';
  }

  @override
  String get descDeleteContactAndDevice =>
      'Removes this contact from the app and the device address book.';

  @override
  String get descDeleteContactApp => 'Removes this contact from the app.';

  @override
  String errorDeleteFailed(String error) {
    return 'Delete failed: $error';
  }

  @override
  String get labelContact => 'Contact';

  @override
  String get tooltipAddToFavorites => 'Add to favorites';

  @override
  String get tooltipRemoveFromFavorites => 'Remove from favorites';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionRemove => 'Remove';

  @override
  String get emptyContactNotFound => 'Contact not found';

  @override
  String get labelBirthday => 'Birthday';

  @override
  String get labelAnniversary => 'Anniversary';

  @override
  String get labelMeetiversary => 'Meetiversary';

  @override
  String get labelGender => 'Gender';

  @override
  String get labelFormalName => 'Formal name';

  @override
  String get labelBloodGroup => 'Blood group';

  @override
  String get labelCustomRingtone => 'Custom ringtone';

  @override
  String get labelRingtone => 'Ringtone';

  @override
  String get tooltipStop => 'Stop';

  @override
  String get tooltipPreview => 'Preview';

  @override
  String get labelChosenSim => 'Chosen SIM';

  @override
  String get descCallsGoOutOnSim => 'Calls go out on this SIM';

  @override
  String get labelCallingCard => 'Calling card';

  @override
  String get labelRelationships => 'Relationships';

  @override
  String get tooltipViewSphere => 'View sphere';

  @override
  String get tooltipAddRelationship => 'Add relationship';

  @override
  String get emptyNoRelationships =>
      'No relationships yet. Tap the link icon to connect a contact.';

  @override
  String get tooltipEditType => 'Edit type';

  @override
  String get labelConnectedApps => 'Connected apps';

  @override
  String get descBirthdayComingUp => '🎂 Birthday coming up within a week';

  @override
  String descLastCall(String duration) {
    return 'Last call: $duration';
  }

  @override
  String descTheirTime(String time) {
    return 'Their time: $time';
  }

  @override
  String descRecentInteractions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recent interactions',
      one: '1 recent interaction',
    );
    return '$_temp0';
  }

  @override
  String get labelBeforeYouCall => 'Before you call';

  @override
  String descEphemeralAutoDelete(int count) {
    return 'Auto-deletes after 1 call ($count/1 calls logged)';
  }

  @override
  String get descEphemeralExpired => 'Expired — self-destructing soon...';

  @override
  String descEphemeralCountdown(String hours, String minutes, String seconds) {
    return 'Self-destructs in: ${hours}h ${minutes}m ${seconds}s';
  }

  @override
  String get labelEphemeralContact => 'Ephemeral Contact';

  @override
  String get labelSqlcipherLocalOnly => 'SQLCipher Local Only';

  @override
  String get actionAdd24Hours => '+24 Hours';

  @override
  String get actionKeepPermanently => 'Keep Permanently';

  @override
  String get actionScrubNow => 'Scrub Now';

  @override
  String get errorAuthRequiredSecret =>
      'Authentication required to view secret contacts';

  @override
  String msgDeletedName(String name) {
    return 'Deleted $name';
  }

  @override
  String titleDeleteContactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count contacts?',
      one: 'Delete 1 contact?',
    );
    return '$_temp0';
  }

  @override
  String get descDeleteSelected =>
      'Removes them from the app, and from the device address book where they are linked.';

  @override
  String msgDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deleted $count contacts',
      one: 'Deleted 1 contact',
    );
    return '$_temp0';
  }

  @override
  String msgDeletedCountFailed(int deleted, int failed) {
    return 'Deleted $deleted contacts, $failed failed';
  }

  @override
  String errorNoPhoneFor(String name) {
    return 'No phone number for $name';
  }

  @override
  String errorNoEmailFor(String name) {
    return 'No email address for $name';
  }

  @override
  String get errorNoEmailApp => 'No email app available';

  @override
  String get errorCouldNotOpenEmail => 'Could not open the email app';

  @override
  String get titleImportExport => 'Import / Export';

  @override
  String get actionImportCsv => 'Import CSV';

  @override
  String get actionExportCsv => 'Export CSV';

  @override
  String get actionImportVcf => 'Import vCard (.vcf)';

  @override
  String get actionExportVcf => 'Export vCard (.vcf)';

  @override
  String get titleBluetoothTransfer => 'Bluetooth transfer';

  @override
  String get actionSendAllViaBluetooth => 'Send all via Bluetooth';

  @override
  String msgImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count contacts',
      one: 'Imported 1 contact',
    );
    return '$_temp0';
  }

  @override
  String get msgNothingImported => 'Nothing imported';

  @override
  String errorImportFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String errorExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get errorNoContactsToSend => 'No contacts to send';

  @override
  String errorCouldNotStartBleShareDetail(String error) {
    return 'Could not start Bluetooth sharing: $error';
  }

  @override
  String get tooltipSecretContacts => 'Secret contacts';

  @override
  String get tooltipRelationStatus => 'Relation status';

  @override
  String get tooltipGroups => 'Groups';

  @override
  String get actionMyProfile => 'My Profile';

  @override
  String get actionScanQrCode => 'Scan QR code';

  @override
  String get actionScanBusinessCard => 'Scan business card';

  @override
  String get actionFindDuplicates => 'Find Duplicates';

  @override
  String get tooltipCancelSelection => 'Cancel selection';

  @override
  String labelSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get tooltipSelectAll => 'Select all';

  @override
  String get tooltipDeleteSelected => 'Delete selected';

  @override
  String get labelAll => 'All';

  @override
  String msgSyncingContacts(int processed, int total) {
    return 'Syncing contacts… $processed of $total';
  }

  @override
  String get msgReadingDeviceContacts => 'Reading device contacts…';

  @override
  String get emptyNoFavorites =>
      'No favorites yet.\nStar a contact to see it here.';

  @override
  String get emptyNoContactsTapPlus => 'No contacts yet. Tap + to add one.';

  @override
  String get labelOneCallBadge => '⏱️ 1-Call';

  @override
  String get labelEphemeralBadge => '⏱️ Ephemeral';

  @override
  String get labelYou => 'YOU';

  @override
  String get labelProfile => 'Profile';

  @override
  String labelDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String labelWeeksAgo(int count) {
    return '${count}w ago';
  }

  @override
  String labelMonthsAgo(int count) {
    return '${count}mo ago';
  }

  @override
  String labelYearsAgo(int count) {
    return '${count}y ago';
  }

  @override
  String get labelTypeMobile => 'Mobile';

  @override
  String get labelTypeHome => 'Home';

  @override
  String get labelTypeWork => 'Work';

  @override
  String get labelTypeMain => 'Main';

  @override
  String get labelTypeFax => 'Fax';

  @override
  String get labelTypeOther => 'Other';

  @override
  String get labelTypePersonal => 'Personal';

  @override
  String get labelTypeSchool => 'School';

  @override
  String get labelTypeWebsite => 'Website';

  @override
  String get labelGenderMale => 'Male';

  @override
  String get labelGenderFemale => 'Female';

  @override
  String get labelGenderNonBinary => 'Non-binary';

  @override
  String get labelGenderPreferNotToSay => 'Prefer not to say';

  @override
  String get labelAddressPersonal => 'Personal address';

  @override
  String get labelAddressOfficial => 'Work address';

  @override
  String errorCouldNotPickImage(String error) {
    return 'Could not pick image: $error';
  }

  @override
  String errorCouldNotPickCard(String error) {
    return 'Could not pick calling card: $error';
  }

  @override
  String get actionTakePhoto => 'Take photo';

  @override
  String get actionChooseFromGallery => 'Choose from gallery';

  @override
  String get errorCameraPermission =>
      'Camera permission is needed to take a photo.';

  @override
  String errorCouldNotPickRingtone(String error) {
    return 'Could not pick ringtone: $error';
  }

  @override
  String get titlePhoneRingtones => 'Phone ringtones';

  @override
  String get descPhoneRingtones => 'Choose from the ringtones on this device';

  @override
  String get titleAudioFile => 'Audio file';

  @override
  String get descAudioFile => 'Pick an audio file from your folders';

  @override
  String get errorRingtoneRevert =>
      'This ringtone is no longer available — reverting to default.';

  @override
  String get titleRemovePhone => 'Remove phone?';

  @override
  String get descRemovePhone => 'This phone will be removed from the contact.';

  @override
  String get titleRemoveEmail => 'Remove email?';

  @override
  String get descRemoveEmail => 'This email will be removed from the contact.';

  @override
  String get titleRemoveSocialLink => 'Remove social link?';

  @override
  String get descRemoveSocialLink =>
      'This social link will be removed from the contact.';

  @override
  String get errorFirstNameRequired => 'First name is required';

  @override
  String errorInvalidPhoneNumber(String number, String reason) {
    return 'Invalid phone number: $number ($reason)';
  }

  @override
  String get errorPhoneEmpty => 'Empty number';

  @override
  String get errorPhoneTooShort => 'Number is too short';

  @override
  String get errorPhoneTooLong => 'Number is too long';

  @override
  String errorPhoneInvalidFormatFor(String code) {
    return 'Invalid number format for +$code';
  }

  @override
  String get errorPhoneInvalidFormat => 'Invalid number format';

  @override
  String errorSaveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get labelPhoneNumbers => 'Phone numbers';

  @override
  String get actionAddPhone => 'Add phone';

  @override
  String get labelEmails => 'Emails';

  @override
  String get actionAddEmail => 'Add email';

  @override
  String get labelSocialLinks => 'Social links';

  @override
  String get hintUrlOrHandle => 'URL or @handle';

  @override
  String get actionAddSocialLink => 'Add social link';

  @override
  String get titleEditMe => 'Edit me';

  @override
  String get titleAddMe => 'Add me';

  @override
  String get titleEditContact => 'Edit contact';

  @override
  String get titleAddContact => 'Add contact';

  @override
  String get actionChangePhoto => 'Change photo';

  @override
  String get actionAddPhoto => 'Add photo';

  @override
  String get labelSalutation => 'Salutation';

  @override
  String get hintSalutation => 'Mr / Ms / Dr';

  @override
  String get labelFirstNameRequired => 'First name *';

  @override
  String get hintEnterFirstName => 'Enter first name';

  @override
  String get labelMiddleName => 'Middle name';

  @override
  String get labelLastName => 'Last name';

  @override
  String get hintOptional => 'Optional';

  @override
  String get hintFormalName => 'How the contact is formally addressed';

  @override
  String get labelPersonalDetails => 'Personal details';

  @override
  String get labelDateOfBirth => 'Date of birth';

  @override
  String get labelMeetiversaryDayYouMet => 'Meetiversary · the day you met';

  @override
  String get labelPreferredSim => 'Preferred SIM';

  @override
  String get descPreferredSim =>
      'Which SIM to call this person on. Leave it on Default to use your usual SIM.';

  @override
  String get descUseSimInSettings => 'Use the SIM set in Settings';

  @override
  String get labelOnThisPhone => 'On this phone';

  @override
  String get labelSelected => 'Selected';

  @override
  String get labelNone => 'None';

  @override
  String get actionAddCallingCard => 'Add calling card';

  @override
  String get descCallingCardShown => 'Photo shown full-screen during calls';

  @override
  String get labelSelect => 'Select';

  @override
  String get actionClear => 'Clear';

  @override
  String get hintDescribe => 'Describe';

  @override
  String get hintCustom => 'Custom';

  @override
  String get actionCustomLabel => '+ Custom';

  @override
  String get labelAddTag => 'Add tag';

  @override
  String get hintTypeAndEnter => 'Type and press enter';

  @override
  String get labelTagSuggestVip => 'VIP';

  @override
  String get labelTagSuggestMentor => 'Mentor';

  @override
  String get labelTagSuggestClient => 'Client';

  @override
  String get labelTagSuggestInvestor => 'Investor';

  @override
  String get labelTagSuggestNeighbor => 'Neighbor';

  @override
  String get labelAddToGroup => 'Add to group';

  @override
  String get hintGroupSearch => 'Type to search, * for all, or add new';

  @override
  String get descLinkToPeople => 'Link this contact to people they know.';

  @override
  String get actionAddAddress => 'Add address';

  @override
  String labelAddressNumber(int index) {
    return 'ADDRESS $index';
  }

  @override
  String get hintStreet => 'House no, street';

  @override
  String get labelCityTown => 'City / Town';

  @override
  String get labelCompanyName => 'Company name';

  @override
  String get hintWhereTheyWork => 'Where they work';

  @override
  String get labelOfficeStreet => 'Office / Street';

  @override
  String get hintBuildingStreet => 'Building, street';

  @override
  String get labelOfficialDetails => 'Official details';

  @override
  String get hintJobTitle => 'Title';

  @override
  String get labelDepartment => 'Department';

  @override
  String get hintTeam => 'Team';

  @override
  String get labelEphemeralToggle => '⏱️ Ephemeral contact';

  @override
  String get descEphemeralToggle =>
      'Temporary entry. Self-destructs automatically.';

  @override
  String get labelExpiryOptions => 'Expiry options';

  @override
  String get labelExpiry2Hours => '2 Hours';

  @override
  String get labelExpiry24Hours => '24 Hours';

  @override
  String get labelExpiry7Days => '7 Days';

  @override
  String get labelExpiryAfterOneCall => 'Auto-delete after 1 call';

  @override
  String get descEphemeralStorage =>
      'Stored exclusively in local SQLCipher DB. Never synced to Google or phone contacts.';

  @override
  String get labelSecretContact => 'Secret contact';

  @override
  String get descHiddenBehindAuth => 'Hidden behind authentication';

  @override
  String get titleSelectCountryCode => 'Select country code';

  @override
  String get hintSearchCountry => 'Search country or code';

  @override
  String emptyNoCountriesMatch(String query) {
    return 'No countries match “$query”';
  }

  @override
  String get titleSecurity => 'Security';

  @override
  String get descSecurityCard => 'App lock, block screenshots and audit log';

  @override
  String get titleSpeedDial => 'Speed Dial';

  @override
  String get descSpeedDialCard =>
      'Hold a keypad key 1-9 to call a saved person';

  @override
  String get descContactsCard => 'Your profile and contact options';

  @override
  String get titleSyncToAnotherDevice => 'Sync to Another Device';

  @override
  String get descSyncCard => 'Send or receive contacts over Wi-Fi';

  @override
  String get titleOnlineProviderSync => 'Online Provider Sync';

  @override
  String get descOnlineSyncCard =>
      'Direct 2-way sync with Google, Microsoft & CardDAV';

  @override
  String get titleBackupRestore => 'Backup & Restore';

  @override
  String get descBackupCard => 'Save all your data to a file, or restore it';

  @override
  String get titleEncryptedCloudBackup => 'Encrypted Cloud Backup';

  @override
  String get descCloudBackupCard =>
      'Save .csbak backup to Google Drive, OneDrive or WebDAV';

  @override
  String get titleSimCalling => 'SIM & calling';

  @override
  String get descSimCard =>
      'Default SIM, caller identification and spam filtering';

  @override
  String get descRingtoneCard => 'Volume, vibration and per-SIM ringtones';

  @override
  String get titleEmergencyInfo => 'Emergency info';

  @override
  String get descEmergencyCard =>
      'A card a helper can read on your lock screen';

  @override
  String get titleDefaultCountry => 'Default country';

  @override
  String descCountrySubtitle(String country) {
    return '$country · used to identify callers';
  }

  @override
  String get titleAppearance => 'Appearance';

  @override
  String get descAppearanceCard => 'Theme mode and accent color';

  @override
  String get titleFeatures => 'Features';

  @override
  String get descFeaturesCard =>
      'Explore all features of SreerajP Contacts Sphere';

  @override
  String get titlePermissions => 'Permissions';

  @override
  String get descPermissionsCard => 'What the app can access and why';

  @override
  String get titleHelp => 'Help';

  @override
  String get descHelpCard => 'How features like sync work';

  @override
  String get titleAbout => 'About';

  @override
  String get descAboutCard => 'Version, author and build details';

  @override
  String get descAuthReasonSync => 'Authenticate to sync your data';

  @override
  String get errorAuthRequiredSync =>
      'Authentication required to sync your data';

  @override
  String get titleNoScreenLock => 'No screen lock';

  @override
  String get descNoLockSync =>
      'Your device has no screen lock, so synced data can\'t be protected by authentication. This may include secret contacts. Continue anyway?';

  @override
  String get descAuthReasonBackup =>
      'Authenticate to back up or restore your data';

  @override
  String get errorAuthRequiredBackup =>
      'Authentication required to back up or restore';

  @override
  String get descNoLockBackup =>
      'Your device has no screen lock, so a backup can\'t be protected by authentication. A backup may include secret contacts. Continue anyway?';

  @override
  String get titleDialerTopContacts => 'Dialer top contacts';

  @override
  String get labelMostRecent => 'Most recent';

  @override
  String get descTopRelations => 'Contacts you’ve linked as relations';

  @override
  String get descTopLikely =>
      'Ordered by who usually answers at this time of day';

  @override
  String get descTopRecent => 'Most contacted, then most recent calls';

  @override
  String get titleDialpadScriptLayout => 'Dialpad script layout';

  @override
  String get labelScriptAuto => 'Auto (Device locale)';

  @override
  String get labelScriptMalayalam => 'Malayalam (മലയാളം)';

  @override
  String get labelScriptDevanagari => 'Devanagari (Sanskrit / Hindi)';

  @override
  String get labelScriptCyrillic => 'Cyrillic (Russian / Ukrainian)';

  @override
  String get labelScriptArabic => 'Arabic (العربية)';

  @override
  String get labelScriptGreek => 'Greek (Ελληνικά)';

  @override
  String get labelScriptNone => 'English only';

  @override
  String get descScriptAuto => 'Follows your device language / locale';

  @override
  String get descScriptMalayalam =>
      'Dual English + Malayalam script layout (ക-ങ)';

  @override
  String get descScriptDevanagari =>
      'Dual English + Devanagari script layout (क-ङ)';

  @override
  String get descScriptCyrillic =>
      'Dual English + Cyrillic script layout (АБВГ)';

  @override
  String get descScriptArabic =>
      'Dual English + Arabic script layout (ا ب ت ث)';

  @override
  String get descScriptGreek => 'Dual English + Greek script layout (ΑΒΓ)';

  @override
  String get descScriptNone => 'Standard English letters only (A-Z)';

  @override
  String get titleSync => 'Sync';

  @override
  String get labelSaveContactsTo => 'Save contacts to';

  @override
  String get labelCallLog => 'Call log';

  @override
  String get errorSyncFailed => 'Sync failed';

  @override
  String get labelWorking => 'Working…';

  @override
  String get errorContactsPermissionSync =>
      'Contacts permission is needed to sync';

  @override
  String get actionAddDeviceToApp => 'Add device contacts to app';

  @override
  String get descAddDeviceToApp =>
      'Pull the phone\'s address book into the app';

  @override
  String msgContactsSynced(int count) {
    return 'Contacts synced — $count added or updated';
  }

  @override
  String get msgContactsUpToDate => 'Contacts are already up to date';

  @override
  String get actionAddAppToDevice => 'Add app contacts to device';

  @override
  String get descAddAppToDevice =>
      'Copy your app contacts into the phone\'s contacts';

  @override
  String errorCouldNotSaveTo(String target, int failed) {
    return 'Could not save to $target — $failed failed';
  }

  @override
  String get msgNoContactsToSyncToDevice => 'No contacts to sync to the device';

  @override
  String msgSavedTo(String target, int total) {
    return 'Saved to $target — $total added or updated';
  }

  @override
  String msgSavedToWithFailed(String target, int total, int failed) {
    return 'Saved to $target — $total added or updated ($failed failed)';
  }

  @override
  String get actionMirrorDeviceToApp =>
      'Add device contacts to app (destructive)';

  @override
  String get descMirrorDeviceToApp =>
      'Make the app match the phone — removes app contacts that are gone from the phone';

  @override
  String get titleMirrorDeviceToApp => 'Mirror device to app?';

  @override
  String get descMirrorDeviceToAppConfirm =>
      'This imports the phone\'s contacts, then deletes app contacts that came from the phone but are no longer on it.\n\nYour \"Me\" contact, secret contacts, and contacts you created only in the app are never deleted.';

  @override
  String get actionMirror => 'Mirror';

  @override
  String msgMirroredFromDevice(int removed) {
    return 'Mirrored from device — $removed removed';
  }

  @override
  String get msgMirroredFromDeviceNone =>
      'Mirrored from device — nothing to remove';

  @override
  String get actionMirrorAppToDevice =>
      'Add app contacts to device (destructive)';

  @override
  String get descMirrorAppToDevice =>
      'Make the phone match the app — removes device contacts that are not in the app';

  @override
  String get titleMirrorAppToDevice => 'Mirror app to device?';

  @override
  String get descMirrorAppToDeviceConfirm =>
      'This copies your app contacts to the phone, then deletes device contacts that are not in the app.\n\nDevice contacts that match your \"Me\" contact or a secret contact are never deleted.';

  @override
  String msgMirroredTo(String target, int removed) {
    return 'Mirrored to $target — $removed removed';
  }

  @override
  String msgMirroredToNone(String target) {
    return 'Mirrored to $target — nothing to remove';
  }

  @override
  String get actionImportCallLog => 'Add device call log to app';

  @override
  String get descImportCallLog =>
      'Import the phone\'s older call history into Recents';

  @override
  String get errorCouldNotReadCallLog =>
      'Couldn\'t read the phone\'s call log — allow the Call logs permission in Android settings';

  @override
  String get msgCallLogUpToDate => 'Call log is already up to date';

  @override
  String labelCountAdded(int count) {
    return '$count added';
  }

  @override
  String labelCountUpdated(int count) {
    return '$count updated';
  }

  @override
  String msgCallLogImported(String parts) {
    return 'Call log imported — $parts';
  }

  @override
  String get actionReplaceCallLog => 'Add device call log to app (destructive)';

  @override
  String get descReplaceCallLog =>
      'Replace Recents with the phone\'s call history';

  @override
  String get titleReplaceCallHistory => 'Replace call history?';

  @override
  String get descReplaceCallHistoryConfirm =>
      'This clears the app\'s call history and rebuilds it from the phone\'s call log. Call notes and feedback saved in the app will be lost.';

  @override
  String get actionReplace => 'Replace';

  @override
  String msgCallLogReplaced(int count) {
    return 'Call log replaced — $count added';
  }

  @override
  String get labelContactCountsIndex => 'Contact counts & search index';

  @override
  String get descContactCountsIndex =>
      'View device/app contact counts and search index status';

  @override
  String get labelMyProfileAddMe => 'My Profile (\"Add Me\")';

  @override
  String get descMyProfileAddMe => 'Create or edit your own Self contact card';

  @override
  String get labelDisplayFormatting => 'Display & formatting';

  @override
  String get descDisplayFormatting =>
      'Sort order, name format, and display filters';

  @override
  String get labelDeviceCloudSync => 'Device & cloud sync';

  @override
  String get descDeviceCloudSync =>
      'Configure device mirroring and cloud accounts';

  @override
  String get labelCustomRelationshipLabels => 'Custom relationship labels';

  @override
  String get descCustomRelationshipLabels =>
      'Manage custom relationship labels for contacts';

  @override
  String get descBlockedNumbersCard =>
      'View and manage numbers blocked from ringing';

  @override
  String get labelSecretContactsExport => 'Secret contacts & export';

  @override
  String get descSecretContactsExport =>
      'Export options and secret contact export controls';

  @override
  String msgSyncedWith(String name) {
    return 'Synced successfully with $name';
  }

  @override
  String get msgSyncCompleted => 'Sync completed';

  @override
  String get titleAddOnlineAccount => 'Add Online Account';

  @override
  String get labelProvider => 'Provider';

  @override
  String get labelAccountEmailName => 'Account Email / Name';

  @override
  String get labelServerUrl => 'Server URL';

  @override
  String get labelUsername => 'Username';

  @override
  String get labelAccount => 'Account';

  @override
  String get descOnlineSyncIntro =>
      'Opt-in 2-way contact sync with Google, Microsoft & CardDAV. Zero telemetry, direct API requests only.';

  @override
  String get labelConfiguredProviders => 'Configured Providers';

  @override
  String get actionAddAccount => 'Add Account';

  @override
  String get emptyNoCloudAccounts => 'No cloud sync accounts configured.';

  @override
  String descProviderLastSynced(String provider, String when) {
    return 'Provider: $provider\nLast Synced: $when';
  }

  @override
  String get labelNever => 'Never';

  @override
  String get tooltipSyncNow => 'Sync Now';

  @override
  String get labelSimCardsAccounts => 'SIM Cards & Accounts';

  @override
  String get descSimCardsAccounts =>
      'Default SIM, ask per call, and SIM colours';

  @override
  String get labelIdentification => 'Identification';

  @override
  String get descIdentification => 'Caller identification and spam filtering';

  @override
  String get labelSpokenAnnouncement => 'Spoken caller announcement';

  @override
  String get descSpokenAnnouncement => 'Announce caller\'s name over ringtone';

  @override
  String get labelTierQuietHours => 'Relationship-tier quiet hours';

  @override
  String get descTierQuietHours =>
      'Silence calls at night except for chosen relationship tiers';

  @override
  String get labelQuickReplies => 'Quick replies';

  @override
  String get descQuickReplies =>
      'Messages offered when rejecting a call with a text';

  @override
  String get labelPostCallOptions => 'Post-call options';

  @override
  String get descPostCallOptions => 'Configure the post-call feedback sheet';

  @override
  String get titleSmartRedialReachMe => 'Smart Redial & \"Reach Me\"';

  @override
  String get descSmartRedialCard =>
      'Auto-retry and reach-me SMS when calls are unanswered';

  @override
  String get descSmartRedialIntro =>
      'Offer 1-tap auto-retry and reach-me SMS when a call is unanswered';

  @override
  String get labelDefaultRetryDelay => 'Default retry delay';

  @override
  String get labelPresetReachMe => 'Preset Reach Me message';

  @override
  String get labelActiveScheduledRedials => 'Active scheduled redials';

  @override
  String labelActiveCount(int count) {
    return '$count active';
  }

  @override
  String labelMinutesLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get hintPresetReachMe => 'Enter your preset reach-me message...';

  @override
  String get titleActiveAutoRedials => 'Active Auto-Redials';

  @override
  String get emptyNoActiveRedials => 'No active scheduled redials.';

  @override
  String labelRedialIn(String number, int minutes) {
    return '$number · in $minutes min';
  }

  @override
  String get errorEnterPassphrase => 'Please enter a backup passphrase';

  @override
  String msgBackupUploadedFile(String file) {
    return 'Encrypted backup uploaded successfully: $file';
  }

  @override
  String get msgBackupUploaded => 'Backup uploaded';

  @override
  String errorUploadFailed(String error) {
    return 'Upload failed: $error';
  }

  @override
  String get descCloudBackupIntro =>
      'Backs up the full app payload (.csbak) encrypted end-to-end with your passphrase via PBKDF2 (300k iters) + AES-GCM-256 to your cloud storage.';

  @override
  String get emptyNoCloudStorage => 'No cloud storage accounts configured.';

  @override
  String get actionAddAccountInProviderSync => 'Add Account in Provider Sync';

  @override
  String get labelTargetCloudAccount => 'Target Cloud Account';

  @override
  String get labelEncryptionPassphrase => 'Encryption Passphrase';

  @override
  String get hintPassphrase => 'Enter passphrase for .csbak encryption';

  @override
  String get actionUploadBackupNow => 'Upload Encrypted Backup Now';

  @override
  String get labelRemoteCloudBackups => 'Remote Cloud Backups';

  @override
  String get emptyNoCloudBackups => 'No cloud backups found for this account.';

  @override
  String descBackupSizeDate(int bytes, String date) {
    return 'Size: $bytes bytes | Date: $date';
  }

  @override
  String get labelCallerIdentification => 'Caller identification';

  @override
  String get descCallerIdentification =>
      'Label callers who aren’t in your contacts — telemarketing and service numbers, numbers you marked as spam';

  @override
  String get labelFilterSuspectedSpam => 'Filter suspected spam';

  @override
  String get descFilterSpam =>
      'Suspected spam calls ring silently. They still appear in Recents and can be answered';

  @override
  String get labelHowIdentificationWorks => 'How identification works';

  @override
  String get descHowIdentificationWorks =>
      'Identification happens on your phone — nothing is sent anywhere. SreerajP Contacts Sphere recognises registered telemarketing (140…) and service (160…) number series, numbers you have marked as spam from Recents, and shows a warning when your network reports that a caller’s number could not be verified.\n\nMobile networks only deliver the caller’s number, not a name, so callers outside your contacts can’t be identified by name. Spam filtering needs SreerajP Contacts Sphere to be your default phone app.';

  @override
  String get titleAccentColor => 'Accent Color';

  @override
  String get labelLivePreview => 'LIVE PREVIEW';

  @override
  String get labelSampleText => 'Sample text';

  @override
  String get labelPresets => 'PRESETS';

  @override
  String get labelCustomColorWheel => 'CUSTOM COLOR WHEEL';

  @override
  String get actionResetDarkToDefault => 'Reset Dark to default';

  @override
  String get actionResetLightToDefault => 'Reset Light to default';

  @override
  String get descContrastAuto =>
      'Text contrast is adjusted automatically for readability.';

  @override
  String get labelSortOrder => 'Sort order';

  @override
  String get descSortOrder => 'How contacts are ordered in lists';

  @override
  String get labelFirstName => 'First name';

  @override
  String get labelHideNoPhone => 'Hide contacts without phone numbers';

  @override
  String get descHideNoPhone =>
      'Contacts with only emails or addresses won\'t show in the main list';

  @override
  String get titleThemeMode => 'Theme Mode';

  @override
  String get labelLight => 'Light';

  @override
  String get labelDark => 'Dark';

  @override
  String get labelSystem => 'System';

  @override
  String get descSystemTheme =>
      'System mode automatically follows your device\'s system-wide dark mode setting.';

  @override
  String get labelVolumeVibration => 'Volume & vibration';

  @override
  String get descVolumeVibration =>
      'Ringtone volume and incoming call vibration';

  @override
  String get labelPerSimRingtones => 'Per-SIM ringtones';

  @override
  String get descPerSimRingtones =>
      'Assign distinct ringtones for calls received on each SIM';

  @override
  String get titleTypography => 'Typography & Text Size';

  @override
  String get labelFont => 'FONT';

  @override
  String get labelTextSize => 'TEXT SIZE';

  @override
  String get labelScaleSmall => 'Small';

  @override
  String get labelScaleDefault => 'Default';

  @override
  String get labelScaleLarge => 'Large';

  @override
  String get labelScaleLarger => 'Larger';

  @override
  String get titleScreenshotGuard => 'Screenshot Guard';

  @override
  String get labelBlockScreenshots => 'Block screenshots';

  @override
  String get descBlockScreenshots =>
      'Keeps contact details and calls out of screenshots, screen recordings and the Recents preview';

  @override
  String get featureC0Name => 'Smart Dialer & Calling';

  @override
  String get featureC0Subtitle =>
      'Fast T9 search, dual-SIM controls, and intelligent calling tools';

  @override
  String get featureC0F0Title => 'Multi-Script T9 Keypad Search';

  @override
  String get featureC0F0Desc =>
      'Search contacts in milliseconds by typing numbers or letters on the dialpad. Fully supports English, Malayalam (including vowels & chillu letters), Devanagari, and more.';

  @override
  String get featureC0F0H0 => 'English & Malayalam';

  @override
  String get featureC0F0H1 => 'Multi-script transliteration';

  @override
  String get featureC0F0H2 => 'Matches names either way';

  @override
  String get featureC0F1Title => 'Speed Dial';

  @override
  String get featureC0F1Desc =>
      'Save a person on keypad keys 1 to 9, then hold that key to call them. Holding works when the number box is empty; assigned keys carry a small dot. Secret contacts can never be put on a key.';

  @override
  String get featureC0F1H0 => 'Keys 1-9';

  @override
  String get featureC0F1H1 => 'Hold a key to call';

  @override
  String get featureC0F1H2 => 'Assign from the keypad or Settings';

  @override
  String get featureC0F2Title => 'Voice Dial';

  @override
  String get featureC0F2Desc =>
      'Tap the microphone on the dialpad and say a number or a name. Speech is turned into text on your phone, in English or Malayalam, and lead-in words like \"call\" are dropped automatically.';

  @override
  String get featureC0F2H0 => 'Speak a number or a name';

  @override
  String get featureC0F2H1 => 'English & Malayalam';

  @override
  String get featureC0F2H2 => 'On-device speech';

  @override
  String get featureC0F3Title => 'Editable Dialer & Precision Editing';

  @override
  String get featureC0F3Desc =>
      'Freely tap anywhere on the typed number to move your cursor, select digits, copy, or paste phone numbers with ease.';

  @override
  String get featureC0F3H0 => 'Cursor positioning';

  @override
  String get featureC0F3H1 => 'Paste numbers';

  @override
  String get featureC0F3H2 => 'Backspace at the cursor';

  @override
  String get featureC0F4Title => 'Top Contacts Quick Access';

  @override
  String get featureC0F4Desc =>
      'A row right above the dialpad for one-tap calling. Choose what fills it: your most contacted people, the family and friends you have linked, or whoever usually answers at this time of day.';

  @override
  String get featureC0F4H0 => 'Favorites row';

  @override
  String get featureC0F4H1 => 'Family & friends filter';

  @override
  String get featureC0F4H2 => 'Likely to answer now';

  @override
  String get featureC0F5Title => 'Dual-SIM Calling Controls';

  @override
  String get featureC0F5Desc =>
      'Choose between SIM 1 and SIM 2 for each call, or set a default SIM so you are not asked every time. A contact can also keep its own preferred SIM, which is used ahead of the default. Each SIM gets its own colour, and Recents shows which one a call used.';

  @override
  String get featureC0F5H0 => 'SIM 1 / SIM 2 picker';

  @override
  String get featureC0F5H1 => 'Default SIM or ask each time';

  @override
  String get featureC0F5H2 => 'Per-contact preferred SIM';

  @override
  String get featureC0F5H3 => 'SIM shown in Recents';

  @override
  String get featureC0F6Title => 'Smart Redial & \"Reach Me\" Mode';

  @override
  String get featureC0F6Desc =>
      'When a call goes unanswered or busy, schedule a redial after a delay you choose, or send a preset \"trying to reach you\" text in one tap.';

  @override
  String get featureC0F6H0 => 'Redial after your delay';

  @override
  String get featureC0F6H1 => '1-tap SMS prompt';

  @override
  String get featureC0F6H2 => 'Cancel a waiting redial';

  @override
  String get featureC0F7Title => 'Spoken Caller Announcements';

  @override
  String get featureC0F7Desc =>
      'Hear a saved caller\'s name spoken out loud when your phone rings, perfect when driving or wearing headphones. A Malayalam name is announced in Malayalam.';

  @override
  String get featureC0F7H0 => 'Voice caller ID';

  @override
  String get featureC0F7H1 => 'Malayalam announcements';

  @override
  String get featureC0F7H2 => 'Quiet-hours exception';

  @override
  String get featureC0F8Title => 'Quick Reject SMS Replies';

  @override
  String get featureC0F8Desc =>
      'Decline incoming calls politely with preset one-tap SMS messages like \"In a meeting, will call back soon.\"';

  @override
  String get featureC0F8H0 => '1-tap decline SMS';

  @override
  String get featureC0F8H1 => 'Custom quick templates';

  @override
  String get featureC0F8H2 => 'Instant dispatch';

  @override
  String get featureC1Name => 'In-Call & Caller Intelligence';

  @override
  String get featureC1Subtitle =>
      'Know who is calling with rich context and seamless call controls';

  @override
  String get featureC1F0Title => 'Modern In-Call Screen & Conference Calling';

  @override
  String get featureC1F0Desc =>
      'A beautiful call screen with mute, loud speaker, call hold, numeric keypad, active call swapping, and merging multi-party conference calls.';

  @override
  String get featureC1F0H0 => 'Speaker & mute';

  @override
  String get featureC1F0H1 => 'Call hold & swap';

  @override
  String get featureC1F0H2 => 'Conference merge';

  @override
  String get featureC1F0H3 => 'Full-screen incoming alert';

  @override
  String get featureC1F1Title => 'Relationship Context Cards';

  @override
  String get featureC1F1Desc =>
      'See the caller\'s relationship badge, how long since you last spoke, personal notes, and upcoming birthdays right as the phone rings.';

  @override
  String get featureC1F1H0 => 'Relationship badge';

  @override
  String get featureC1F1H1 => 'Last spoken days';

  @override
  String get featureC1F1H2 => 'Instant notes preview';

  @override
  String get featureC1F2Title => 'Pre-Call Summary';

  @override
  String get featureC1F2Desc =>
      'Before you ring someone, see when you last spoke, how long that call lasted, what you noted, and the local time in their city if you saved an address.';

  @override
  String get featureC1F2H0 => 'Catch-up reminders';

  @override
  String get featureC1F2H1 => 'Their local time';

  @override
  String get featureC1F2H2 => 'Interaction timeline';

  @override
  String get featureC1F3Title => 'Post-Call Notes & Voice Transcribing';

  @override
  String get featureC1F3Desc =>
      'Quickly jot down what you discussed right after hanging up using your keyboard or speaking aloud with automatic voice-to-text.';

  @override
  String get featureC1F3H0 => 'Voice-to-text input';

  @override
  String get featureC1F3H1 => 'Post-call prompt';

  @override
  String get featureC1F3H2 => 'Follow-up reminder';

  @override
  String get featureC2Name => 'Contact Management & Relations';

  @override
  String get featureC2Subtitle =>
      'Organize your network into meaningful spheres and circles';

  @override
  String get featureC2F0Title => 'Rich Contact Profiles';

  @override
  String get featureC2F0Desc =>
      'Store multiple phone numbers, emails, home/work addresses, birthdays, anniversaries, social links, official details, and phonetic names.';

  @override
  String get featureC2F0H0 => 'Multi-phone & email';

  @override
  String get featureC2F0H1 => 'Birthday reminders';

  @override
  String get featureC2F0H2 => 'Custom labels';

  @override
  String get featureC2F1Title => '7 Relationship Spheres';

  @override
  String get featureC2F1Desc =>
      'Every link you save sits in one of seven categories: Immediate Family, Extended Family, Family by Marriage, Professional, Educational, Social, and Service. The label inside it — \"Father\", \"Manager\" — is whatever you type.';

  @override
  String get featureC2F1H0 => 'Seven fixed categories';

  @override
  String get featureC2F1H1 => 'Your own kinship labels';

  @override
  String get featureC2F1H2 => 'Saved on both contacts';

  @override
  String get featureC2F2Title => 'Relationship Quiet Hours (DND Filter)';

  @override
  String get featureC2F2Desc =>
      'Silence calls between the times you set, and list who should still get through — starred contacts, whole relationship categories, a tag, or named individuals. Everyone else stays quiet.';

  @override
  String get featureC2F2H0 => 'Set your quiet window';

  @override
  String get featureC2F2H1 => 'Allow list, not a block list';

  @override
  String get featureC2F2H2 => 'By category, tag or person';

  @override
  String get featureC2F3Title => 'Tags & Custom Groups';

  @override
  String get featureC2F3Desc =>
      'Tag contacts with short words of your own, and build groups (like \"Project Team\" or \"Book Club\") that can carry their own ringtone.';

  @override
  String get featureC2F3H0 => 'Tag cloud explorer';

  @override
  String get featureC2F3H1 => 'Custom groups';

  @override
  String get featureC2F3H2 => 'Group ringtones';

  @override
  String get featureC2F4Title => 'Duplicate Contact Finder & Smart Merge';

  @override
  String get featureC2F4Desc =>
      'Find duplicates by phone number and by name — including names written in another script — then merge them cleanly without losing any detail.';

  @override
  String get featureC2F4H0 => 'Name & number matching';

  @override
  String get featureC2F4H1 => 'Safe data merge';

  @override
  String get featureC2F4H2 => 'Review before merging';

  @override
  String get featureC2F5Title => 'Temporary (Ephemeral) Contacts';

  @override
  String get featureC2F5Desc =>
      'Save a delivery driver or a one-off seller as a temporary contact and it deletes itself — after 2 hours, 24 hours, 7 days, or a single call.';

  @override
  String get featureC2F5H0 => 'Self-deleting entry';

  @override
  String get featureC2F5H1 => 'Countdown banner';

  @override
  String get featureC2F5H2 => 'Keep it permanently';

  @override
  String get featureC2F6Title => 'Connected Messaging Apps';

  @override
  String get featureC2F6Desc =>
      'A contact shows the messengers they can be reached on — WhatsApp, Telegram, Arattai and others — read from your phone\'s own address book. Tap one to open the chat there.';

  @override
  String get featureC2F6H0 => 'Open chat directly';

  @override
  String get featureC2F6H1 => 'Read from your phone';

  @override
  String get featureC2F6H2 => 'No account needed';

  @override
  String get featureC3Name => 'Privacy, Security & Vault';

  @override
  String get featureC3Subtitle =>
      'Protect your sensitive contacts and private conversations';

  @override
  String get featureC3F0Title => 'Secret Contacts Vault';

  @override
  String get featureC3F0Desc =>
      'Hide sensitive personal or business contacts in a protected vault. They are completely invisible in the main list until unlocked.';

  @override
  String get featureC3F0H0 => 'Biometric / PIN unlock';

  @override
  String get featureC3F0H1 => 'Hidden from main list';

  @override
  String get featureC3F0H2 => 'Encrypted database';

  @override
  String get featureC3F1Title => 'App Lock: Off, Device Lock or App PIN';

  @override
  String get featureC3F1Desc =>
      'Lock the whole app behind your phone\'s fingerprint and face, or behind a separate 4–6 digit App PIN with a one-time recovery code. Secret contacts, backups and sync ask again on top of it.';

  @override
  String get featureC3F1H0 => 'Fingerprint & Face unlock';

  @override
  String get featureC3F1H1 => 'Separate App PIN';

  @override
  String get featureC3F1H2 => 'One-time recovery code';

  @override
  String get featureC3F2Title => 'Screenshot Guard';

  @override
  String get featureC3F2Desc =>
      'Blocks screenshots, screen recording, and the Recents preview while you are on a screen holding private data — contact details, a call in progress, the lock screen, secret contacts, and the audit log.';

  @override
  String get featureC3F2H0 => 'Screenshot blocking';

  @override
  String get featureC3F2H1 => 'Screen recording defense';

  @override
  String get featureC3F2H2 => 'Recents preview hidden';

  @override
  String get featureC3F3Title => 'Contact Change Audit Log';

  @override
  String get featureC3F3Desc =>
      'A private, tamper-evident history of every contact created, edited or deleted, with what it looked like before and after — so an accidental change can be undone.';

  @override
  String get featureC3F3H0 => 'Before & after snapshots';

  @override
  String get featureC3F3H1 => 'Undo a change';

  @override
  String get featureC3F3H2 => 'Signed export';

  @override
  String get featureC4Name => 'Instant Contact Sharing & Scanning';

  @override
  String get featureC4Subtitle =>
      'Exchange contact cards quickly without typing';

  @override
  String get featureC4F0Title => 'vCard QR Code Generator & Scanner';

  @override
  String get featureC4F0Desc =>
      'Create a QR code of your contact card for others to scan in seconds, or use the camera to scan and save anyone\'s QR contact card.';

  @override
  String get featureC4F0H0 => 'Instant QR vCard';

  @override
  String get featureC4F0H1 => 'Built-in camera scanner';

  @override
  String get featureC4F0H2 => '1-tap address book import';

  @override
  String get featureC4F1Title => 'AirQR Animated Code Streaming';

  @override
  String get featureC4F1Desc =>
      'A photo or a long contact card will not fit in one QR code. AirQR splits it across many frames and plays them as an animation for the other phone\'s camera to read — no Bluetooth, no network, no pairing.';

  @override
  String get featureC4F1H0 => 'Sends photos & full cards';

  @override
  String get featureC4F1H1 => 'Camera-only transfer';

  @override
  String get featureC4F1H2 => 'Live progress while it streams';

  @override
  String get featureC4F2Title => 'On-Device Business Card Scanner';

  @override
  String get featureC4F2Desc =>
      'Snap a photo of any physical business card to extract name, phone, email, and company details instantly—all processed 100% on your phone without cloud upload.';

  @override
  String get featureC4F2H0 => 'On-device AI OCR';

  @override
  String get featureC4F2H1 => 'Zero cloud upload';

  @override
  String get featureC4F2H2 => 'Selectable field import';

  @override
  String get featureC4F3Title => 'Offline Bluetooth LE Share';

  @override
  String get featureC4F3Desc =>
      'Discover nearby ContactSphere devices and send contacts directly over Bluetooth Low Energy without needing internet or pairing codes.';

  @override
  String get featureC4F3H0 => 'Zero internet required';

  @override
  String get featureC4F3H1 => 'Auto device discovery';

  @override
  String get featureC4F3H2 => 'Receiver must confirm';

  @override
  String get featureC4F4Title => 'CSV & vCard Import / Export';

  @override
  String get featureC4F4Desc =>
      'Bring contacts in from a CSV or vCard (.vcf) file, or write your address book out as one, then choose where it goes through the system share sheet.';

  @override
  String get featureC4F4H0 => 'CSV in and out';

  @override
  String get featureC4F4H1 => 'vCard (.vcf) in and out';

  @override
  String get featureC4F4H2 => 'Secret contacts left out';

  @override
  String get featureC5Name => 'Data Sync & Backup';

  @override
  String get featureC5Subtitle =>
      'Keep your contacts safe, synchronized, and recoverable anywhere';

  @override
  String get featureC5F0Title => 'Device Contacts & Call Log Sync';

  @override
  String get featureC5F0Desc =>
      'Copy contacts between the app and your phone\'s address book in whichever direction you choose — you run each one yourself. The phone\'s call log flows into Recents on its own.';

  @override
  String get featureC5F0H0 => 'Either direction, on demand';

  @override
  String get featureC5F0H1 => 'Adds and updates, never deletes';

  @override
  String get featureC5F0H2 => 'Call log arrives automatically';

  @override
  String get featureC5F1Title => 'Local Wi-Fi Device-to-Device Sync';

  @override
  String get featureC5F1Desc =>
      'Transfer contacts between two phones on the same Wi-Fi network, encrypted with a pairing code that never leaves the screen. Nothing is uploaded, and nothing on the receiving phone is deleted.';

  @override
  String get featureC5F1H0 => 'Direct phone to phone';

  @override
  String get featureC5F1H1 => 'Encrypted with a QR pairing code';

  @override
  String get featureC5F1H2 => 'No cloud needed';

  @override
  String get featureC5F2Title =>
      'Online Provider Sync & Encrypted Cloud Backup';

  @override
  String get featureC5F2Desc =>
      'Optionally sync contacts with Google, Microsoft or a CardDAV server, and upload a password-encrypted backup file to Google Drive, OneDrive or your own WebDAV storage.';

  @override
  String get featureC5F2H0 => 'Google, Microsoft & WebDAV';

  @override
  String get featureC5F2H1 => 'Password-encrypted file';

  @override
  String get featureC5F2H2 => 'Secret contacts never uploaded';

  @override
  String get featureC5F3Title => 'Offline Backup & Restore Files';

  @override
  String get featureC5F3Desc =>
      'Save everything — contacts, call history, photos, settings and the emergency card — into one password-locked file, and restore it on any phone. The password is the only key; the app never stores it.';

  @override
  String get featureC5F3H0 => 'Export to file';

  @override
  String get featureC5F3H1 => 'Safe encrypted format';

  @override
  String get featureC5F3H2 => 'Restore replaces everything';

  @override
  String get featureC6Name => 'Call Defense & Spam Blocking';

  @override
  String get featureC6Subtitle =>
      'Shield yourself from spam calls and unwanted numbers';

  @override
  String get featureC6F0Title => 'Automatic Call Screening';

  @override
  String get featureC6F0Desc =>
      'A built-in screening service inspects every incoming number before your phone rings and turns away anything on your blocked list — checked entirely on this phone, against your own list.';

  @override
  String get featureC6F0H0 => 'Rejected before it rings';

  @override
  String get featureC6F0H1 => 'Nothing looked up online';

  @override
  String get featureC6F0H2 => 'Default dialer integration';

  @override
  String get featureC6F1Title => 'Blocked Numbers Manager';

  @override
  String get featureC6F1Desc =>
      'Block a number with a long-press in Recents, from the Block control during a call, or by typing it in yourself. Blocking during a live call hangs it up at once, and blocked calls still appear in Recents so you can see who tried.';

  @override
  String get featureC6F1H0 => 'Block from Recents or in-call';

  @override
  String get featureC6F1H1 => 'Blocklist manager';

  @override
  String get featureC6F1H2 => 'Unblock anytime';

  @override
  String get featureC6F2Title => 'Block Unknown Callers';

  @override
  String get featureC6F2Desc =>
      'Turn away calls that arrive with no number or a withheld one. They are rejected before ringing and still written into Recents as blocked.';

  @override
  String get featureC6F2H0 => 'Hidden numbers rejected';

  @override
  String get featureC6F2H1 => 'Still logged in Recents';

  @override
  String get featureC6F2H2 => 'One switch to turn on';

  @override
  String get featureC6F3Title => 'Caller Identification & Spam Filter';

  @override
  String get featureC6F3Desc =>
      'Label callers who are not in your contacts using what can be worked out locally — telemarketing and service number series, numbers you marked as spam, and the network\'s verified-caller flag. Flagged callers can ring silently instead of loudly.';

  @override
  String get featureC6F3H0 => 'Labels unknown callers';

  @override
  String get featureC6F3H1 => 'Ring spam silently';

  @override
  String get featureC6F3H2 => 'Mark a number as spam';

  @override
  String get featureC7Name => 'Personalization & Accessibility';

  @override
  String get featureC7Subtitle =>
      'Customize the appearance, audio, and regional settings to your taste';

  @override
  String get featureC7F0Title => 'Theme, Accent Color & Typography';

  @override
  String get featureC7F0Desc =>
      'Switch between Light, Dark, or System mode, choose an accent colour, and set the font and text size. Three bundled fonts cover both Malayalam and English.';

  @override
  String get featureC7F0H0 => 'Dark & Light mode';

  @override
  String get featureC7F0H1 => 'Curated color palettes';

  @override
  String get featureC7F0H2 => 'Font & text size';

  @override
  String get featureC7F1Title => 'Per-SIM, Group & Contact Ringtones';

  @override
  String get featureC7F1Desc =>
      'Assign distinctive ringtones to SIM 1 vs SIM 2, to a group, or to a single contact. The most specific one wins: the contact\'s tone, then their group\'s, then the SIM\'s.';

  @override
  String get featureC7F1H0 => 'Distinct ringtone per SIM';

  @override
  String get featureC7F1H1 => 'Group ringtones';

  @override
  String get featureC7F1H2 => 'Per-contact ringtones';

  @override
  String get featureC7F2Title => 'Emergency Info Lock-Screen Card';

  @override
  String get featureC7F2Desc =>
      'Set vital medical info (blood group, allergies, emergency contacts) visible on your lock screen for first responders without unlocking.';

  @override
  String get featureC7F2H0 => 'Lock-screen access';

  @override
  String get featureC7F2H1 => 'Per-field privacy toggle';

  @override
  String get featureC7F2H2 => 'Direct emergency dial';

  @override
  String get featureC7F3Title => 'Default Country Dialing Code';

  @override
  String get featureC7F3Desc =>
      'Tell the app which country your plain, un-prefixed numbers belong to. It is what lets a call from +91 98765 43210 be recognised as the 98765 43210 in your contacts, and it is used to match blocked numbers too.';

  @override
  String get featureC7F3H0 => 'Auto country prefix';

  @override
  String get featureC7F3H1 => 'International format';

  @override
  String get featureC7F3H2 => 'Matches callers to contacts';

  @override
  String get featureC7F4Title => 'Contact Counts & Search Index';

  @override
  String get featureC7F4Desc =>
      'See how many contacts sit on the phone and in the app, and check the health of the search index that makes T9 and name search fast. Rebuild it in seconds if a contact stops turning up.';

  @override
  String get featureC7F4H0 => 'Device vs app counts';

  @override
  String get featureC7F4H1 => 'Index health check';

  @override
  String get featureC7F4H2 => 'One-tap rebuild';

  @override
  String get featureC7F5Title => 'In-App Help & Guides';

  @override
  String get featureC7F5Desc =>
      'Over twenty plain-English guides covering every feature here — calling, blocking, sync, backups, privacy, sharing and more — plus a FAQ and troubleshooting page. All offline, inside the app.';

  @override
  String get featureC7F5H0 => 'Guide for every feature';

  @override
  String get featureC7F5H1 => 'FAQ & troubleshooting';

  @override
  String get featureC7F5H2 => 'Works offline';

  @override
  String get titleFeaturesHeader => 'SreerajP Contacts Sphere Features';

  @override
  String get descFeaturesHeader =>
      'Explore every intelligent tool, privacy safeguard, and calling feature designed for you.';

  @override
  String get msgSavedCardOff => 'Saved. The lock screen card is off.';

  @override
  String get msgSavedNothingOn => 'Saved. Nothing is switched on to show yet.';

  @override
  String get msgSavedCardOn => 'Saved. The card is on your lock screen.';

  @override
  String errorCouldNotSave(String error) {
    return 'Could not save: $error';
  }

  @override
  String get titleLeaveWithoutSaving => 'Leave without saving?';

  @override
  String get descUnsavedEmergency =>
      'Your changes to the emergency card are not saved.';

  @override
  String get actionKeepEditing => 'Keep editing';

  @override
  String get actionDiscard => 'Discard';

  @override
  String get errorNothingToShare =>
      'Nothing on the card is switched on to share.';

  @override
  String get descShareFormatted =>
      'Send formatted details via messaging or email';

  @override
  String get actionShareAsCardImage => 'Share as Card Image';

  @override
  String get descShareCardImage => 'Send visual ICE card image (PNG)';

  @override
  String get tooltipShareIceCard => 'Share ICE Card';

  @override
  String get descEmergencyWarning =>
      'Anything you switch on here can be read by anyone holding your phone, without your PIN. That is the point of an emergency card — so switch on only what a stranger should see.';

  @override
  String get labelShowOnLockScreen => 'Show on lock screen';

  @override
  String get descShowOnLockScreen =>
      'Adds a persistent notification with 1-tap emergency call action. Opens the card over the lock screen with a high-contrast emergency QR code.';

  @override
  String get labelNameOnCard => 'Name shown on the card';

  @override
  String get labelShowTheName => 'Show the name';

  @override
  String get descNotificationsOff =>
      'Notifications for this app are switched off, so the card cannot show anywhere.';

  @override
  String get descNotificationSilent =>
      'This notification is set to silent. The lock screen hides silent notifications on many phones.';

  @override
  String get actionOpenNotificationSettings => 'Open notification settings';

  @override
  String get titleNotSeeingOnLock => 'Not seeing it on the lock screen?';

  @override
  String get descLockScreenTips =>
      'The phone decides which notifications the lock screen shows. Check this system setting:\n\nSettings → Notifications → Notifications on lock screen\n\nPick \"Show conversations, default and silent\". If it is set to \"Hide silent notifications\" or \"Don\'t show any notifications\", the emergency card cannot appear there — no app can override that.';

  @override
  String get labelMedicalDetails => 'Medical details';

  @override
  String get labelAllergies => 'Allergies';

  @override
  String get labelMedicines => 'Medicines';

  @override
  String get labelConditions => 'Conditions';

  @override
  String get labelAddressField => 'Address';

  @override
  String get hintAllergies => 'e.g. Penicillin, peanuts';

  @override
  String get hintMedicines => 'Medicines you take regularly';

  @override
  String get hintConditions => 'e.g. Diabetes, epilepsy';

  @override
  String get hintHomeAddress => 'Home address';

  @override
  String get hintEmergencyNotes => 'Anything else a helper should know';

  @override
  String get labelOrganDonor => 'Organ donor';

  @override
  String get labelShowOrganDonor => 'Show \"Organ donor\"';

  @override
  String get labelPeopleToCall => 'People to call';

  @override
  String get descPeopleToCall =>
      'Each one gets a Call button on the card. The call is placed straight from the lock screen.';

  @override
  String get emptyNoOneAdded => 'No one added yet.';

  @override
  String get actionFromContacts => 'From contacts';

  @override
  String get actionTypeANumber => 'Type a number';

  @override
  String get tooltipShownOnCard => 'Shown on the card';

  @override
  String get tooltipHidden => 'Hidden';

  @override
  String get labelWhatStrangerSees => 'What a stranger will see';

  @override
  String get descCardSwitchedOff => 'Nothing — the card is switched off.';

  @override
  String get descNothingYetFill =>
      'Nothing yet. Fill in a field and switch it on.';

  @override
  String get descTapSaveToApply =>
      'Tap Save to apply changes to the lock screen.';

  @override
  String get titleChoosePersonToCall => 'Choose a person to call';

  @override
  String get titleAddPerson => 'Add a person';

  @override
  String get titleEditPerson => 'Edit person';

  @override
  String get labelNumber => 'Number';

  @override
  String get labelRelationOptional => 'Relation (optional)';

  @override
  String get hintRelationExample => 'e.g. Wife, Doctor';

  @override
  String get errorNameAndNumberNeeded => 'A name and a number are both needed.';

  @override
  String get labelNotSet => 'Not set';

  @override
  String errorFailedLoadGroups(String error) {
    return 'Failed to load groups: $error';
  }

  @override
  String get errorCouldNotCreateGroup =>
      'Could not create group (name may already exist)';

  @override
  String get titleGroupName => 'Group name';

  @override
  String get hintGroupExample => 'e.g. Family';

  @override
  String get actionOk => 'OK';

  @override
  String errorCouldNotSaveRingtone(String error) {
    return 'Could not save ringtone: $error';
  }

  @override
  String errorCouldNotClearRingtone(String error) {
    return 'Could not clear ringtone: $error';
  }

  @override
  String get errorNoContactsToAdd => 'No contacts to add';

  @override
  String titleAddToGroup(String name) {
    return 'Add to \"$name\"';
  }

  @override
  String get msgNoNewContactsAdded => 'No new contacts added';

  @override
  String msgContactsAddedToGroup(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts added to \"$name\"',
      one: '1 contact added to \"$name\"',
    );
    return '$_temp0';
  }

  @override
  String errorCouldNotAddContacts(String error) {
    return 'Could not add contacts: $error';
  }

  @override
  String titleDeleteGroupConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get descDeleteGroup =>
      'The group is removed; contacts in it are not deleted.';

  @override
  String get emptyNoGroups => 'No groups yet';

  @override
  String get actionAddContactsEllipsis => 'Add contacts…';

  @override
  String get actionRingtoneEllipsis => 'Ringtone…';

  @override
  String get actionClearRingtone => 'Clear ringtone';

  @override
  String get emptyNoTags =>
      'No tags yet. Add tags to a contact and they show up here.';

  @override
  String get descTagCloudHint =>
      'Tap a tag to see its contacts. Long-press to rename, merge or delete.';

  @override
  String titleAddToTag(String tag) {
    return 'Add to #$tag';
  }

  @override
  String msgContactsAddedToTag(int count, String tag) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts added to #$tag',
      one: '1 contact added to #$tag',
    );
    return '$_temp0';
  }

  @override
  String titleRemoveTagConfirm(String tag) {
    return 'Remove #$tag?';
  }

  @override
  String descRemoveTagFrom(String name) {
    return 'Removes the tag from $name. The contact itself is not deleted.';
  }

  @override
  String get descRemoveTagFromThis =>
      'Removes the tag from this contact. The contact itself is not deleted.';

  @override
  String msgRemovedTag(String tag) {
    return 'Removed #$tag';
  }

  @override
  String errorCouldNotRemove(String error) {
    return 'Could not remove: $error';
  }

  @override
  String get tooltipRenameMergeDeleteTag => 'Rename, merge or delete tag';

  @override
  String get actionAddContacts => 'Add contacts';

  @override
  String get emptyTagNoContacts =>
      'No contacts have this tag.\n\nAdd some below, or delete the tag from the menu above.';

  @override
  String get tooltipRemoveTagFromContact => 'Remove this tag from the contact';

  @override
  String get labelNoPhone => 'No phone';

  @override
  String errorFailedFindDuplicates(String error) {
    return 'Failed to find duplicates: $error';
  }

  @override
  String get titleMergeThisSet => 'Merge this set?';

  @override
  String descMergeThisSet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Keep the selected contact and merge $count others into it. This cannot be undone.',
      one:
          'Keep the selected contact and merge 1 other into it. This cannot be undone.',
    );
    return '$_temp0';
  }

  @override
  String msgMergedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Merged $count contacts',
      one: 'Merged 1 contact',
    );
    return '$_temp0';
  }

  @override
  String errorMergeFailed(String error) {
    return 'Merge failed: $error';
  }

  @override
  String get errorNothingSelectedToMerge => 'Nothing selected to merge';

  @override
  String get titleMergeAllSets => 'Merge all sets?';

  @override
  String descMergeAllSets(int sets, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: 'Resolve $sets sets',
      one: 'Resolve 1 set',
    );
    String _temp1 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total contacts',
      one: '1 contact',
    );
    return '$_temp0, merging $_temp1 into their kept ones. This cannot be undone.';
  }

  @override
  String get actionMerge => 'Merge';

  @override
  String get labelScanning => 'Scanning…';

  @override
  String labelDuplicateSetsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count duplicate sets found',
      one: '1 duplicate set found',
    );
    return '$_temp0';
  }

  @override
  String get labelNoDuplicates => 'No duplicates';

  @override
  String get descTapToKeep =>
      'Tap a contact to choose which to keep; untick the rest.';

  @override
  String get labelAllCleanedUp => 'All cleaned up';

  @override
  String get descNoMoreDuplicates =>
      'No more duplicate contacts. Your address book is tidy.';

  @override
  String get labelUnnamed => 'Unnamed';

  @override
  String get labelKeep => 'KEEP';

  @override
  String labelKeepingMerging(int count) {
    return 'Keeping 1 · merging $count';
  }

  @override
  String get labelNothingSelected => 'Nothing selected';

  @override
  String get labelToMerge => 'to merge';

  @override
  String get actionMergeAllSets => 'Merge all sets';

  @override
  String msgAuditExported(int count) {
    return 'Signed Audit Log exported successfully ($count entries verified)';
  }

  @override
  String get titleClearAuditLog => 'Clear the audit log?';

  @override
  String get descClearAuditLog =>
      'Your contacts are not touched — only the record of how they changed. Anything not yet undone can no longer be undone.';

  @override
  String get msgAuditCleared => 'Audit log cleared';

  @override
  String get titleAuditLog => 'Audit Log';

  @override
  String get actionExportSignedAuditLog => 'Export Signed Audit Log';

  @override
  String get tooltipHideSecret => 'Hide secret contacts';

  @override
  String get tooltipShowSecret => 'Show secret contacts';

  @override
  String get actionClearLog => 'Clear log';

  @override
  String descAuditIntro(int days) {
    return 'Every contact added, edited or deleted is recorded here with SHA-256 cryptographic hash chaining for $days days. Tap an entry to see changes, or tap 1-Click Export Signed Audit Log to export.';
  }

  @override
  String descChainVerified(int verified, int total) {
    return 'Tamper-Proof Chain Verified ($verified / $total entries linked)';
  }

  @override
  String descChainTampered(String row) {
    return 'Security Warning: Tamper detected at row #$row!';
  }

  @override
  String get labelAuditAdded => 'Added';

  @override
  String get labelAuditEdited => 'Edited';

  @override
  String get labelAuditDeleted => 'Deleted';

  @override
  String get emptyAuditNothing =>
      'Nothing recorded yet. Changes to your contacts will show up here.';

  @override
  String get emptyAuditFilter => 'Nothing recorded under this filter.';

  @override
  String get labelSourceManual => 'In the app';

  @override
  String get labelSourceDeviceSync => 'Phone contacts sync';

  @override
  String get labelSourceMerge => 'Merged duplicates';

  @override
  String get labelSourceRestore => 'Backup restore';

  @override
  String get labelSourceP2pSync => 'Sync from another device';

  @override
  String get labelSourceImport => 'File import';

  @override
  String get labelSourceUndo => 'Undo from the audit log';

  @override
  String get labelSourceUnknown => 'Unknown';

  @override
  String get titleUndoThisChange => 'Undo this change?';

  @override
  String get actionUndo => 'Undo';

  @override
  String get msgContactRemovedAgain => 'Contact removed again';

  @override
  String get msgChangeUndone => 'Change undone';

  @override
  String errorUndoFailed(String error) {
    return 'Undo failed: $error';
  }

  @override
  String get titleChangeDetails => 'Change details';

  @override
  String get descNoVisibleChange =>
      'No field visible in the log is different. The change was recorded because something was written to this contact.';

  @override
  String get labelWhatChanged => 'What changed';

  @override
  String get labelBefore => 'Before';

  @override
  String get labelAfter => 'After';

  @override
  String get descUndone =>
      'This change has been undone. The undo itself is recorded as a new entry.';

  @override
  String get descCannotUndo =>
      'This entry cannot be undone — it has no saved copy of the earlier version.';

  @override
  String get labelUndone => 'Undone';

  @override
  String get actionUndoThisChange => 'Undo this change';

  @override
  String get titleOpenThisContact => 'Open this contact';

  @override
  String get descSeeContactNow => 'See the contact as it is now';

  @override
  String get descUndoCreate => 'Undo will delete this contact again.';

  @override
  String get descUndoUpdate => 'Undo will put the old details back.';

  @override
  String get descUndoDelete =>
      'Undo will create this contact again. It gets a new id, so old call history stays unlinked and only relationships whose other person still exists come back.';

  @override
  String get labelPhoto => 'Photo';

  @override
  String get labelSecret => 'Secret';

  @override
  String get labelFavourite => 'Favourite';

  @override
  String get labelSelf => 'Self';

  @override
  String get labelPhoneContactsLink => 'Phone contacts link';

  @override
  String get labelAddresses => 'Addresses';

  @override
  String get labelWorkDetails => 'Work details';

  @override
  String get actionBackUpNow => 'Back up now';

  @override
  String get descBackUpNow =>
      'Save all your contacts, photos and settings to one password-protected file.';

  @override
  String get actionRestoreFromFile => 'Restore from a file';

  @override
  String get descRestoreFromFile =>
      'Load a backup file. This replaces everything currently in the app.';

  @override
  String get descBackupPasswordNote =>
      'The backup is locked with your password. Keep it safe — without it the file cannot be opened, on this or any other phone. That same password is what lets you restore on a new phone.';

  @override
  String get msgCreatingBackup => 'Creating backup…';

  @override
  String get msgBackupReady => 'Backup ready. Choose where to save it.';

  @override
  String errorBackupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get msgRestoring => 'Restoring…';

  @override
  String get msgRestoreComplete => 'Restore complete.';

  @override
  String errorRestoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get titleReplaceAllData => 'Replace all data?';

  @override
  String get descReplaceAllData =>
      'Restoring will DELETE everything currently in the app — all contacts, call history, groups and settings — and replace it with the backup. This cannot be undone.';

  @override
  String errorPasswordTooShort(int count) {
    return 'Use at least $count characters.';
  }

  @override
  String get errorPasswordsDontMatch => 'The passwords do not match.';

  @override
  String get errorEnterBackupPassword => 'Enter the backup password.';

  @override
  String get titleSetBackupPassword => 'Set a backup password';

  @override
  String get titleBackupPassword => 'Backup password';

  @override
  String get labelPassword => 'Password';

  @override
  String get labelEnterPassword => 'Enter password';

  @override
  String get labelConfirmPassword => 'Confirm password';

  @override
  String get actionBackUp => 'Back up';

  @override
  String get actionRestore => 'Restore';

  @override
  String get titleSendToDevice => 'Send to Another Device';

  @override
  String get descSendToDevice =>
      'Share your contacts (and more) with another phone over Wi-Fi.';

  @override
  String get titleReceiveFromDevice => 'Receive from Another Device';

  @override
  String get descReceiveFromDevice =>
      'Add another phone\'s contacts to this phone. Nothing already here is changed or removed.';

  @override
  String get descSyncFooter =>
      'Both phones must be on the same Wi-Fi network and running this app.';

  @override
  String get descSameWifi => 'Both phones must be on the same Wi-Fi network.';

  @override
  String get msgConnecting => 'Connecting…';

  @override
  String get msgWaitingForSender =>
      'Connected — waiting for the sender to choose…';

  @override
  String get titleReceived => 'Received';

  @override
  String descReceivedSummary(int added, int skipped) {
    return 'Added $added new contacts ($skipped already on this phone were kept). Nothing was removed.';
  }

  @override
  String get titleCouldNotReceive => 'Could not receive';

  @override
  String get errorEnterAddressPortCode =>
      'Enter the address, port and pairing code';

  @override
  String get descReceiveAddsOnly =>
      'This ADDS the other phone\'s contacts to this phone. Contacts you already have are kept as they are — nothing here is changed or removed.';

  @override
  String get actionScanOtherPhoneQr => 'Scan the other phone\'s QR';

  @override
  String get descOrEnterByHand => 'or enter by hand';

  @override
  String get labelOtherPhoneAddress => 'Other phone\'s address';

  @override
  String get labelPort => 'Port';

  @override
  String get labelPairingCode => 'Pairing code';

  @override
  String get hintShownOnOtherPhone => 'shown on the other phone';

  @override
  String get actionConnect => 'Connect';

  @override
  String get errorNotPairingCode =>
      'Not a SreerajP Contacts Sphere pairing code';

  @override
  String get titleScanPairingCode => 'Scan pairing code';

  @override
  String get titleSent => 'Sent';

  @override
  String descSentSummary(int contacts, int groups, int callLogs) {
    return 'Sent $contacts contacts, $groups groups and $callLogs call-log entries to the other phone.';
  }

  @override
  String get titleCouldNotSend => 'Could not send';

  @override
  String get descSendIntro =>
      'Share this phone\'s SreerajP Contacts Sphere data with another phone on the same Wi-Fi. Start below, then scan the QR (or type the code) on the other phone. After it connects, pick what to send.';

  @override
  String get actionStart => 'Start';

  @override
  String get descScanThisCode =>
      'On the other phone, choose Receive, then scan this code:';

  @override
  String get descEnterTheseByHand => '…or enter these by hand:';

  @override
  String get labelThisPhoneAddress => 'This phone\'s address';

  @override
  String get actionCopyCode => 'Copy code';

  @override
  String get msgAddressCopied => 'Address copied';

  @override
  String get msgCodeCopied => 'Code copied';

  @override
  String get msgWaitingForOtherPhone => 'Waiting for the other phone…';

  @override
  String get labelOtherPhoneConnected => 'Other phone connected';

  @override
  String get labelCallHistory => 'Call history';

  @override
  String get labelBlockedSpamNumbers => 'Blocked & spam numbers';

  @override
  String get labelEmergencyInfoCard => 'Emergency info card';

  @override
  String get labelAppSettings => 'App settings';

  @override
  String get titleChooseWhatToShare => 'Choose what to share';

  @override
  String get descNeverOverrides =>
      'This never overrides anything already on the other phone. On a conflict, the other phone keeps its own data.';

  @override
  String get actionFullSyncNewPhone => 'Full Sync (for a brand-new phone)';

  @override
  String get labelOrSendOnly => 'Or send only:';

  @override
  String get labelAlwaysIncluded => 'Always included';

  @override
  String get actionSendSelected => 'Send selected';

  @override
  String get titleFullSync => 'Full Sync?';

  @override
  String get descFullSync =>
      'Send everything (contacts, groups, call history, relationships, blocked numbers and settings). Best for a brand-new phone. The other phone still keeps any data it already has.';

  @override
  String get actionSendEverything => 'Send everything';

  @override
  String get descScreenshotGuardRow =>
      'Block screenshots, recordings, and Recents preview';

  @override
  String get descAuditLogRow =>
      'What changed on your contacts, and how to undo it';

  @override
  String get descLockOff => 'Off — the app opens without a lock';

  @override
  String get descLockDevice => 'On — unlock with your device lock';

  @override
  String get descLockAppPin => 'On — unlock with your app PIN';

  @override
  String get titleAppLock => 'App lock';

  @override
  String get labelLockOff => 'Off';

  @override
  String get descLockOffOption => 'No lock when opening the app';

  @override
  String get labelDeviceLock => 'Device lock';

  @override
  String get descDeviceLockOption => 'Fingerprint, face or device PIN';

  @override
  String get descDeviceLockUnavailable =>
      'Set a screen lock on your device to use this';

  @override
  String get labelAppPin => 'App PIN';

  @override
  String get descAppPinOption => 'A separate PIN just for this app';

  @override
  String get descUnlockReason => 'Unlock SreerajP Contacts Sphere';

  @override
  String get titleAppLocked => 'SreerajP Contacts Sphere is locked';

  @override
  String get descUnlockDevice =>
      'Unlock with your fingerprint, face or device PIN to continue';

  @override
  String get labelUnlocking => 'Unlocking…';

  @override
  String get actionUnlock => 'Unlock';

  @override
  String get descEnterAppPin => 'Enter your app PIN to continue';

  @override
  String get actionForgotPin => 'Forgot PIN?';

  @override
  String get titleEnterRecoveryCode => 'Enter recovery code';

  @override
  String get descEnterRecoveryCode =>
      'Enter the recovery code you saved when setting the PIN. This turns App lock off so you can set a new PIN.';

  @override
  String get labelRecoveryCode => 'Recovery code';

  @override
  String get errorIncorrectCode => 'Incorrect code';

  @override
  String get titleSetAppPin => 'Set an app PIN';

  @override
  String get titleConfirmPin => 'Confirm your PIN';

  @override
  String get titleSaveRecoveryCode => 'Save your recovery code';

  @override
  String get descChoosePin => 'Choose a 4 to 6 digit PIN to unlock the app';

  @override
  String get descEnterSamePin => 'Enter the same PIN again';

  @override
  String get descRecoveryCodeInfo =>
      'If you forget your PIN, this code lets you back in. Write it down and keep it safe — it is shown only once.';

  @override
  String get errorCouldNotSavePin => 'Couldn\'t save the PIN. Try again.';

  @override
  String get errorPinsDidntMatch => 'PINs didn\'t match — start again';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get msgRecoveryCodeCopied => 'Recovery code copied';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionSavedTurnOnLock => 'I\'ve saved it — turn on App lock';

  @override
  String get descThemeModeRow => 'Choose between Light, Dark, or System mode';

  @override
  String get descTypographyRow => 'App font family and text scale preferences';

  @override
  String get descAccentColorRow =>
      'Custom color palette, presets, and live preview';

  @override
  String titleSpeedDialSlot(int slot) {
    return 'Speed dial $slot';
  }

  @override
  String get descSpeedDialIntro =>
      'Hold a keypad key on the dialer to call the person saved on it. Holding works only when the number box is empty. Secret contacts cannot be saved to a key.';

  @override
  String get descTapToChooseContact => 'Tap to choose a contact';

  @override
  String tooltipRemoveFromKey(int slot) {
    return 'Remove from key $slot';
  }

  @override
  String get descDefaultCountryInfo =>
      'Used to match incoming and dialed numbers to your contacts';

  @override
  String get tooltipOpenSystemSettings => 'Open system settings';

  @override
  String get labelExplicitPerms => 'Explicit';

  @override
  String get descExplicitPerms =>
      'Permissions and system roles requiring user interaction or runtime approval.';

  @override
  String get labelImplicitPerms => 'Implicit';

  @override
  String get descImplicitPerms =>
      'Declared in the manifest; granted automatically by system at install.';

  @override
  String get labelGranted => 'Granted';

  @override
  String get labelDenied => 'Denied';

  @override
  String get labelPermDialer => 'Default phone app';

  @override
  String get descPermDialer =>
      'Become the system dialer so SreerajP Contacts Sphere shows its own in-call screen and call screening controls.';

  @override
  String get labelPermContacts => 'Contacts';

  @override
  String get descPermContacts =>
      'Read and sync contacts from your device address book.';

  @override
  String get labelPermPhone => 'Phone & Call Log';

  @override
  String get descPermPhone =>
      'Place, answer and manage calls, and reconcile their real duration from the call log.';

  @override
  String get labelPermMicrophone => 'Microphone';

  @override
  String get descPermMicrophone =>
      'Voice input / speech-to-text when adding notes.';

  @override
  String get labelPermLocation => 'Location';

  @override
  String get descPermLocation =>
      'Tag contacts with places and support BLE scanning on older Android.';

  @override
  String get labelPermNotifications => 'Notifications';

  @override
  String get descPermNotifications =>
      'Show reminders for birthdays, follow-ups and missed calls.';

  @override
  String get labelPermAlarms => 'Alarms & reminders';

  @override
  String get descPermAlarms =>
      'Lets Smart Redial call back on schedule even if the app is closed.';

  @override
  String get labelPermPhotos => 'Photos & Media';

  @override
  String get descPermPhotos =>
      'Pick a profile photo for a contact from your gallery.';

  @override
  String get labelPermCamera => 'Camera';

  @override
  String get descPermCamera =>
      'Take a new photo for a contact or scan QR codes.';

  @override
  String get labelPermBtScan => 'Bluetooth Scan';

  @override
  String get descPermBtScan =>
      'Find a nearby phone sharing a contact over Bluetooth (declared with neverForLocation).';

  @override
  String get labelPermBtConnect => 'Bluetooth Connect';

  @override
  String get descPermBtConnect =>
      'Connect to another phone to transfer contacts over Bluetooth.';

  @override
  String get labelPermBtAdvertise => 'Bluetooth Advertise';

  @override
  String get descPermBtAdvertise =>
      'Make this phone discoverable while sharing contacts over Bluetooth.';

  @override
  String get labelPermBiometrics => 'Biometrics';

  @override
  String get descPermBiometrics =>
      'Unlock secret contacts, and confirm before exporting or syncing them, with fingerprint or face.';

  @override
  String get labelPermProximity => 'Screen off near ear';

  @override
  String get descPermProximity =>
      'Turns the screen off while holding the phone to your ear during a call so your cheek cannot tap controls.';

  @override
  String get labelPermCallService => 'Foreground Call Service & Ringing';

  @override
  String get descPermCallService =>
      'Runs active call services, full-screen incoming alerts, and vibration when calls arrive.';

  @override
  String get labelPermBtLegacy => 'Bluetooth (legacy)';

  @override
  String get descPermBtLegacy => 'Bluetooth access on Android 11 and below.';

  @override
  String get labelPermBoot => 'Start after restart';

  @override
  String get descPermBoot =>
      'Puts your emergency info card back on the lock screen after the phone reboots. Used for nothing else.';

  @override
  String get labelPermInternet => 'Internet & Wi-Fi';

  @override
  String get descPermInternet =>
      'Copies your data to another phone over your local Wi-Fi during P2P sync. No cloud server is contacted.';

  @override
  String get tooltipRefreshSims => 'Refresh SIMs';

  @override
  String get emptyNoSims =>
      'No SIMs detected. Multi-SIM options need phone permission and a device with at least one SIM. Grant the phone permission and tap refresh.';

  @override
  String get descDefaultSimInfo =>
      'Which SIM outgoing calls use unless you pick per call';

  @override
  String get descLetAndroidChoose => 'Let Android choose';

  @override
  String get labelAskSimEachCall => 'Ask which SIM before each call';

  @override
  String get descAskSimEachCall =>
      'Show a SIM chooser each time you place a call';

  @override
  String get descNeedsMoreThanOneSim => 'Needs more than one SIM';

  @override
  String get labelSimColours => 'SIM colours';

  @override
  String get descSimColoursInfo =>
      'The SIM name appears in this colour on the calling screen';

  @override
  String get labelDefaultColour => 'Default colour';

  @override
  String titleColourFor(String name) {
    return 'Colour for $name';
  }

  @override
  String get actionUseDefault => 'Use default';

  @override
  String get titlePerSimRingtones => 'Per-SIM Ringtones';

  @override
  String get emptyNoSimsRingtone =>
      'No SIMs detected. Per-SIM ringtones need phone permission and a device with at least one SIM. Grant the phone permission and tap refresh.';

  @override
  String get labelPerSimRingtone => 'Per-SIM ringtone';

  @override
  String get descPerSimRingtone => 'A ringtone for calls received on each SIM';

  @override
  String get tooltipChangeRingtone => 'Change ringtone';

  @override
  String get tooltipPickRingtone => 'Pick ringtone';

  @override
  String get descPerContactRingtoneNote =>
      'A ringtone set on an individual contact takes precedence over the per-SIM ringtone. Set one from a contact’s edit screen.';

  @override
  String descSlotDefaultRingtone(String slot) {
    return '$slot · default ringtone';
  }

  @override
  String descSlotDefaultTone(String slot, String tone) {
    return '$slot · Default · $tone';
  }

  @override
  String get titleVolumeVibration => 'Volume & Vibration';

  @override
  String get labelRingtoneVolume => 'Ringtone volume';

  @override
  String get descRingtoneMuted =>
      'Muted — the ringtone won’t sound, but the phone still vibrates if vibration is on below';

  @override
  String descRingtoneVolumePercent(int value) {
    return 'Plays incoming-call ringtones at $value% of your phone’s ring volume';
  }

  @override
  String get labelVibrateIncoming => 'Vibrate on incoming calls';

  @override
  String get descVibrateIncoming =>
      'Your phone comes first: silent mode, Do Not Disturb and the phone’s own “Vibrate for calls” setting all override this';

  @override
  String get descQuietHoursSwitch =>
      'Silence calls at night except for chosen allowed contacts';

  @override
  String get labelQuietHoursRange => 'Quiet hours range';

  @override
  String get labelAllowedRingThrough => 'Allowed Contacts (Ring Through)';

  @override
  String get descAllowedRingThrough =>
      'Callers in allowed relationships, tags, or individual contacts ring loudly; all others are silenced.';

  @override
  String get labelAllowedRelationships => 'Allowed Relationships & Categories';

  @override
  String get labelEmergencyContactsIce => 'Emergency Contacts (ICE)';

  @override
  String get labelStarredContacts => 'Starred Contacts';

  @override
  String get actionAddRelationship => 'Add Relationship';

  @override
  String get labelAllowedTags => 'Allowed Tags';

  @override
  String get actionAddTag => 'Add Tag';

  @override
  String get labelSpecificContacts => 'Specific Contacts';

  @override
  String labelContactNumber(int id) {
    return 'Contact #$id';
  }

  @override
  String get actionAddContact => 'Add Contact';

  @override
  String labelAllowedActiveNumbers(int count) {
    return 'Allowed active numbers: $count';
  }

  @override
  String get titleSelectAllowedRelationships => 'Select Allowed Relationships';

  @override
  String get titleSelectAllowedTags => 'Select Allowed Tags';

  @override
  String get emptyNoTagsInContacts =>
      'No tags found in contacts. Create tags on contacts first.';

  @override
  String get titleSelectAllowedContacts => 'Select Allowed Contacts';

  @override
  String get hintQuietStartTime => 'SELECT RELATIONSHIP QUIET HOURS START TIME';

  @override
  String get hintQuietEndTime => 'SELECT RELATIONSHIP QUIET HOURS END TIME';

  @override
  String get titleNewQuickReply => 'New quick reply';

  @override
  String get titleEditQuickReply => 'Edit quick reply';

  @override
  String get hintQuickReplyExample => 'e.g. Can\'t talk now. Call you later.';

  @override
  String get titleResetQuickReplies => 'Reset quick replies?';

  @override
  String get descResetQuickReplies =>
      'Your custom messages will be replaced by the default ones.';

  @override
  String get actionReset => 'Reset';

  @override
  String get tooltipResetToDefaults => 'Reset to defaults';

  @override
  String get descQuickRepliesInfo =>
      'Quick replies appear when you reject an incoming call with a message. The reply is sent to the caller as an SMS from the SIM the call came in on.';

  @override
  String get actionAddReply => 'Add a reply';

  @override
  String get descAddReply => 'Write a message to offer when rejecting a call';

  @override
  String get emptyNoQuickReplies =>
      'No quick replies yet. Add one, or reset to the defaults from the top-right.';

  @override
  String labelRepliesCount(int count) {
    return 'Replies ($count)';
  }

  @override
  String get labelCatImmediateFamily => 'Immediate Family';

  @override
  String get labelCatExtendedFamily => 'Extended Family';

  @override
  String get labelCatFamilyByMarriage => 'Family by Marriage';

  @override
  String get labelCatProfessional => 'Professional';

  @override
  String get labelCatEducational => 'Educational';

  @override
  String get labelCatSocial => 'Social';

  @override
  String get labelCatService => 'Service';

  @override
  String get titleNewRelationship => 'New relationship';

  @override
  String get titleEditRelationship => 'Edit relationship';

  @override
  String get labelRelationshipName => 'Relationship name';

  @override
  String get errorRelationshipExists => 'That relationship already exists';

  @override
  String get titleResetRelationshipNames => 'Reset relationship names?';

  @override
  String get descResetRelationshipNames =>
      'Your custom list will be replaced by the built-in relationship names.';

  @override
  String get titleRelationshipNames => 'Relationship names';

  @override
  String get descRelationshipNamesInfo =>
      'These labels appear as chips when you link two contacts, under whichever of the seven categories they belong to. You can still type any label you like. Editing them here does not change relationships you have already saved.';

  @override
  String get actionAddRelationshipName => 'Add a relationship';

  @override
  String get descAddRelationshipName =>
      'Add a name to offer when linking contacts';

  @override
  String get emptyNoRelationshipNames =>
      'No relationship names yet. Add one, or reset to the defaults from the top-right.';

  @override
  String labelRelationshipsCount(int count) {
    return 'Relationships ($count)';
  }

  @override
  String get labelContactCounts => 'Contact counts';

  @override
  String get descGrantContactsToCount =>
      'Grant contacts permission to count device contacts';

  @override
  String descDeviceAppCounts(String device, String app) {
    return 'Device: $device  ·  App: $app';
  }

  @override
  String get labelSearchIndex => 'Search index';

  @override
  String get msgCheckingSearchIndex => 'Checking search index...';

  @override
  String get descIndexHealthy => 'Index healthy — all contacts are findable';

  @override
  String descIndexStale(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts have stale search keys',
      one: '1 contact has stale search keys',
    );
    return '$_temp0';
  }

  @override
  String get actionRebuild => 'Rebuild';

  @override
  String get descAuthExportSecret =>
      'Authenticate to export your secret contacts';

  @override
  String get errorAuthRequiredExportSecret =>
      'Authentication required to export secret contacts';

  @override
  String msgExportedSecretTo(String path) {
    return 'Exported secret contacts to $path';
  }

  @override
  String errorExportSecretFailed(String error) {
    return 'Failed to export secret contacts: $error';
  }

  @override
  String get titleSecretContactsExport => 'Secret Contacts & Export';

  @override
  String get labelIncludeSecretInExport => 'Include secret contacts in export';

  @override
  String get descIncludeSecretInExport =>
      'When off, standard VCF exports skip contacts flagged as secret';

  @override
  String get labelExportSecretContacts => 'Export secret contacts';

  @override
  String get descExportSecretContacts =>
      'Save a separate VCF file containing only secret contacts (gated by auth)';

  @override
  String get titleSpokenAnnouncement => 'Spoken Caller Announcement';

  @override
  String get descSpokenAnnouncementSwitch =>
      'Announce caller\'s name over ringtone (\"Amma calling\" / \"അമ്മ വിളിക്കുന്നു\")';

  @override
  String get descSuppressDuringQuiet =>
      'Suppress spoken announcements during quiet hours';

  @override
  String get labelTestAnnouncement => 'Test spoken announcement';

  @override
  String get descTestAnnouncement =>
      'Preview English or Malayalam voice announcement';

  @override
  String get hintQuietStartTimeGeneric => 'SELECT QUIET HOURS START TIME';

  @override
  String get hintQuietEndTimeGeneric => 'SELECT QUIET HOURS END TIME';

  @override
  String get descEnterCallerNameToTest => 'Enter caller name to test:';

  @override
  String get hintCallerNameExample => 'e.g. Amma or അമ്മ';

  @override
  String get actionPlayTest => 'Play Test';

  @override
  String get titlePostCallOptions => 'Post-call Options';

  @override
  String get labelAskAfterCalls => 'Ask after calls';

  @override
  String get descAskAfterCalls =>
      'Show the “How did it go?” sheet when a call ends';

  @override
  String get hintRelationshipNameExample => 'e.g. Mentor';

  @override
  String get helpHomeText1 => 'Help & User Guides';

  @override
  String get helpHomeHeading1 => 'Calling & Dialer';

  @override
  String get helpHomeTitle1 => 'T9 Dialing & Malayalam';

  @override
  String get helpHomeSub1 =>
      'How multi-script T9 search works and where Malayalam vowels (അ to അഃ) are mapped.';

  @override
  String get helpHomeTitle2 => 'Calling & In-Call Controls';

  @override
  String get helpHomeSub2 =>
      'Conference merge, hold and swap, dual-SIM options, smart redial, and spoken caller names.';

  @override
  String get helpHomeTitle3 => 'Call Screening & Blocking';

  @override
  String get helpHomeSub3 =>
      'Blocking a number before it rings, blocked unknown callers, and why the default dialer role is needed.';

  @override
  String get helpHomeTitle4 => 'Caller ID & Spam Filter';

  @override
  String get helpHomeSub4 =>
      'Labelling unknown callers, ringing suspected spam silently, and marking a number as spam.';

  @override
  String get helpHomeTitle5 => 'Call Context & Notes';

  @override
  String get helpHomeSub5 =>
      'Pre-call summary, \"Likely to answer now\", and the notes you write after a call.';

  @override
  String get helpHomeHeading2 => 'Organization & Sharing';

  @override
  String get helpHomeTitle6 => 'Relationship Spheres';

  @override
  String get helpHomeSub6 =>
      'The 7 categories from Immediate Family to Service, your own labels, and quiet hours.';

  @override
  String get helpHomeTitle7 => 'Groups & Tags';

  @override
  String get helpHomeSub7 =>
      'Building groups, group ringtones, the tag cloud, and selecting many contacts at once.';

  @override
  String get helpHomeTitle8 => 'Duplicate Contacts & Merge';

  @override
  String get helpHomeSub8 =>
      'How identical names, phones, and emails are detected and merged without data loss.';

  @override
  String get helpHomeTitle9 => 'Sharing & Card Scanning';

  @override
  String get helpHomeSub9 =>
      'QR contact codes, the on-device business card scanner, and sharing over Bluetooth.';

  @override
  String get helpHomeTitle10 => 'Import & Export Files';

  @override
  String get helpHomeSub10 =>
      'CSV and vCard files in and out, and AirQR for sending more than one QR code can hold.';

  @override
  String get helpHomeHeading3 => 'Privacy & Protection';

  @override
  String get helpHomeTitle11 => 'Privacy, Security & Vault';

  @override
  String get helpHomeSub11 =>
      'Secret contacts vault, biometric/PIN protection, screenshot guard, and security audit log.';

  @override
  String get helpHomeTitle12 => 'Biometric Lock Details';

  @override
  String get helpHomeSub12 =>
      'Every place the app asks for your fingerprint or face, and what happens without a screen lock.';

  @override
  String get helpHomeTitle13 => 'App Lock & PIN';

  @override
  String get helpHomeSub13 =>
      'The three lock modes, setting an App PIN, and the recovery code if you forget it.';

  @override
  String get helpHomeTitle14 => 'Permissions Explained';

  @override
  String get helpHomeSub14 =>
      'What each permission is for, which are optional, and what stops working if you say no.';

  @override
  String get helpHomeTitle15 => 'Emergency Info Card';

  @override
  String get helpHomeSub15 =>
      'Setting lock-screen medical details and emergency contacts for first responders.';

  @override
  String get helpHomeHeading4 => 'Sync & Backups';

  @override
  String get helpHomeTitle16 => 'Local Wi-Fi P2P Device Sync';

  @override
  String get helpHomeSub16 =>
      'How direct device-to-device Wi-Fi transfer works with end-to-end encryption and zero cloud.';

  @override
  String get helpHomeTitle17 => 'Phonebook & Call Log Sync';

  @override
  String get helpHomeSub17 =>
      'Merging or mirroring contacts and call history with Android system storage.';

  @override
  String get helpHomeTitle18 => 'Cloud Sync & Google Drive';

  @override
  String get helpHomeSub18 =>
      'Two-way online sync, encrypted cloud backups, WebDAV setup, and vault privacy.';

  @override
  String get helpHomeTitle19 => 'Offline Backup & Restore';

  @override
  String get helpHomeSub19 =>
      'Exporting encrypted backup files, password safety, and restoring on a new phone.';

  @override
  String get helpHomeHeading5 => 'Personalization & Tools';

  @override
  String get helpHomeTitle20 => 'Look, Sound & Region';

  @override
  String get helpHomeSub20 =>
      'Theme and accent colour, fonts and text size, ringtones and vibration, and the default country.';

  @override
  String get helpHomeTitle21 => 'Contact Tools';

  @override
  String get helpHomeSub21 =>
      'Temporary self-deleting contacts, connected messaging apps, and the search index.';

  @override
  String get helpHomeHeading6 => 'Frequently Asked Questions';

  @override
  String get helpHomeTitle22 => 'FAQs & Troubleshooting Guide';

  @override
  String get helpHomeSub22 =>
      'Direct answers to top questions: permissions, default dialer, quiet hours, and search indexing.';

  @override
  String get helpHomeText2 => 'Help Center & Knowledge Base';

  @override
  String get helpHomeText3 =>
      'Browse in-depth guides and solutions for all features of SreerajP Contacts Sphere.';

  @override
  String get helpGroupsTagsTitle1 => 'Groups & tags';

  @override
  String get helpGroupsTagsIntro =>
      'Groups and tags are two different ways to sort the same address book. A contact belongs to groups you build by hand, and carries tags you type as short labels. Both are yours — the app never creates one on its own.';

  @override
  String get helpGroupsTagsTitle2 => 'Groups';

  @override
  String get helpGroupsTagsBullet1 =>
      'Open the Contacts tab and tap the group icon in the top bar to see all your groups.';

  @override
  String get helpGroupsTagsBullet2 =>
      'Create a group, give it a name, and add members. A contact can be in more than one group.';

  @override
  String get helpGroupsTagsBullet3 =>
      'A group can carry its own ringtone. Pick one from the phone\'s ringtones or from an audio file in your folders.';

  @override
  String get helpGroupsTagsBullet4 =>
      'The group ringtone is used for members who do not have their own ringtone set. A ringtone on the contact always wins.';

  @override
  String get helpGroupsTagsTitle3 => 'Tags';

  @override
  String get helpGroupsTagsBullet5 =>
      'A tag is a short word you attach to a contact while editing them — \"plumber\", \"school\", \"trek group\". There is no fixed list; type whatever fits.';

  @override
  String get helpGroupsTagsBullet6 =>
      'The Tags tab at the bottom of the app shows every tag in use as a cloud. A tag used by more contacts is drawn larger.';

  @override
  String get helpGroupsTagsBullet7 =>
      'Tap a tag to see everyone who carries it. From there you can call, message, or open any of them.';

  @override
  String get helpGroupsTagsBullet8 =>
      'Tags also work as an exception list for quiet hours, so a whole tag can be allowed to ring through.';

  @override
  String get helpGroupsTagsTitle4 => 'Working on many contacts at once';

  @override
  String get helpGroupsTagsBullet9 =>
      'Long-press a contact in the list to start selecting. Tap more contacts to add them to the selection.';

  @override
  String get helpGroupsTagsBullet10 =>
      'The top bar then offers \"Select all\" and \"Delete selected\", so you can clear out many contacts in one step.';

  @override
  String get helpGroupsTagsBullet11 =>
      'Tap the cross in the top bar to leave selection mode without changing anything.';

  @override
  String get helpGroupsTagsFooter =>
      'Tip: use a group when the set is fixed and you want one ringtone for it. Use a tag when you only want to find those people again later.';

  @override
  String get helpAppLockTitle1 => 'App lock & PIN';

  @override
  String get helpAppLockIntro =>
      'App lock puts a screen in front of the whole app when you open it. You pick how it is unlocked under Settings → Security → App lock. There are three choices.';

  @override
  String get helpAppLockTitle2 => 'The three modes';

  @override
  String get helpAppLockBullet1 =>
      'Off — the app opens straight away. Secret contacts still ask for an unlock separately.';

  @override
  String get helpAppLockBullet2 =>
      'Device lock — uses your phone\'s own fingerprint, face, or screen-lock PIN. This choice is greyed out until you set a screen lock in Android settings.';

  @override
  String get helpAppLockBullet3 =>
      'App PIN — a separate PIN just for this app, typed on a keypad inside the app. Useful when other people know your phone PIN.';

  @override
  String get helpAppLockTitle3 => 'Setting up an App PIN';

  @override
  String get helpAppLockBullet4 =>
      'Choose a PIN of 4 to 6 digits and confirm it.';

  @override
  String get helpAppLockBullet5 =>
      'You are then shown a one-time recovery code. Write it down or copy it somewhere safe — it is shown once and never again.';

  @override
  String get helpAppLockBullet6 =>
      'The PIN is not stored as you typed it, and nobody can read it back out of the app.';

  @override
  String get helpAppLockTitle4 => 'If you forget the App PIN';

  @override
  String get helpAppLockBullet7 =>
      'Tap \"Forgot PIN?\" on the lock screen and enter your recovery code.';

  @override
  String get helpAppLockBullet8 =>
      'A correct code switches App lock off and lets you in. Set a new PIN afterwards if you still want the lock.';

  @override
  String get helpAppLockBullet9 =>
      'Without the recovery code there is no way past the lock. That is deliberate — a back door for you would be a back door for anyone.';

  @override
  String get helpAppLockTitle5 => 'When you are asked again';

  @override
  String get helpAppLockBullet10 =>
      'The lock screen returns when you come back to the app after leaving it, not on every screen inside it.';

  @override
  String get helpAppLockBullet11 =>
      'The back gesture cannot dismiss it. Only a correct unlock, or the recovery code, lets you through.';

  @override
  String get helpAppLockFooter =>
      'App lock guards the door. Your secret contacts, backups, and sync have their own unlock on top of it — see the Biometric lock guide.';

  @override
  String get helpContactToolsTitle1 => 'Contact tools';

  @override
  String get helpContactToolsIntro =>
      'Three smaller tools that are easy to miss: contacts that delete themselves, the messaging apps a contact can be reached on, and the search index that makes the dialer find people fast.';

  @override
  String get helpContactToolsTitle2 => 'Ephemeral (temporary) contacts';

  @override
  String get helpContactToolsBullet1 =>
      'While adding or editing a contact, switch on \"Ephemeral contact\". The entry then removes itself later, on its own.';

  @override
  String get helpContactToolsBullet2 =>
      'Choose how long it lives: 2 hours, 24 hours, 7 days, or \"Auto-delete after 1 call\".';

  @override
  String get helpContactToolsBullet3 =>
      'Good for a delivery driver, a cab, or a one-off seller — the number is there when you need it and gone afterwards.';

  @override
  String get helpContactToolsBullet4 =>
      'Opening the contact shows a banner counting down to its removal. From there you can add another 24 hours, or tap to keep it for good.';

  @override
  String get helpContactToolsBullet5 =>
      'The app checks about once a minute, so a contact disappears shortly after its time is up rather than at the exact second.';

  @override
  String get helpContactToolsTitle3 => 'Connected apps';

  @override
  String get helpContactToolsBullet6 =>
      'If a messenger such as WhatsApp, Telegram or Arattai has synced itself against a contact on your phone, that contact shows a row of those apps.';

  @override
  String get helpContactToolsBullet7 =>
      'Tap one to open the chat or call in that app directly. Nothing is sent by this app — it simply opens the other one.';

  @override
  String get helpContactToolsBullet8 =>
      'The row is read from your phone\'s own address book, so it appears only for contacts linked to a device contact, and only while contacts permission is granted.';

  @override
  String get helpContactToolsTitle4 => 'Contact counts & search index';

  @override
  String get helpContactToolsBullet9 =>
      'Settings → Contacts → Contact counts & search index shows how many contacts are on the phone and how many are in the app — the quickest way to see whether a sync worked.';

  @override
  String get helpContactToolsBullet10 =>
      'The search index is what makes T9 keypad search, transliterated search, and name search fast.';

  @override
  String get helpContactToolsBullet11 =>
      'The screen tells you either \"Index healthy — all contacts are findable\" or how many contacts have stale search keys.';

  @override
  String get helpContactToolsBullet12 =>
      'When some are stale, a Rebuild button appears. Tap it and the keys are rebuilt for the whole address book.';

  @override
  String get helpContactToolsBullet13 =>
      'Rebuild this if search stops finding a contact you know is saved, or after restoring an old backup.';

  @override
  String get helpContactToolsFooter =>
      'Tip: an ephemeral contact is deleted for real when its time is up. If you may want the number later, tap \"Keep permanently\" on the banner before it goes.';

  @override
  String get helpCallerIntelligenceTitle1 => 'Call context & notes';

  @override
  String get helpCallerIntelligenceIntro =>
      'The app reads your own call history to tell you a little about a person before you ring them, while they ring you, and after you hang up. All of it is worked out on this phone from data you already have.';

  @override
  String get helpCallerIntelligenceTitle2 => 'Before you call';

  @override
  String get helpCallerIntelligenceBullet1 =>
      'Open a contact and you see a short summary: when you last spoke, how long that call lasted, and what you noted about it.';

  @override
  String get helpCallerIntelligenceBullet2 =>
      'If the contact has an address with a city, the summary also shows the local time there — useful before calling someone in another country.';

  @override
  String get helpCallerIntelligenceBullet3 =>
      'When there is enough history, it suggests the time of day this person usually answers.';

  @override
  String get helpCallerIntelligenceTitle3 => '\"Likely to answer now\"';

  @override
  String get helpCallerIntelligenceBullet4 =>
      'The dialer shows a short row of contacts above the keypad. You choose what fills it in Settings → Dialer top contacts: Most recent, Family & friends, or Likely to answer now.';

  @override
  String get helpCallerIntelligenceBullet5 =>
      '\"Likely to answer now\" puts the people who usually pick up at this hour first. It is worked out from your own Recents — how often calls at this time of day were answered.';

  @override
  String get helpCallerIntelligenceBullet6 =>
      'This only changes the order of the row. The app never dials on its own here — every call is still a tap you make.';

  @override
  String get helpCallerIntelligenceTitle4 => 'While the phone is ringing';

  @override
  String get helpCallerIntelligenceBullet7 =>
      'For a saved contact, the call screen can show their relationship, how long it has been since you last spoke, and a birthday or anniversary coming up.';

  @override
  String get helpCallerIntelligenceBullet8 =>
      'A pending reminder you set for that person is shown too, so you remember why you meant to speak.';

  @override
  String get helpCallerIntelligenceTitle5 => 'After the call';

  @override
  String get helpCallerIntelligenceBullet9 =>
      'When a call ends, a \"How did it go?\" sheet can appear. Note how the call went, write down what you discussed, and set a follow-up reminder.';

  @override
  String get helpCallerIntelligenceBullet10 =>
      'You can dictate the note instead of typing it — tap the microphone and speak. Speech is turned into text on the phone.';

  @override
  String get helpCallerIntelligenceBullet11 =>
      'Everything you save joins that contact\'s timeline, which is what the next pre-call summary reads.';

  @override
  String get helpCallerIntelligenceBullet12 =>
      'If you would rather not be asked, turn the sheet off under Settings → SIM & calling → Post-call options.';

  @override
  String get helpCallerIntelligenceFooter =>
      'Privacy: none of this leaves the phone. There is no lookup service behind it — the app only reads your own contacts, call log, and notes from its encrypted database.';

  @override
  String get helpBiometricsText => 'Biometric lock';

  @override
  String get helpBiometricsIntro =>
      'SreerajP Contacts Sphere can ask for your fingerprint or face before it shows or moves your most private data. It uses your phone\'s own lock — the app never sees or stores your fingerprint or face.';

  @override
  String get helpBiometricsTitle1 => 'Where you are asked';

  @override
  String get helpBiometricsBullet1 =>
      'Viewing your secret contacts. These are hidden from the normal contact list until you unlock them.';

  @override
  String get helpBiometricsBullet2 =>
      'Exporting secret contacts, so a private contact cannot be sent out of the app without your say-so.';

  @override
  String get helpBiometricsBullet3 =>
      'Opening \"Sync to Another Device\", because a sync can include your secret contacts.';

  @override
  String get helpBiometricsBullet4 =>
      'Opening \"Backup & Restore\", because a backup can include them too.';

  @override
  String get helpBiometricsBullet5 =>
      'Opening the audit log, which holds a full before-and-after record of your contacts.';

  @override
  String get helpBiometricsBullet6 =>
      'Accepting a contact someone sends you over Bluetooth.';

  @override
  String get helpBiometricsBullet7 =>
      'Opening the app at all, if you set App lock to \"Device lock\" under Settings → Security.';

  @override
  String get helpBiometricsTitle2 => 'What counts as \"you\"';

  @override
  String get helpBiometricsBullet8 =>
      'Any fingerprint or face you have set up on the phone is accepted.';

  @override
  String get helpBiometricsBullet9 =>
      'If you have not set up a fingerprint or face, the phone falls back to your screen-lock PIN, pattern, or password.';

  @override
  String get helpBiometricsBullet10 =>
      'App lock can instead use an App PIN, which is separate from the phone\'s lock. That one is checked by the app itself — see the \"App lock & PIN\" guide.';

  @override
  String get helpBiometricsTitle3 => 'Your privacy';

  @override
  String get helpBiometricsBullet11 =>
      'The check is handled by Android, not by SreerajP Contacts Sphere. The app only learns whether the unlock passed or failed.';

  @override
  String get helpBiometricsBullet12 =>
      'This works offline. Nothing about your fingerprint or face ever leaves the phone.';

  @override
  String get helpBiometricsFooter =>
      'Tip: set up a screen lock (fingerprint, face, or PIN) in Android settings. With no lock at all the check cannot run, so sync and backup warn you and then let you decide whether to go on.';

  @override
  String get helpBackupText => 'Backup & Restore';

  @override
  String get helpBackupIntro =>
      'A backup saves everything in the app into one file that you keep. You can use it to move to a new phone or to recover after a reset — even if the new app was installed from a different source.';

  @override
  String get helpBackupTitle1 => 'What the backup holds';

  @override
  String get helpBackupBullet1 =>
      'All contacts and their details, call history, groups, relationships, and blocked / spam numbers.';

  @override
  String get helpBackupBullet2 =>
      'Contact photos and calling-card images are included inside the file.';

  @override
  String get helpBackupBullet3 =>
      'Your app settings, such as theme and accent color.';

  @override
  String get helpBackupBullet4 =>
      'Your emergency info card, with its emergency contacts and the \"show on lock screen\" switches.';

  @override
  String get helpBackupBullet5 =>
      'Custom ringtones are not included — they point at files on this phone that would not exist elsewhere.';

  @override
  String get helpBackupTitle2 => 'Your password is the key';

  @override
  String get helpBackupBullet6 =>
      'The backup file is locked with a password you choose. The app does not store it anywhere.';

  @override
  String get helpBackupBullet7 =>
      'You need the same password to restore — on this phone or any other. Keep it somewhere safe.';

  @override
  String get helpBackupBullet8 =>
      'If you lose the password, the file cannot be opened. There is no way to recover it — that is what keeps your data private.';

  @override
  String get helpBackupTitle3 => 'Restoring replaces everything';

  @override
  String get helpBackupBullet9 =>
      'Restoring DELETES what is currently in the app and rebuilds it as an exact copy of the backup.';

  @override
  String get helpBackupBullet10 =>
      'It is not a merge. If you want to combine two phones without losing data, use \"Sync to Another Device\" instead.';

  @override
  String get helpBackupBullet11 =>
      'Restore a backup made with the same app version. A backup from a very different version may be refused.';

  @override
  String get helpBackupFooter =>
      'Tip: after making a backup, the app opens the share sheet so you can save the file to Files, Drive, or send it to yourself. Store it somewhere other than this phone.';

  @override
  String get helpT9DialingText => 'T9 Dialing & Malayalam';

  @override
  String get helpT9DialingIntro =>
      'SreerajP Contacts Sphere features a smart multi-script T9 dialpad. You can search your contacts seamlessly using English or regional script key presses (Malayalam, Devanagari, etc.).';

  @override
  String get helpT9DialingTitle1 => 'Malayalam Vowels Mapping (അ to അഃ)';

  @override
  String get helpT9DialingBullet1 =>
      'Key 2 (ക-ങ): Vowels അ, ആ + Matras ാ, ി, ീ';

  @override
  String get helpT9DialingBullet2 =>
      'Key 3 (ച-ഞ): Vowels ഉ, ഊ, ഋ + Matras ു, ൂ, ൃ';

  @override
  String get helpT9DialingBullet3 =>
      'Key 4 (ട-ണ): Vowels എ, ഏ, ഐ + Matras െ, േ, ൈ';

  @override
  String get helpT9DialingBullet4 =>
      'Key 5 (ത-ന): Vowels ഒ, ഓ, ഔ + Matras ൊ, ോ, ൌ, ൗ';

  @override
  String get helpT9DialingBullet5 =>
      'Key 9 (ള-റ): Anusvaram & Visargam (ം, ഃ) + Chillu letters (ൺ, ൻ, ർ, ൽ, ൾ, ൿ)';

  @override
  String get helpT9DialingTitle2 => 'Why Vowels Aren\'t Printed on Key Labels';

  @override
  String get helpT9DialingBullet6 =>
      'Key legends display consonant group ranges (e.g. ക-ങ, ച-ഞ) to keep the dialpad clean and easy to read.';

  @override
  String get helpT9DialingBullet7 =>
      'Even though vowels are not printed on the button face, all vowels (അ-ഔ), matras, and chillu letters are fully mapped and active in T9 search.';

  @override
  String get helpT9DialingTitle3 => 'Manglish & Transliteration Search';

  @override
  String get helpT9DialingBullet8 =>
      'English T9 key presses automatically match Malayalam names. For example, typing 2-6-4-5 (A-N-I-L) will match both \"Anil\" and \"അനിൽ\".';

  @override
  String get helpT9DialingBullet9 =>
      'To change the script shown on the keys, use the \"Dialpad script\" card on the main Settings page.';

  @override
  String get helpT9DialingFooter =>
      'Tip: the \"Dialpad script\" card offers Auto, Malayalam, Devanagari, Cyrillic, Arabic, Greek, or None. Auto follows the app language. Whichever you pick, search still matches every script — the setting only changes what is printed on the keys.';

  @override
  String get helpCloudSyncText => 'Cloud Sync & Backup';

  @override
  String get helpCloudSyncIntro =>
      'SreerajP Contacts Sphere connects with Google, Microsoft, and CardDAV/WebDAV servers. You can use a single provider or decouple them — syncing live contacts with one service while backing up your encrypted database to another.';

  @override
  String get helpCloudSyncTitle1 => 'Contact Sync vs Cloud Backup';

  @override
  String get helpCloudSyncBullet1 =>
      'Online Contact Sync (Live 2-Way): synchronizes individual contact cards (names, phone numbers, emails) directly with Google People API, Microsoft Graph Contacts, or CardDAV address books. Synced contacts appear in your online address book.';

  @override
  String get helpCloudSyncBullet2 =>
      'Encrypted Cloud Backup: exports a full, password-encrypted .csbak file containing your complete database (all contacts, call history, call notes, tags, settings, and emergency info) to cloud file storage (Google Drive AppData, Microsoft OneDrive, or WebDAV).';

  @override
  String get helpCloudSyncTitle2 => 'Mixing cloud providers';

  @override
  String get helpCloudSyncBullet3 =>
      'You can use Google for live contact sync while storing encrypted cloud backups on Microsoft OneDrive or a self-hosted WebDAV server.';

  @override
  String get helpCloudSyncBullet4 =>
      'In Settings → Online Provider Sync, toggle \"Contact Sync: On\" and \"Cloud Backup: Off\" for your Google account.';

  @override
  String get helpCloudSyncBullet5 =>
      'Add your Microsoft or WebDAV account separately and select it when uploading encrypted cloud backups in Settings → Encrypted Cloud Backup.';

  @override
  String get helpCloudSyncTitle3 => 'Privacy & Security';

  @override
  String get helpCloudSyncBullet6 =>
      'Secret Vault Contacts: contacts saved as Secret in SreerajP Contacts Sphere are app-only and are NEVER uploaded or synced to online contact providers (Google Contacts, Outlook, or CardDAV).';

  @override
  String get helpCloudSyncBullet7 =>
      'Encrypted Payload: Cloud backup files (.csbak) are encrypted locally using PBKDF2 and AES-GCM with your personal passphrase before upload. The cloud provider cannot read your backup data.';

  @override
  String get helpCloudSyncFooter =>
      'Tip: You can manage all configured accounts under Settings → Online Provider Sync. Each account can have independent toggles for live contact sync and cloud backup.';

  @override
  String get helpPersonalizationTitle1 => 'Look, sound & region';

  @override
  String get helpPersonalizationIntro =>
      'Almost everything about how the app looks, what it sounds like, and how it reads phone numbers can be changed. Here is where each setting lives.';

  @override
  String get helpPersonalizationTitle2 => 'Theme and colour';

  @override
  String get helpPersonalizationBullet1 =>
      'Settings → Appearance → Theme Mode: Light, Dark, or System. System follows your phone\'s own dark-mode setting.';

  @override
  String get helpPersonalizationBullet2 =>
      'Settings → Appearance → Accent Color: pick a preset or build your own colour. The preview updates as you choose.';

  @override
  String get helpPersonalizationTitle3 => 'Font and text size';

  @override
  String get helpPersonalizationBullet3 =>
      'Settings → Appearance → Typography & Text Size sets the font and how large text is drawn.';

  @override
  String get helpPersonalizationBullet4 =>
      'Three Malayalam-capable fonts are built in — Manjari, Anek Malayalam, and Noto Sans Malayalam. Each covers Malayalam and English, so names in either script stay readable.';

  @override
  String get helpPersonalizationBullet5 =>
      'The fonts ship inside the app. Nothing is downloaded, and this works with no internet.';

  @override
  String get helpPersonalizationTitle4 => 'How the contact list reads';

  @override
  String get helpPersonalizationBullet6 =>
      'Settings → Contacts → Display & formatting sets the sort order (by first name or last name).';

  @override
  String get helpPersonalizationBullet7 =>
      'The same screen can hide contacts that have no phone number, which tidies a list imported from an email account.';

  @override
  String get helpPersonalizationTitle5 => 'Ringtones, volume and vibration';

  @override
  String get helpPersonalizationBullet8 =>
      'Settings → Ringtone → Volume & vibration sets the ringtone volume and whether incoming calls vibrate.';

  @override
  String get helpPersonalizationBullet9 =>
      'Settings → Ringtone → Per-SIM ringtones gives SIM 1 and SIM 2 different tones, so you know which line is ringing.';

  @override
  String get helpPersonalizationBullet10 =>
      'A group can carry its own ringtone, and any contact can be given one while editing them.';

  @override
  String get helpPersonalizationBullet11 =>
      'When several apply, the most specific wins: the contact\'s own tone first, then their group\'s, then the SIM\'s.';

  @override
  String get helpPersonalizationBullet12 =>
      'Ringtones are not included in backups or in a sync to another phone, because they point at a sound file on this phone.';

  @override
  String get helpPersonalizationTitle6 => 'Default country';

  @override
  String get helpPersonalizationBullet13 =>
      'Settings → Default country tells the app which country your plain, un-prefixed numbers belong to.';

  @override
  String get helpPersonalizationBullet14 =>
      'It is what lets the app see that a call from +91 98765 43210 is the same person as the 98765 43210 saved in your contacts.';

  @override
  String get helpPersonalizationBullet15 =>
      'Blocked numbers are matched the same way, so a number blocked in local form still blocks the international form.';

  @override
  String get helpPersonalizationBullet16 =>
      'Getting this wrong is the usual reason a saved contact shows up as an unknown caller.';

  @override
  String get helpPersonalizationFooter =>
      'Tip: theme, accent colour, fonts and the default country travel to another phone on a sync. Ringtones and SIM choices stay behind, because they belong to this handset.';

  @override
  String get helpCallerIdSpamTitle1 => 'Caller ID & spam filter';

  @override
  String get helpCallerIdSpamIntro =>
      'When a number that is not in your contacts calls, the app tries to say something useful about it, and can make a suspected spam call ring quietly instead of loudly. Both are switches you control, and both work entirely on this phone.';

  @override
  String get helpCallerIdSpamTitle2 => 'Caller identification';

  @override
  String get helpCallerIdSpamBullet1 =>
      'Turn it on under Settings → SIM & calling → Identification → \"Caller identification\".';

  @override
  String get helpCallerIdSpamBullet2 =>
      'An unknown caller gets a label built from what can be worked out locally: the telemarketing and service number series, numbers you yourself marked as spam, and the network\'s own verified-caller flag when it sends one.';

  @override
  String get helpCallerIdSpamBullet3 =>
      'The badge appears on the call screen — red for suspected spam, a softer colour for a telemarketing or service number.';

  @override
  String get helpCallerIdSpamBullet4 =>
      'No number is ever looked up on the internet. There is no caller ID database behind this and nothing is uploaded.';

  @override
  String get helpCallerIdSpamTitle3 => 'Filter suspected spam';

  @override
  String get helpCallerIdSpamBullet5 =>
      'The second switch on the same screen, \"Filter suspected spam\", makes flagged callers ring silently instead of loudly.';

  @override
  String get helpCallerIdSpamBullet6 =>
      'The call still comes through and still lands in Recents. You are simply not disturbed by it.';

  @override
  String get helpCallerIdSpamBullet7 =>
      'Use this when you want to see who called but not be interrupted. Use blocking when you do not want the call at all.';

  @override
  String get helpCallerIdSpamTitle4 => 'Block unknown';

  @override
  String get helpCallerIdSpamBullet8 =>
      'Settings → Contacts → Blocked numbers has a \"Block unknown\" switch for calls that arrive with no number or a hidden one.';

  @override
  String get helpCallerIdSpamBullet9 =>
      'With it on, those calls are rejected before your phone rings, and are still written into Recents as blocked so you can see that they happened.';

  @override
  String get helpCallerIdSpamBullet10 =>
      'It does not affect a number you simply have not saved — only calls with no caller number at all.';

  @override
  String get helpCallerIdSpamTitle5 => 'Marking a number as spam';

  @override
  String get helpCallerIdSpamBullet11 =>
      'Long-press a call in Recents and choose \"Mark as spam\". The same action reads \"Not spam\" afterwards, so you can take the mark off again.';

  @override
  String get helpCallerIdSpamBullet12 =>
      'A spam mark is separate from blocking. The number can still ring you — it is now labelled, and the spam filter can silence it if that switch is on.';

  @override
  String get helpCallerIdSpamBullet13 =>
      'Your own marks feed the caller identification label, so the next call from that number is recognised.';

  @override
  String get helpCallerIdSpamFooter =>
      'Tip: identification and spam filtering both need the app to be your default phone app, because Android only lets the default dialer inspect a call before it rings.';

  @override
  String get helpImportExportTitle1 => 'Import & export files';

  @override
  String get helpImportExportIntro =>
      'You can move contacts in and out of the app as ordinary files — a spreadsheet-friendly CSV, or a vCard (.vcf) that any phone or computer address book understands.';

  @override
  String get helpImportExportTitle2 => 'Where to find it';

  @override
  String get helpImportExportBullet1 =>
      'Open the Contacts tab, tap the three-dot menu in the top bar, and choose \"Import / Export\".';

  @override
  String get helpImportExportBullet2 =>
      'Four choices appear: Import CSV, Export CSV, Import vCard (.vcf), and Export vCard (.vcf).';

  @override
  String get helpImportExportTitle3 => 'Importing';

  @override
  String get helpImportExportBullet3 =>
      'You pick the file yourself through the system file picker. The app never browses your storage on its own.';

  @override
  String get helpImportExportBullet4 =>
      'Imported contacts are added to the app. When the import finishes you are told how many came in.';

  @override
  String get helpImportExportBullet5 =>
      'If the file brings in people you already have, run Contacts → menu → \"Find Duplicates\" afterwards to tidy up.';

  @override
  String get helpImportExportTitle4 => 'Exporting';

  @override
  String get helpImportExportBullet6 =>
      'An export writes a file and then opens the system share sheet, so you decide where it goes.';

  @override
  String get helpImportExportBullet7 =>
      'An export file is plain and not password-protected. Treat it like a copy of your address book and delete it when you are done.';

  @override
  String get helpImportExportBullet8 =>
      'Secret contacts are left out of a normal export unless you turn on \"Include secret contacts in export\" under Settings → Contacts → Secret contacts & export.';

  @override
  String get helpImportExportBullet9 =>
      'That same screen has \"Export secret contacts\", which saves a separate file holding only the secret ones. It asks for your fingerprint, face, or PIN first.';

  @override
  String get helpImportExportBullet10 =>
      'For a full, password-locked copy of everything — call history, photos, settings and all — use Settings → Backup & Restore instead.';

  @override
  String get helpImportExportTitle5 =>
      'AirQR: sending more than one QR code can hold';

  @override
  String get helpImportExportBullet11 =>
      'A single QR code cannot hold a photo or a long contact card. AirQR splits the data across many frames and plays them as an animated QR code.';

  @override
  String get helpImportExportBullet12 =>
      'Open a contact, choose \"Share as QR code\", then tap the Air-Gap Stream button in that dialog to start the animation.';

  @override
  String get helpImportExportBullet13 =>
      'On the other phone, open Contacts → menu → \"Scan QR code\" and point the camera at the animation. It shows the progress while the frames come in and saves the contact once they are all there.';

  @override
  String get helpImportExportBullet14 =>
      'Nothing is sent over Bluetooth, Wi-Fi or the internet — the only path is the camera looking at the screen. Keep both phones steady until it completes.';

  @override
  String get helpImportExportFooter =>
      'Tip: vCard (.vcf) is the safer choice for moving to another phone, because it keeps multiple numbers, emails and photos. CSV is best when you want to open the list in a spreadsheet.';

  @override
  String get helpPrivacySecurityText => 'Privacy, Security & Vault';

  @override
  String get helpPrivacySecurityIntro =>
      'SreerajP Contacts Sphere is built from the ground up to guarantee uncompromising privacy, encrypted local storage, and granular security controls.';

  @override
  String get helpPrivacySecurityTitle1 => 'Secret Contacts Vault';

  @override
  String get helpPrivacySecurityBullet1 =>
      'What is a Secret Contact? Any contact marked as \"Secret\" is completely hidden from the main contact list, T9 dialer searches, and general export files.';

  @override
  String get helpPrivacySecurityBullet2 =>
      'Seeing them: tap the padlock icon in the top bar of the Contacts tab and unlock with your fingerprint, face, or device PIN. The list then shows the secret contacts alongside the rest.';

  @override
  String get helpPrivacySecurityBullet3 =>
      'Tap the padlock again to hide them. They also hide when you leave the contact list, so they are never left showing behind you.';

  @override
  String get helpPrivacySecurityTitle2 => 'Biometrics & App PIN Protection';

  @override
  String get helpPrivacySecurityBullet4 =>
      'You can secure the entire app or sensitive sections using your device\'s biometric sensors (fingerprint / face unlock).';

  @override
  String get helpPrivacySecurityBullet5 =>
      'If your phone has no biometric hardware, or you want a code separate from your phone PIN, set an App PIN under Settings → Security → App lock. See the \"App lock & PIN\" guide.';

  @override
  String get helpPrivacySecurityTitle3 => 'Screenshot Guard';

  @override
  String get helpPrivacySecurityBullet6 =>
      'Screenshot guard blocks screenshots, screen recording, and the preview Android shows in Recents, while you are on a screen holding private data.';

  @override
  String get helpPrivacySecurityBullet7 =>
      'Turn it on or off under Settings → Security → Screenshot guard.';

  @override
  String get helpPrivacySecurityTitle4 => 'Security Audit Log';

  @override
  String get helpPrivacySecurityBullet8 =>
      'The audit log records every change to a contact — created, edited, or deleted — with what it looked like before and after.';

  @override
  String get helpPrivacySecurityBullet9 =>
      'Open an entry to see exactly what changed, and undo it if the change was a mistake.';

  @override
  String get helpPrivacySecurityBullet10 =>
      'Entries are chained together with a cryptographic hash, so an entry cannot be quietly altered or removed without it showing.';

  @override
  String get helpPrivacySecurityBullet11 =>
      'Settings → Security → Audit log, which asks for your unlock first. It can also export a signed copy of the log.';

  @override
  String get helpPrivacySecurityFooter =>
      'Security principle: everything is stored on this phone in a database encrypted with a key held in the phone\'s hardware keystore. There is no tracking, no advertising, and no server of ours to talk to.';

  @override
  String get helpContactSharingText => 'Sharing & Card Scanning';

  @override
  String get helpContactSharingIntro =>
      'Quickly exchange contact information using modern digital QR codes, on-device business card OCR camera scanning, and offline Bluetooth LE.';

  @override
  String get helpContactSharingTitle1 => 'QR Code Sharing & Scanner';

  @override
  String get helpContactSharingBullet1 =>
      'Show a QR code: open a contact, tap Share, and choose \"Share as QR code\". A standard vCard QR appears on screen for someone else to scan.';

  @override
  String get helpContactSharingBullet2 =>
      'Scan a QR code: open the Contacts tab, tap the three-dot menu, and choose \"Scan QR code\" to open the camera.';

  @override
  String get helpContactSharingBullet3 =>
      'What was scanned is shown to you first. You save it as a new contact only after looking at it.';

  @override
  String get helpContactSharingTitle2 => 'Business Card Scanner (On-Device AI)';

  @override
  String get helpContactSharingBullet4 =>
      'Photograph any paper business card with your phone\'s camera.';

  @override
  String get helpContactSharingBullet5 =>
      'ContactSphere\'s optical character recognition (OCR) scans the image in seconds to extract names, phone numbers, emails, addresses, and company titles.';

  @override
  String get helpContactSharingBullet6 =>
      'You can review, edit, or untick any field before saving to your address book.';

  @override
  String get helpContactSharingBullet7 =>
      '100% On-Device Privacy: The card photo is processed locally on your phone and is never uploaded to any cloud server.';

  @override
  String get helpContactSharingTitle3 => 'Offline Bluetooth LE Share';

  @override
  String get helpContactSharingBullet8 =>
      'Share contacts directly with nearby Android devices running ContactSphere without internet or pairing codes.';

  @override
  String get helpContactSharingBullet9 =>
      'The sender opens a contact, taps Share, and chooses \"Share via Bluetooth\". The receiver opens the Contacts tab, taps the three-dot menu, and chooses \"Bluetooth transfer\".';

  @override
  String get helpContactSharingBullet10 =>
      'The receiving phone shows a challenge you must confirm, so a contact cannot be pushed onto your phone without you agreeing.';

  @override
  String get helpContactSharingBullet11 =>
      'Devices automatically discover each other and transfer the contact securely over low-energy radio.';

  @override
  String get helpContactSharingFooter =>
      'Tip: every sharing method here uses the standard vCard format, which Android, iOS and desktop address books all understand. To send a whole address book as a file instead, see the Import & export guide.';

  @override
  String get helpDuplicateMergeText => 'Duplicate Contacts & Merge';

  @override
  String get helpDuplicateMergeIntro =>
      'Keep your address book clean and clutter-free with ContactSphere\'s intelligent duplicate detection and safe one-tap merging system.';

  @override
  String get helpDuplicateMergeTitle1 => 'How Duplicates are Detected';

  @override
  String get helpDuplicateMergeBullet1 =>
      'Same phone number: two contacts share the same digits, or the same number once it is put into full international form.';

  @override
  String get helpDuplicateMergeBullet2 =>
      'Same name: two contacts have the same full name, or the same name once it is transliterated — so \"Anil\" and \"അനിൽ\" are seen as one person.';

  @override
  String get helpDuplicateMergeBullet3 =>
      'Matching spreads across a set: if A matches B and B matches C, all three are shown together as one set.';

  @override
  String get helpDuplicateMergeBullet4 =>
      'Email addresses are deliberately not used, and neither are sound-alike name codes. Both produced wrong merges between unrelated people.';

  @override
  String get helpDuplicateMergeTitle2 => 'Smart Merging Process';

  @override
  String get helpDuplicateMergeBullet5 =>
      'Open the Contacts tab, tap the three-dot menu, and choose \"Find Duplicates\".';

  @override
  String get helpDuplicateMergeBullet6 =>
      'Each set is shown as one card. The contact that will be kept is at the top; the others are ticked to be merged into it.';

  @override
  String get helpDuplicateMergeBullet7 =>
      'Untick anyone who does not belong in the set, or tap a different row to keep that one instead.';

  @override
  String get helpDuplicateMergeBullet8 =>
      'All the different phone numbers, emails, addresses, birthdays and notes from the set are carried over into the contact you keep. Nothing is thrown away.';

  @override
  String get helpDuplicateMergeBullet9 =>
      'Merge one set with its own Merge button, or use \"Merge all sets\" at the bottom to do the whole list at once.';

  @override
  String get helpDuplicateMergeTitle3 => 'Safety & Reversibility';

  @override
  String get helpDuplicateMergeBullet10 =>
      'Before merging everything at once, make a backup under Settings → Backup & Restore. A merge cannot be undone from the duplicates screen.';

  @override
  String get helpDuplicateMergeBullet11 =>
      'If a merge was wrong, open the kept contact and edit it — the extra numbers and details are all still there, so you can move them back out into a new contact.';

  @override
  String get helpDuplicateMergeFooter =>
      'Tip: run \"Find Duplicates\" after a phonebook sync or a file import — that is when duplicates usually appear.';

  @override
  String get helpContactSyncText => 'Contact Sync';

  @override
  String get helpContactSyncIntro =>
      'Sync keeps the app and your phone in step. You control each direction yourself — nothing here runs automatically. Open it from Settings → Contacts → Device & cloud sync.';

  @override
  String get helpContactSyncTitle1 => 'The two normal actions';

  @override
  String get helpContactSyncBullet1 =>
      'Add device contacts to app: copies the phone\'s address book into the app. It only adds or updates — it never deletes.';

  @override
  String get helpContactSyncBullet2 =>
      'Add app contacts to device: copies your app contacts into the phone. It only adds or updates — it never deletes. Your \"Me\" contact and secret contacts are never sent to the phone.';

  @override
  String get helpContactSyncTitle2 => 'Destructive sync';

  @override
  String get helpContactSyncBullet3 =>
      'The two \"(destructive)\" actions make the target an exact copy of the source. As well as adding and updating, they delete extras — so use them with care. Each one asks you to confirm first.';

  @override
  String get helpContactSyncBullet4 =>
      'Add device contacts to app (destructive): after importing, it deletes app contacts that came from the phone but are no longer on it. It never deletes your \"Me\" contact, your secret contacts, or any contact you created only in the app.';

  @override
  String get helpContactSyncBullet5 =>
      'Add app contacts to device (destructive): after copying, it deletes device contacts that are not in the app. Device contacts that match your \"Me\" contact or a secret contact are never deleted, even though those are never copied to the phone.';

  @override
  String get helpContactSyncTitle3 => 'Call log';

  @override
  String get helpContactSyncBullet6 =>
      'The phone\'s call log syncs into Recents on its own — when the app starts, when you open Recents, and when a call ends. Calls made from another dialer, or while the app was closed, come in this way. You do not have to do anything.';

  @override
  String get helpContactSyncBullet7 =>
      'Add device call log to app: brings in the phone\'s older call history in one go, further back than the automatic sync reaches. It skips calls the app already has, so running it again is safe.';

  @override
  String get helpContactSyncBullet8 =>
      'Add device call log to app (destructive): clears Recents and rebuilds it from the phone\'s call log. Any call notes or feedback you saved in the app are lost.';

  @override
  String get helpContactSyncBullet9 =>
      'There is no \"app to device\" for the call log: Android owns the phone\'s call log and records calls on its own.';

  @override
  String get helpContactSyncFooter =>
      'Tip: a destructive sync cannot be undone. If you are unsure, make a backup first (Settings → Backup & Restore).';

  @override
  String get helpCallScreeningText => 'Call Screening & Blocking';

  @override
  String get helpCallScreeningIntro =>
      'The app can turn a call away before your phone rings. Blocking is a list you build yourself, checked on this phone against the incoming number — nothing is looked up anywhere else.';

  @override
  String get helpCallScreeningTitle1 => 'How call screening works';

  @override
  String get helpCallScreeningBullet1 =>
      'When a call arrives, Android hands the number to the app\'s call screening service before the phone rings.';

  @override
  String get helpCallScreeningBullet2 =>
      'If the number is on your blocked list, the call is rejected straight away — no ring, no vibration, no incoming screen.';

  @override
  String get helpCallScreeningBullet3 =>
      'Numbers are matched after being put into full international form using your Default country, so a number blocked as 98765 43210 also blocks +91 98765 43210.';

  @override
  String get helpCallScreeningBullet4 =>
      'A blocked call is still written into Recents with a \"Blocked\" mark, so you can see who tried.';

  @override
  String get helpCallScreeningTitle2 => 'Blocking a number';

  @override
  String get helpCallScreeningBullet5 =>
      'From Recents: long-press the call and choose \"Block number\". The same action then reads \"Unblock number\".';

  @override
  String get helpCallScreeningBullet6 =>
      'During a call: tap Block on the call screen. This works while it is ringing and while you are talking.';

  @override
  String get helpCallScreeningBullet7 =>
      'By hand: Settings → Contacts → Blocked numbers, then add the number yourself.';

  @override
  String get helpCallScreeningBullet8 =>
      'Blocking a number that is on a call right now hangs that call up immediately, wherever you blocked it from.';

  @override
  String get helpCallScreeningTitle3 => 'Callers with no number';

  @override
  String get helpCallScreeningBullet9 =>
      'Settings → Contacts → Blocked numbers also has a \"Block unknown\" switch, for calls that arrive with a hidden or withheld number.';

  @override
  String get helpCallScreeningBullet10 =>
      'Those calls are rejected before ringing and still recorded in Recents as blocked.';

  @override
  String get helpCallScreeningBullet11 =>
      'It does not affect ordinary numbers you have not saved — only calls that carry no number at all.';

  @override
  String get helpCallScreeningTitle4 => 'Silencing instead of blocking';

  @override
  String get helpCallScreeningBullet12 =>
      'If you would rather see the call but not be disturbed, use \"Filter suspected spam\" under Settings → SIM & calling → Identification. Flagged callers then ring silently.';

  @override
  String get helpCallScreeningBullet13 =>
      'See the \"Caller ID & spam filter\" guide for how a caller gets flagged.';

  @override
  String get helpCallScreeningTitle5 => 'Default phone app is required';

  @override
  String get helpCallScreeningBullet14 =>
      'Android only lets the default phone app inspect a call before it rings. Without that role, blocking cannot happen early enough.';

  @override
  String get helpCallScreeningBullet15 =>
      'Settings → Permissions shows whether the app already holds the role, and lets you ask for it.';

  @override
  String get helpCallScreeningFooter =>
      'Privacy note: screening happens entirely on this phone, against your own list. No phone number is ever sent to a server, and there is no shared spam database behind it.';

  @override
  String get helpPermissionsTitle1 => 'Permissions explained';

  @override
  String get helpPermissionsIntro =>
      'Settings → Permissions lists everything the app can access, with a live status beside each one. This page explains what each is for, and what stops working if you say no.';

  @override
  String get helpPermissionsTitle2 => 'Two kinds of permission';

  @override
  String get helpPermissionsBullet1 =>
      'Explicit — Android asks you, and you can say no or change your mind later. These are the ones with Granted / Denied beside them.';

  @override
  String get helpPermissionsBullet2 =>
      'Implicit — declared when the app is built and granted by the system at install. There is no prompt, because they cannot reach your personal data on their own.';

  @override
  String get helpPermissionsTitle3 => 'For calling';

  @override
  String get helpPermissionsBullet3 =>
      'Default phone app — makes this the system dialer, so it can show its own in-call screen, full-screen incoming alerts, and screen calls before they ring. Without it, calling works but blocking and screening do not.';

  @override
  String get helpPermissionsBullet4 =>
      'Phone & Call Log — place, answer and manage calls, and read back a call\'s real duration for Recents.';

  @override
  String get helpPermissionsBullet5 =>
      'Foreground Call Service & Ringing — keeps a call alive and lets the app ring and show the incoming-call screen.';

  @override
  String get helpPermissionsBullet6 =>
      'Screen off near ear — blanks the screen while the phone is against your ear so your cheek does not press buttons.';

  @override
  String get helpPermissionsTitle4 => 'For your contacts';

  @override
  String get helpPermissionsBullet7 =>
      'Contacts — read and sync your phone\'s address book. Without it, the app keeps its own contacts but cannot see or update the phone\'s.';

  @override
  String get helpPermissionsBullet8 =>
      'Photos & Media — pick a profile photo from your gallery.';

  @override
  String get helpPermissionsBullet9 =>
      'Camera — take a contact photo, scan a QR code, or scan a paper business card.';

  @override
  String get helpPermissionsBullet10 =>
      'Microphone — dictate a call note instead of typing it.';

  @override
  String get helpPermissionsBullet11 =>
      'Location — tag a contact with a place, and needed by Android for Bluetooth scanning on older versions.';

  @override
  String get helpPermissionsTitle5 => 'For reminders and the emergency card';

  @override
  String get helpPermissionsBullet12 =>
      'Notifications — show reminders for birthdays, follow-ups and missed calls, and carry the emergency info card on your lock screen.';

  @override
  String get helpPermissionsBullet13 =>
      'Alarms & reminders — lets Smart Redial call back at the time you set even when the app is closed.';

  @override
  String get helpPermissionsBullet14 =>
      'Start after restart — puts your emergency info card back on the lock screen after the phone reboots.';

  @override
  String get helpPermissionsTitle6 => 'For sharing and sync';

  @override
  String get helpPermissionsBullet15 =>
      'Bluetooth Scan, Connect and Advertise — find a nearby phone, connect to it, and be findable while sharing a contact over Bluetooth.';

  @override
  String get helpPermissionsBullet16 =>
      'Internet & Wi-Fi — used only to copy your data to another phone across your own local Wi-Fi during device sync. No cloud server is contacted unless you set up online sync or cloud backup yourself.';

  @override
  String get helpPermissionsBullet17 =>
      'Biometrics — unlock secret contacts, and confirm before you export or sync data that may include them.';

  @override
  String get helpPermissionsTitle7 => 'Saying no, and changing your mind';

  @override
  String get helpPermissionsBullet18 =>
      'Every permission is asked for only when you first use the feature that needs it. Nothing is requested at install.';

  @override
  String get helpPermissionsBullet19 =>
      'Refusing one disables just that feature. The rest of the app keeps working.';

  @override
  String get helpPermissionsBullet20 =>
      'A permission you denied twice shows as \"Blocked\". Android will not ask again — use the settings button in the top bar of the Permissions screen to change it by hand.';

  @override
  String get helpPermissionsFooter =>
      'The app has no advertising or analytics code and contacts no server of ours. Anything that leaves the phone leaves because you set up a sync, a share, or a cloud backup.';

  @override
  String get helpEmergencyInfoText => 'Emergency info';

  @override
  String get helpEmergencyInfoIntro =>
      'The emergency card holds a few facts that could help someone who finds you unwell — your blood group, your allergies, and who to call. It can be read on your lock screen without your PIN.';

  @override
  String get helpEmergencyInfoTitle1 => 'What \"without unlocking\" means';

  @override
  String get helpEmergencyInfoBullet1 =>
      'While the card is on, a notification called \"Emergency info\" sits on your lock screen. Tapping it opens the card straight away — no PIN, fingerprint, or face needed.';

  @override
  String get helpEmergencyInfoBullet2 =>
      'The phone stays locked. Only the card opens; the rest of the app, and everything else on the phone, stays shut.';

  @override
  String get helpEmergencyInfoBullet3 =>
      'Android keeps its own \"Emergency information\" page behind the lock screen Emergency button. That page belongs to the phone maker, and no app can write into it — which is why SreerajP Contacts Sphere uses its own notification instead.';

  @override
  String get helpEmergencyInfoTitle2 => 'You choose every line';

  @override
  String get helpEmergencyInfoBullet4 =>
      'The whole feature is off until you switch it on.';

  @override
  String get helpEmergencyInfoBullet5 =>
      'Each field has its own \"Show on lock screen\" switch. A field you leave switched off never leaves the app.';

  @override
  String get helpEmergencyInfoBullet6 =>
      'The preview at the bottom of the edit screen shows exactly what a stranger would see.';

  @override
  String get helpEmergencyInfoBullet7 =>
      'Switching the card off removes the notification and wipes the copy the lock screen was reading. What you typed stays saved inside the app.';

  @override
  String get helpEmergencyInfoTitle3 => 'Calling for help';

  @override
  String get helpEmergencyInfoBullet8 =>
      'Each person you add gets a Call button on the card. Tapping it dials them right away from the lock screen.';

  @override
  String get helpEmergencyInfoBullet9 =>
      'People picked from your contacts are copied onto the card as a name and one number. Editing that contact later does not change the card — open this screen and save again.';

  @override
  String get helpEmergencyInfoTitle4 =>
      'If the card is missing from the lock screen';

  @override
  String get helpEmergencyInfoBullet10 =>
      'Your phone decides which notifications the lock screen shows. Open Settings → Notifications → Notifications on lock screen and pick \"Show conversations, default and silent\".';

  @override
  String get helpEmergencyInfoBullet11 =>
      'If that is set to \"Hide silent notifications\" or \"Don\'t show any notifications\", the card cannot appear there. No app can override that choice.';

  @override
  String get helpEmergencyInfoBullet12 =>
      'Also check that notifications for SreerajP Contacts Sphere are on, and that the \"Emergency info\" notification is not turned down to silent. The edit screen warns you when either is the case, and the button there opens the right settings page.';

  @override
  String get helpEmergencyInfoBullet13 =>
      'The card stays in the notification shade all the time on purpose — it is meant to be one tap away, and it cannot be swiped off by accident.';

  @override
  String get helpEmergencyInfoTitle5 => 'How it is stored';

  @override
  String get helpEmergencyInfoBullet14 =>
      'Your full record stays in the app\'s encrypted database, like the rest of your contacts.';

  @override
  String get helpEmergencyInfoBullet15 =>
      'Only the lines you switched on are copied into a small, plain file that the lock-screen card can read while the phone is locked. That copy cannot be encrypted — a locked phone has no way to unlock it for a stranger.';

  @override
  String get helpEmergencyInfoBullet16 =>
      'The copy stays inside the app\'s private storage. Other apps cannot read it, and it is left out of phone backups.';

  @override
  String get helpEmergencyInfoBullet17 =>
      'The card is saved inside a password-protected SreerajP Contacts Sphere backup, so a restore on a new phone brings it back.';

  @override
  String get helpEmergencyInfoBullet18 =>
      'It also travels on a Full Sync to another phone, or when you tick \"Emergency info card\" while choosing what to share. The other phone only takes it if it has no card of its own — your card never replaces someone else\'s.';

  @override
  String get helpEmergencyInfoFooter =>
      'Tip: keep it short. Blood group, serious allergies, and one or two people to call are worth far more to a helper than a long medical history.';

  @override
  String get descCatImmediateFamily =>
      'The people you live with or grew up with.';

  @override
  String get descCatExtendedFamily =>
      'Blood relatives outside your immediate family.';

  @override
  String get descCatFamilyByMarriage => 'In-laws and step relatives.';

  @override
  String get descCatProfessional => 'People you work with or do business with.';

  @override
  String get descCatEducational => 'People from school, college or training.';

  @override
  String get descCatSocial => 'Friends, neighbours and other links.';

  @override
  String get descCatService => 'People whose services you use.';

  @override
  String helpRelationshipCategoriesExample(
    String description,
    String examples,
  ) {
    return '$description e.g. $examples.';
  }

  @override
  String get helpCallManagementText => 'Calling & In-Call Controls';

  @override
  String get helpCallManagementIntro =>
      'SreerajP Contacts Sphere provides an intelligent calling experience with multi-party controls, dual-SIM management, automatic redial assistance, and spoken caller announcements.';

  @override
  String get helpCallManagementTitle1 =>
      'In-Call Controls & Conference Calling';

  @override
  String get helpCallManagementBullet1 =>
      'Mute & Speaker: Tap Mute to silence your microphone, or Speaker for loud hands-free audio.';

  @override
  String get helpCallManagementBullet2 =>
      'Hold & Keypad: Put active calls on hold or open the dialpad to enter IVR menu digits (like pressing 1 for English).';

  @override
  String get helpCallManagementBullet3 =>
      'Add Call & Call Swap: Add a second participant while keeping the first call on hold. Tap Swap to switch between active callers.';

  @override
  String get helpCallManagementBullet4 =>
      'Conference Merge: Tap Merge to combine both calls into one conference call. Merge only appears when your network supports conference calls. Tap Manage to see who is on the call, drop one person, or talk to one person in private.';

  @override
  String get helpCallManagementTitle2 => 'Speed Dial';

  @override
  String get helpCallManagementBullet5 =>
      'Keypad keys 1 to 9 can each hold one person. Hold a key on the dialer to call them.';

  @override
  String get helpCallManagementBullet6 =>
      'Holding only works when the number box is empty, so a long press while you are typing never starts a call.';

  @override
  String get helpCallManagementBullet7 =>
      'To set a key: hold an empty key on the dialer and pick a contact, or go to Settings → Speed Dial. If the contact has more than one number you are asked which one to save.';

  @override
  String get helpCallManagementBullet8 =>
      'A key that holds someone shows a small coloured dot above the digit.';

  @override
  String get helpCallManagementBullet9 =>
      'Secret contacts cannot be put on a key, and a key is freed automatically if you delete its contact or make it secret.';

  @override
  String get helpCallManagementTitle3 => 'Dual-SIM Calling & Preferences';

  @override
  String get helpCallManagementBullet10 =>
      'On dual-SIM phones, the dialer gives you SIM 1 and SIM 2 call buttons for immediate selection.';

  @override
  String get helpCallManagementBullet11 =>
      'Settings → SIM & calling → SIM Cards & Accounts sets the default SIM for outgoing calls, or switches on \"Ask before each call\" so you are asked every time.';

  @override
  String get helpCallManagementBullet12 =>
      'One person can have their own SIM: open the contact, tap Edit, and choose it under \"Preferred SIM\". Calls to them then use that SIM instead of the default one.';

  @override
  String get helpCallManagementBullet13 =>
      'With \"Ask before each call\" switched on you are still asked, but the SIM that call would have used is already ticked, so it is one tap.';

  @override
  String get helpCallManagementBullet14 =>
      'If that SIM is later removed from the phone, calls quietly fall back to your default SIM.';

  @override
  String get helpCallManagementBullet15 =>
      'The same screen gives each SIM its own colour, so you can tell at a glance which line a call is on.';

  @override
  String get helpCallManagementBullet16 =>
      'Recents shows which SIM was used for each incoming, outgoing, or missed call.';

  @override
  String get helpCallManagementTitle4 => 'Smart Redial & \"Reach Me\" SMS';

  @override
  String get helpCallManagementBullet17 =>
      'When an outgoing call is busy or unanswered, the app offers to redial the number for you after a delay.';

  @override
  String get helpCallManagementBullet18 =>
      'You can instead send a preset \"Reach Me\" text in one tap, to say you tried to get through.';

  @override
  String get helpCallManagementBullet19 =>
      'Settings → SIM & calling → Smart Redial & \"Reach Me\" sets the default retry delay and the preset message, and lists the redials that are waiting to run.';

  @override
  String get helpCallManagementBullet20 =>
      'A scheduled redial is the one place the app dials on its own, and only because you set the delay yourself. Cancel a waiting redial from that same list.';

  @override
  String get helpCallManagementTitle5 => 'Spoken Caller Announcements';

  @override
  String get helpCallManagementBullet21 =>
      'Turn it on under Settings → SIM & calling → Spoken caller announcement. The app then says the caller\'s name over the ringtone — \"Amma calling\".';

  @override
  String get helpCallManagementBullet22 =>
      'A Malayalam name is announced in Malayalam. Use the Test button on that screen to hear how a name sounds before a real call arrives.';

  @override
  String get helpCallManagementBullet23 =>
      'Switch on the quiet-hours exception, and set its time range, to stay silent at night while the phone still rings.';

  @override
  String get helpCallManagementTitle6 => 'Quick SMS Decline Replies';

  @override
  String get helpCallManagementBullet24 =>
      'Cannot answer right now? Tap Reply on the incoming call screen to decline the call and send a preset text instead.';

  @override
  String get helpCallManagementBullet25 =>
      'Write your own messages under Settings → SIM & calling → Quick replies.';

  @override
  String get helpCallManagementFooter =>
      'Tip: make this your Default Phone App — Settings → Permissions shows whether it already is. Without that role, Android does not hand over the in-call controls or the full-screen incoming alert.';

  @override
  String get helpRelationshipCategoriesText1 => 'Relationship categories';

  @override
  String get helpRelationshipCategoriesIntro =>
      'Every relationship you save has two parts: a category and a label. The category is one of seven fixed buckets. The label is whatever you want to call it — \"Father\", \"Cousin Brother\", \"Manager\".';

  @override
  String get helpRelationshipCategoriesTitle1 => 'Why categories exist';

  @override
  String get helpRelationshipCategoriesBullet1 =>
      'The sphere used to draw one node for every different label. With twenty or more links it turned into a crowd.';

  @override
  String get helpRelationshipCategoriesBullet2 =>
      'Now the sphere draws at most seven nodes — one per category. The number inside a node is how many contacts sit in it.';

  @override
  String get helpRelationshipCategoriesBullet3 =>
      'Tap a node to see everyone inside it, each with their own label. Nothing is hidden; it is only tidier.';

  @override
  String get helpRelationshipCategoriesTitle2 => 'Adding a relationship';

  @override
  String get helpRelationshipCategoriesBullet4 =>
      'Pick the contact you want to link.';

  @override
  String get helpRelationshipCategoriesBullet5 =>
      'Pick one of the seven categories.';

  @override
  String get helpRelationshipCategoriesBullet6 =>
      'Type the label, or tap one of the suggested chips. The chips are only shortcuts — any wording you like is accepted.';

  @override
  String get helpRelationshipCategoriesTitle3 => 'The seven categories';

  @override
  String get helpRelationshipCategoriesTitle4 => 'Both sides, one category';

  @override
  String get helpRelationshipCategoriesBullet7 =>
      'A link is saved on both contacts. If you save someone as your Father, you show up on their side as their Son or Daughter.';

  @override
  String get helpRelationshipCategoriesBullet8 =>
      'The reverse side keeps the same category, so the pair always sits in the same bucket on both spheres.';

  @override
  String get helpRelationshipCategoriesTitle5 =>
      'Relationships you saved earlier';

  @override
  String get helpRelationshipCategoriesBullet9 =>
      'Old links had no category. On the first launch after this update, each one is sorted by its label — \"Father\" goes to Immediate Family, \"Colleague\" to Professional, and so on.';

  @override
  String get helpRelationshipCategoriesBullet10 =>
      'A label the app does not recognise goes to Social. Nothing is deleted, and you can move any link to another category by tapping it and choosing \"Change\".';

  @override
  String get helpRelationshipCategoriesTitle6 =>
      'Quiet hours use these categories';

  @override
  String get helpRelationshipCategoriesBullet11 =>
      'Settings → SIM & calling → Relationship-tier quiet hours silences calls between the times you set.';

  @override
  String get helpRelationshipCategoriesBullet12 =>
      'It is an allow list, not a block list. Everyone is silenced except the people you add — starred contacts, whole categories such as Immediate Family, a tag, or named individuals.';

  @override
  String get helpRelationshipCategoriesBullet13 =>
      'This is why the category matters: allowing \"Immediate Family\" lets every contact in that bucket ring through, whatever label you gave each one.';

  @override
  String get helpRelationshipCategoriesFooter =>
      'Tip: if you are unsure where someone belongs, pick the category you would look under later. The label carries the detail.';

  @override
  String get helpP2pSyncText => 'Sync to Another Device';

  @override
  String get helpP2pSyncIntro =>
      'Copy your contacts (and more) from one phone to another over the same Wi-Fi network. There is no internet, cloud, or account involved — the two phones talk directly to each other. Both phones must be running this app.';

  @override
  String get helpP2pSyncTitle1 => 'Before you start';

  @override
  String get helpP2pSyncBullet1 => 'Put both phones on the same Wi-Fi network.';

  @override
  String get helpP2pSyncBullet2 =>
      'Make sure both phones run the same version of this app. If the versions do not match, sync stops and asks you to update both phones.';

  @override
  String get helpP2pSyncBullet3 =>
      'On both phones open Settings → Sync to Another Device. It asks for your fingerprint, face, or PIN first, because a sync can include secret contacts.';

  @override
  String get helpP2pSyncBullet4 =>
      'On the phone that is sending, tap \"Send to Another Device\". On the phone that is receiving, tap \"Receive from Another Device\".';

  @override
  String get helpP2pSyncTitle2 => 'How the two phones connect';

  @override
  String get helpP2pSyncBullet5 =>
      'The sending phone shows a pairing code and a QR code.';

  @override
  String get helpP2pSyncBullet6 =>
      'The receiving phone scans that QR code, or you type the pairing code in by hand.';

  @override
  String get helpP2pSyncBullet7 =>
      'The pairing code is only ever shown on screen — it is never sent over the network. The whole transfer is encrypted using that code, so if the wrong code is used the connection simply fails.';

  @override
  String get helpP2pSyncTitle3 => 'Full Sync vs Selective Sync';

  @override
  String get helpP2pSyncBullet8 =>
      'Full Sync sends everything below in one go. The sender\'s app settings replace the receiver\'s, and the sender\'s own profile (\"Self\") card is added to the receiver as a normal contact (it never replaces the receiver\'s own profile).';

  @override
  String get helpP2pSyncBullet9 =>
      'Selective Sync sends only the groups of data you pick. Contacts are always included. Settings only fill in blanks (they never overwrite what the receiver already set), and the sender\'s \"Self\" card is not sent.';

  @override
  String get helpP2pSyncTitle4 => 'What gets synced';

  @override
  String get helpP2pSyncBullet10 =>
      'Contacts and their details: phone numbers, emails, addresses, official details, social links, and tags.';

  @override
  String get helpP2pSyncBullet11 => 'Contact photos and calling-card photos.';

  @override
  String get helpP2pSyncBullet12 =>
      'Call history: call logs, interactions, and reminders.';

  @override
  String get helpP2pSyncBullet13 => 'Groups and who belongs to them.';

  @override
  String get helpP2pSyncBullet14 => 'Relationships between contacts.';

  @override
  String get helpP2pSyncBullet15 => 'Blocked numbers.';

  @override
  String get helpP2pSyncBullet16 =>
      'Your emergency info card — on a Full Sync, or when you tick it while choosing what to share. The receiving phone takes it only if it has no card of its own, so nobody\'s medical details get replaced.';

  @override
  String get helpP2pSyncBullet17 =>
      'App settings that are not tied to a specific phone — such as theme, accent color, default country, quick replies, and call-handling options.';

  @override
  String get helpP2pSyncTitle5 => 'What is never synced';

  @override
  String get helpP2pSyncBullet18 =>
      'Ringtones. A ringtone points at a file on the sending phone, which would not exist on the other phone.';

  @override
  String get helpP2pSyncBullet19 =>
      'SIM-specific settings, such as the default SIM and per-SIM ringtones or colors. These refer to the physical SIM cards in the sending phone.';

  @override
  String get helpP2pSyncTitle6 => 'Nothing on the receiving phone is deleted';

  @override
  String get helpP2pSyncBullet20 =>
      'Sync only adds. The receiving phone keeps all of its own data — nothing is erased or overwritten by the contacts that come in.';

  @override
  String get helpP2pSyncBullet21 =>
      'A contact you already have (same name and at least one shared phone number) is skipped, not duplicated. Only brand-new contacts are added, and their details and call history come across with them.';

  @override
  String get helpP2pSyncBullet22 =>
      'Because an existing contact is skipped, the sender\'s call history for that contact is not merged in — only new contacts bring their history.';

  @override
  String get helpP2pSyncTitle7 => 'Your data stays private';

  @override
  String get helpP2pSyncBullet23 =>
      'The transfer happens directly between the two phones on your local Wi-Fi. Nothing is uploaded to the internet or to any server.';

  @override
  String get helpP2pSyncBullet24 =>
      'Opening sync is protected by your device lock, because the data can include secret contacts.';

  @override
  String get helpP2pSyncFooter =>
      'Tip: keep both phones awake and on the same Wi-Fi until the sync finishes.';

  @override
  String get helpFaqTroubleshootingText => 'FAQs & Troubleshooting';

  @override
  String get helpFaqTroubleshootingIntro =>
      'Find quick answers to common questions about permissions, default dialer setup, privacy, sync options, and troubleshooting steps in ContactSphere.';

  @override
  String get helpFaqTroubleshootingTitle1 => 'General & Permissions';

  @override
  String get helpFaqTroubleshootingQ1 =>
      'Why does ContactSphere need Default Phone App permission?';

  @override
  String get helpFaqTroubleshootingA1 =>
      'Android requires an app to be set as the Default Phone App to show incoming call alerts, enable conference merging/call swap, and automatically screen and block spam calls.';

  @override
  String get helpFaqTroubleshootingQ2 =>
      'Are my contacts uploaded to external servers?';

  @override
  String get helpFaqTroubleshootingA2 =>
      'No. ContactSphere is built with an offline-first architecture. All contacts, call logs, notes, and photos reside in your encrypted local SQLite database. No data is sent to external servers unless you explicitly configure your personal Google Drive / WebDAV cloud backup.';

  @override
  String get helpFaqTroubleshootingQ3 => 'Why are some permissions optional?';

  @override
  String get helpFaqTroubleshootingA3 =>
      'Permissions such as Bluetooth (for nearby sharing), Camera (for QR and business-card scanning), and Microphone (for dictating call notes) are asked for only when you first use that feature. Refusing one disables just that feature. See the \"Permissions explained\" guide for the full list.';

  @override
  String get helpFaqTroubleshootingTitle2 => 'Dialer & Calling';

  @override
  String get helpFaqTroubleshootingQ4 =>
      'How do I search Malayalam or Devanagari names on T9?';

  @override
  String get helpFaqTroubleshootingA4 =>
      'Press the keys for the consonant group, or type the name as it sounds in English (typing 2-6-4-5 matches both \"Anil\" and \"അനിൽ\"). To change which script the keypad shows, use the \"Dialpad script\" card on the main Settings page.';

  @override
  String get helpFaqTroubleshootingQ5 =>
      'How do I choose which SIM to call from?';

  @override
  String get helpFaqTroubleshootingA5 =>
      'On dual-SIM phones the dialer gives you separate SIM 1 and SIM 2 call buttons. To stop choosing every time, set a default SIM under Settings → SIM & calling → SIM Cards & Accounts, or switch on \"Ask before each call\" there.';

  @override
  String get helpFaqTroubleshootingQ6 =>
      'Why didn\'t a call ring during quiet hours?';

  @override
  String get helpFaqTroubleshootingA6 =>
      'Quiet hours silence everything except the people you allow. Open Settings → SIM & calling → Relationship-tier quiet hours and add whoever should still get through — starred contacts, whole relationship categories, a tag, or named individuals. Anyone not on that list is silenced until the quiet hours end.';

  @override
  String get helpFaqTroubleshootingTitle3 => 'Sync, Cloud & Backups';

  @override
  String get helpFaqTroubleshootingQ7 =>
      'What is the difference between Local Wi-Fi Sync and Cloud Sync?';

  @override
  String get helpFaqTroubleshootingA7 =>
      'Local Wi-Fi sync copies data straight from one phone to another on the same network, with no internet and no account. Online sync and cloud backup use accounts you add yourself — Google, Microsoft, or a CardDAV/WebDAV server — and are off until you set one up.';

  @override
  String get helpFaqTroubleshootingQ8 =>
      'What happens if I forget my Backup password?';

  @override
  String get helpFaqTroubleshootingA8 =>
      'A backup file is encrypted with the password you chose, and the app never stores it. There is no server to ask, so a lost password means the file cannot be opened. Write it down somewhere safe before you need it.';

  @override
  String get helpFaqTroubleshootingQ9 =>
      'Will syncing with my phone contacts delete anything?';

  @override
  String get helpFaqTroubleshootingA9 =>
      'Standard sync merges new and updated contacts safely. Destructive / Mirror sync will warn you explicitly before replacing or removing any contacts.';

  @override
  String get helpFaqTroubleshootingTitle4 => 'Privacy & Secret Contacts';

  @override
  String get helpFaqTroubleshootingQ10 =>
      'How do I restore access if biometric unlock fails?';

  @override
  String get helpFaqTroubleshootingA10 =>
      'The phone\'s own unlock prompt falls back to your screen-lock PIN, pattern, or password. If you use an App PIN instead and have forgotten it, tap \"Forgot PIN?\" on the lock screen and enter the recovery code you were given when you set it up.';

  @override
  String get helpFaqTroubleshootingQ11 =>
      'Why does the screen go black when switching apps?';

  @override
  String get helpFaqTroubleshootingA11 =>
      'Screenshot Guard protects sensitive views from being captured in Android\'s recent apps preview or by background recording tools.';

  @override
  String get helpFaqTroubleshootingTitle5 => 'Troubleshooting & Maintenance';

  @override
  String get helpFaqTroubleshootingQ12 =>
      'Search is slow or not finding new contacts. How to fix?';

  @override
  String get helpFaqTroubleshootingA12 =>
      'Open Settings → Contacts → Contact counts & search index. If any contacts have stale search keys, a Rebuild button appears — tap it and the keys are rebuilt in a few seconds.';

  @override
  String get helpFaqTroubleshootingQ13 =>
      'A blocked number still shows in Recents. Is it ringing?';

  @override
  String get helpFaqTroubleshootingA13 =>
      'No. A blocked call is rejected before your phone rings, but it is still written into Recents with a \"Blocked\" mark so you can see that someone tried. If you would rather see the call and just not be disturbed, use \"Filter suspected spam\" instead of blocking.';

  @override
  String get helpFaqTroubleshootingQ14 => 'A contact vanished on its own. Why?';

  @override
  String get helpFaqTroubleshootingA14 =>
      'It was probably saved as an ephemeral (temporary) contact, which deletes itself after 2 hours, 24 hours, 7 days, or one call. Opening such a contact shows a countdown banner with a \"Keep Permanently\" button.';

  @override
  String get helpFaqTroubleshootingQ15 => 'Where are groups and tags?';

  @override
  String get helpFaqTroubleshootingA15 =>
      'Groups are behind the group icon in the top bar of the Contacts tab. Tags have their own tab at the bottom of the app, drawn as a cloud where a tag used by more people appears larger.';

  @override
  String get helpFaqTroubleshootingQ16 =>
      'How do I clean up duplicate contacts?';

  @override
  String get helpFaqTroubleshootingA16 =>
      'Open the Contacts tab, tap the three-dot menu, and choose \"Find Duplicates\". Matching is by phone number and by name (including transliterated names). Review each set, then merge it, or use \"Merge all sets\".';

  @override
  String get helpFaqTroubleshootingFooter =>
      'Still stuck? Open the matching guide in Help, or check Settings → Permissions to see whether the feature is simply missing a permission.';

  @override
  String get aboutDetailAuthor => 'Author';

  @override
  String get aboutDetailEmail => 'Email';

  @override
  String get aboutDetailLicense => 'License';

  @override
  String get aboutDetailAiUsed => 'AI used';

  @override
  String get aboutDetailIdeUsed => 'IDE used';

  @override
  String get labelVersion => 'Version';

  @override
  String get labelBuildDate => 'Build Date';

  @override
  String labelVersionBuild(String version, String build) {
    return '$version (build $build)';
  }

  @override
  String get tabDetails => 'Details';

  @override
  String get tabHistory => 'History';

  @override
  String get tabAddContact => 'Add contact';

  @override
  String get emptyNoCallsWithContact => 'No calls with this contact yet.';

  @override
  String get emptyNoCallsWithNumber => 'No calls with this number yet.';

  @override
  String get tooltipCheckAgain => 'Check again';

  @override
  String get tooltipCreateGroup => 'Create group';

  @override
  String get tooltipCentreSphere => 'Centre sphere here';

  @override
  String get tooltipOpenProfile => 'Open profile';

  @override
  String get tooltipCancelRedial => 'Cancel redial';

  @override
  String get tooltipScanAgain => 'Scan again';

  @override
  String get tooltipShowPassword => 'Show password';

  @override
  String get tooltipHidePassword => 'Hide password';

  @override
  String get tooltipRemoveAccount => 'Remove account';
}
