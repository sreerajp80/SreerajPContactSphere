// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get actionCancel => 'റദ്ദാക്കുക';

  @override
  String get actionBlock => 'തടയുക';

  @override
  String get titleBlockedNumbers => 'തടഞ്ഞ നമ്പറുകൾ';

  @override
  String get titleBlockNumber => 'നമ്പർ തടയുക';

  @override
  String get labelPhoneNumber => 'ഫോൺ നമ്പർ';

  @override
  String get hintPhoneNumberExample => 'ഉദാ. +91 98765 43210';

  @override
  String get errorNotAPhoneNumber => 'ഇത് ഒരു നമ്പർ പോലെ തോന്നുന്നില്ല';

  @override
  String msgNumberUnblocked(String number) {
    return '$number എന്ന നമ്പറിന്റെ തടയൽ നീക്കി';
  }

  @override
  String get labelBlockUnknownCallers => 'അജ്ഞാത ഫോൺ വിളികൾ തടയുക';

  @override
  String get descBlockUnknownCallers =>
      'നമ്പർ കാണിക്കാത്ത (മറച്ചുവെച്ചതോ സ്വകാര്യമോ ആയ) ഫോൺ വിളികൾ നിരസിക്കുക';

  @override
  String get descBlockedNumbersInfo =>
      'തടഞ്ഞ നമ്പറുകൾ ഒരിക്കലും റിംഗ് ചെയ്യില്ല. SreerajP Contacts Sphere നിങ്ങളുടെ സ്വതേയുള്ള ഫോൺ ആപ്പ് ആയിരിക്കുമ്പോഴും നമ്പർ കൃത്യമായി യോജിക്കുമ്പോഴും മാത്രമേ തടയൽ പ്രവർത്തിക്കൂ.';

  @override
  String get actionAddNumber => 'നമ്പർ ചേർക്കുക';

  @override
  String get descAddNumber =>
      'ആ നമ്പറിൽ നിന്നുള്ള ഫോൺ വിളികൾ റിംഗ് ചെയ്യുന്നതിനു മുമ്പ് നിരസിക്കപ്പെടും.';

  @override
  String get emptyBlockedNumbers => 'തടഞ്ഞ നമ്പറുകളൊന്നുമില്ല.';

  @override
  String labelBlockedCount(int count) {
    return 'തടഞ്ഞവ ($count)';
  }

  @override
  String labelBlockedOn(String date) {
    return '$date-ന് തടഞ്ഞു';
  }

  @override
  String get tooltipUnblock => 'തടയൽ നീക്കുക';

  @override
  String get titleLanguage => 'ഭാഷ';

  @override
  String get labelSystemDefault => 'സിസ്റ്റം സ്വതവേ';

  @override
  String get descLanguageSystemDefault =>
      'ഫോണിന്റെ ഭാഷ ഇംഗ്ലീഷ്, മലയാളം അല്ലെങ്കിൽ സംസ്കൃതം ആണെങ്കിൽ അത് ഉപയോഗിക്കുക';

  @override
  String semanticsLanguageSetting(String language) {
    return 'ഭാഷ, ഇപ്പോൾ $language';
  }

  @override
  String get languageNameEn => 'English';

  @override
  String get languageNameMl => 'മലയാളം';

  @override
  String get languageNameSa => 'संस्कृतम्';

  @override
  String get actionSave => 'സൂക്ഷിക്കുക';

  @override
  String get actionDelete => 'ഇല്ലാതാക്കുക';

  @override
  String get actionClose => 'അടയ്ക്കുക';

  @override
  String get actionDone => 'പൂർത്തിയായി';

  @override
  String get actionTryAgain => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get actionSkip => 'ഒഴിവാക്കുക';

  @override
  String get actionContinue => 'തുടരുക';

  @override
  String get actionChange => 'മാറ്റുക';

  @override
  String get navContacts => 'വിലാസവിവരങ്ങൾ';

  @override
  String get navDialer => 'ഡയലർ';

  @override
  String get navRecents => 'സമീപകാലം';

  @override
  String get navTags => 'അടയാളങ്ങൾ';

  @override
  String get msgSwipeAgainToExit =>
      'പുറത്തുകടക്കാൻ വീണ്ടും വലത്തോട്ട് സ്വൈപ്പ് ചെയ്യുക';

  @override
  String get tooltipReturnToCall => 'ഫോൺ വിളിയിലേക്ക് മടങ്ങുക';

  @override
  String get msgAddingCallToOngoing =>
      'നിലവിലുള്ള ഫോൺ വിളിയിലേക്ക് മറ്റൊരു ഫോൺ വിളി ചേർക്കുന്നു…';

  @override
  String labelContactCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count വിലാസവിവരങ്ങൾ',
      one: 'ഒരു വിലാസവിവരം',
    );
    return '$_temp0';
  }

  @override
  String msgTagMerged(String tag, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count വിലാസവിവരങ്ങൾ മാറ്റി',
      one: 'ഒരു വിലാസവിവരം മാറ്റി',
    );
    return '#$tag-ലേക്ക് ലയിപ്പിച്ചു ($_temp0)';
  }

  @override
  String msgTagRenamed(String tag) {
    return '#$tag എന്ന് പേരുമാറ്റി';
  }

  @override
  String errorCouldNotRename(String error) {
    return 'പേരുമാറ്റാനായില്ല: $error';
  }

  @override
  String errorCouldNotMerge(String error) {
    return 'ലയിപ്പിക്കാനായില്ല: $error';
  }

  @override
  String errorCouldNotDelete(String error) {
    return 'ഇല്ലാതാക്കാനായില്ല: $error';
  }

  @override
  String titleDeleteTagConfirm(String tag) {
    return '#$tag ഇല്ലാതാക്കണോ?';
  }

  @override
  String get descDeleteUnusedTag =>
      'ഒരു വിലാസവിവരവും ഈ അടയാളം ഉപയോഗിക്കുന്നില്ല, അതിനാൽ മറ്റൊന്നും മാറില്ല.';

  @override
  String get errorTagInUseAgain =>
      'അടയാളം വീണ്ടും ഉപയോഗത്തിലാണ് — ആദ്യം അതിലെ വിലാസവിവരങ്ങൾ നീക്കുക';

  @override
  String msgTagDeleted(String tag) {
    return '#$tag ഇല്ലാതാക്കി';
  }

  @override
  String get actionRenameTag => 'അടയാളത്തിന്റെ പേരുമാറ്റുക';

  @override
  String get actionMergeInto => 'ലയിപ്പിക്കുക…';

  @override
  String get descNoOtherTags => 'ലയിപ്പിക്കാൻ മറ്റ് അടയാളങ്ങളില്ല';

  @override
  String get actionDeleteTag => 'അടയാളം ഇല്ലാതാക്കുക';

  @override
  String descRemoveContactsFirst(int count) {
    return 'ആദ്യം ഇതിലെ വിലാസവിവരങ്ങൾ നീക്കുക ($count)';
  }

  @override
  String titleRenameTag(String tag) {
    return '#$tag പേരുമാറ്റുക';
  }

  @override
  String get labelTagName => 'അടയാളത്തിന്റെ പേര്';

  @override
  String descTagAlreadyExists(String tag) {
    return '#$tag ഇതിനകം നിലവിലുണ്ട്. രണ്ട് അടയാളങ്ങളും ഒന്നാകും.';
  }

  @override
  String actionMergeIntoTag(String tag) {
    return '#$tag-ലേക്ക് ലയിപ്പിക്കുക';
  }

  @override
  String get actionRename => 'പേരുമാറ്റുക';

  @override
  String titleMergeTagInto(String tag) {
    return '#$tag എവിടേക്ക് ലയിപ്പിക്കണം?';
  }

  @override
  String get labelToneGreat => 'നന്നായി';

  @override
  String get labelToneOkay => 'കുഴപ്പമില്ല';

  @override
  String get labelToneRough => 'മോശം';

  @override
  String get labelIntentCatchUp => 'കുശലം';

  @override
  String get labelIntentWork => 'ജോലി';

  @override
  String get labelIntentScheduling => 'സമയക്രമീകരണം';

  @override
  String get labelIntentFollowUp => 'തുടർനടപടി';

  @override
  String get labelIntentFamily => 'കുടുംബം';

  @override
  String get labelIntentUrgent => 'അടിയന്തരം';

  @override
  String get titleHowDidItGo => 'എങ്ങനെയുണ്ടായിരുന്നു?';

  @override
  String labelCallWith(String name) {
    return '$name-മായുള്ള ഫോൺ വിളി';
  }

  @override
  String get labelWhatWasItAbout => 'എന്തിനെക്കുറിച്ചായിരുന്നു?';

  @override
  String get labelNotes => 'കുറിപ്പുകൾ';

  @override
  String get hintAnythingWorthRemembering => 'ഓർത്തിരിക്കേണ്ടതെന്തെങ്കിലും?';

  @override
  String get labelAddFollowUpReminder => 'തുടർ ഓർമ്മപ്പെടുത്തൽ ചേർക്കുക';

  @override
  String get descFollowUpSavedForReference =>
      'ഓർമ്മയ്ക്കായി സൂക്ഷിക്കും — അറിയിപ്പുകൾ ഉടൻ വരും';

  @override
  String get hintFollowUpExample => 'ഉദാ. കരാർ അയയ്ക്കുക';

  @override
  String get hintPickFollowUpTime => 'തീയതിയും സമയവും തിരഞ്ഞെടുക്കുക (ഐച്ഛികം)';

  @override
  String titleSendContacts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count വിലാസവിവരങ്ങൾ അയയ്ക്കുക',
      one: 'ഒരു വിലാസവിവരം അയയ്ക്കുക',
    );
    return '$_temp0';
  }

  @override
  String get errorBluetoothOff =>
      'ബ്ലൂടൂത്ത് ഓഫാണ്. അത് ഓണാക്കി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get errorBleUnsupported => 'ഈ ഫോണിന് Bluetooth LE വഴി പങ്കിടാനാവില്ല.';

  @override
  String get errorBluetoothPermissionDenied => 'ബ്ലൂടൂത്ത് അനുമതി നിഷേധിച്ചു.';

  @override
  String get errorCouldNotStartBleShare =>
      'ബ്ലൂടൂത്ത് പങ്കിടൽ ആരംഭിക്കാനായില്ല.';

  @override
  String get errorBleShareFailed => 'ബ്ലൂടൂത്ത് പങ്കിടൽ പരാജയപ്പെട്ടു.';

  @override
  String get actionReceiveViaBluetooth => 'ബ്ലൂടൂത്ത് വഴി സ്വീകരിക്കുക';

  @override
  String descBleReceiveHowTo(String menuItem) {
    return 'മറ്റേ ഫോണിൽ SreerajP Contacts Sphere തുറന്ന് വിലാസവിവരങ്ങളുടെ മെനുവിൽ നിന്ന് “$menuItem” തിരഞ്ഞെടുക്കുക.';
  }

  @override
  String get labelIncludePhotos => 'ഫോട്ടോകളും ഉൾപ്പെടുത്തുക';

  @override
  String get msgStartingBleShare => 'ബ്ലൂടൂത്ത് പങ്കിടൽ ആരംഭിക്കുന്നു…';

  @override
  String get msgWaitingForNearbyPhone =>
      'അടുത്തുള്ള ഒരു ഫോണിനായി കാത്തിരിക്കുന്നു…';

  @override
  String get msgSending => 'അയയ്ക്കുന്നു…';

  @override
  String msgSendingPercent(int percent) {
    return 'അയയ്ക്കുന്നു… $percent%';
  }

  @override
  String get msgSent => 'അയച്ചു.';

  @override
  String get errorBlePermissionNeeded =>
      'പങ്കിടാൻ ബ്ലൂടൂത്ത് അനുമതി വേണം. SreerajP Contacts Sphere-ന് “സമീപമുള്ള ഉപകരണങ്ങൾ” അനുവദിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get errorNoPhoneConnected =>
      'ഒരു ഫോണും ബന്ധിപ്പിച്ചില്ല. സ്വീകരിക്കുന്നയാൾ തയ്യാറാകുമ്പോൾ വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get titleIncomingTransfer => 'വരുന്ന കൈമാറ്റം';

  @override
  String get descNearbyDeviceWantsToSend =>
      'അടുത്തുള്ള ഒരു ഉപകരണം നിങ്ങൾക്ക് വിലാസവിവരങ്ങൾ അയയ്ക്കാൻ ആഗ്രഹിക്കുന്നു.';

  @override
  String get descReceiveThisTransfer => 'ഈ കൈമാറ്റം സ്വീകരിക്കണോ?';

  @override
  String get actionDecline => 'നിരസിക്കുക';

  @override
  String get actionAccept => 'സ്വീകരിക്കുക';

  @override
  String get descAuthReasonBleReceive =>
      'ബ്ലൂടൂത്ത് കൈമാറ്റം സ്വീകരിക്കാൻ സ്ഥിരീകരിക്കുക';

  @override
  String get titleAuthenticateToReceive => 'സ്വീകരിക്കാൻ സ്ഥിരീകരിക്കുക';

  @override
  String get errorAuthFailedBle =>
      'സ്ഥിരീകരണം പരാജയപ്പെട്ടു. വീണ്ടും ശ്രമിക്കുക, അല്ലെങ്കിൽ കൈമാറ്റം നിരസിക്കുക.';

  @override
  String get descVerifyIdentityBle =>
      'ഈ ബ്ലൂടൂത്ത് കൈമാറ്റം സ്വീകരിക്കാൻ നിങ്ങൾ ആരെന്ന് സ്ഥിരീകരിക്കുക.';

  @override
  String get labelVerifying => 'പരിശോധിക്കുന്നു…';

  @override
  String get titleEnterPinToReceive => 'സ്വീകരിക്കാൻ PIN നൽകുക';

  @override
  String get errorWrongPinTryAgain => 'തെറ്റായ PIN — വീണ്ടും ശ്രമിക്കുക';

  @override
  String get descEnterPinBle =>
      'ഈ ബ്ലൂടൂത്ത് കൈമാറ്റം സ്വീകരിക്കാൻ ആപ്പ് PIN നൽകുക.';

  @override
  String get errorCouldNotScheduleRetry =>
      'സ്വയം വീണ്ടും വിളിക്കൽ ക്രമീകരിക്കാനായില്ല';

  @override
  String msgAutoRetryAt(String time, String name) {
    return '$time-ന് $name-നെ സ്വയം വീണ്ടും വിളിക്കും';
  }

  @override
  String get actionView => 'കാണുക';

  @override
  String get titleAllowAlarmsReminders => 'അലാറം അനുമതി നൽകുക';

  @override
  String get descAlarmsPermission =>
      'ഈ ആപ്പ് അടച്ചിരിക്കുമ്പോഴും നിശ്ചിത സമയത്ത് തിരികെ വിളിക്കാൻ സ്വയം വീണ്ടും വിളിക്കലിന് “അലാറങ്ങളും റിമൈൻഡറുകളും” അനുമതി വേണം. അടുത്തതായി തുറക്കുന്ന ക്രമീകരണ സ്ക്രീനിൽ SreerajP Contacts Sphere-ന് അത് ഓണാക്കുക.';

  @override
  String get actionOpenSettings => 'ക്രമീകരണങ്ങൾ തുറക്കുക';

  @override
  String get errorCouldNotLaunchMessaging => 'സന്ദേശ ആപ്പ് തുറക്കാനായില്ല';

  @override
  String get titleCallUnanswered => 'ഫോൺ വിളിക്ക് മറുപടിയില്ല';

  @override
  String get labelOptionAutoRetry => 'ഒന്ന്: സ്വയം വീണ്ടും വിളി';

  @override
  String get labelOptionReachMe => 'രണ്ട്: ബന്ധപ്പെടാൻ സന്ദേശം';

  @override
  String actionAutoRetryIn(int minutes) {
    return '$minutes മിനിറ്റിൽ സ്വയം വിളിക്കുക';
  }

  @override
  String get tooltipEditMessage => 'സന്ദേശം തിരുത്തുക';

  @override
  String get hintReachMeMessage => 'നിങ്ങളുടെ സന്ദേശം എഴുതുക...';

  @override
  String get actionSendReachMeSms => 'ബന്ധപ്പെടാൻ SMS അയയ്ക്കുക';

  @override
  String get actionDismiss => 'അവഗണിക്കുക';

  @override
  String labelMinutesShort(int minutes) {
    return '$minutes മിനിറ്റ്';
  }

  @override
  String get labelDefaultSim => 'സ്വതവേയുള്ള സിം';

  @override
  String get labelSimToDial => 'വിളിക്കാനുള്ള സിം:';

  @override
  String get titleSelectSimForRetry => 'വീണ്ടും വിളിക്കാനുള്ള സിം';

  @override
  String get labelFieldName => 'പേര്';

  @override
  String get labelFieldPhone => 'ഫോൺ';

  @override
  String get labelFieldEmail => 'ഇമെയിൽ';

  @override
  String get labelFieldDesignation => 'പദവി';

  @override
  String get labelFieldCompany => 'സ്ഥാപനം';

  @override
  String get labelFieldStreet => 'തെരുവ്';

  @override
  String get labelFieldCity => 'നഗരം';

  @override
  String get labelFieldState => 'സംസ്ഥാനം';

  @override
  String get labelFieldPostalCode => 'പിൻകോഡ്';

  @override
  String get labelFieldCountry => 'രാജ്യം';

  @override
  String get labelFieldLink => 'ലിങ്ക്';

  @override
  String get titleReadFromCard => 'കാർഡിൽ നിന്ന് വായിച്ചത്';

  @override
  String get descUntickWrongFields =>
      'തെറ്റായി വന്നവയുടെ ടിക്ക് മാറ്റുക. അടുത്ത സ്ക്രീനിൽ എല്ലാം ഇനിയും തിരുത്താം.';

  @override
  String get emptyNoFieldsRead =>
      'ഈ കാർഡിൽ നിന്ന് ഒരു വിവരവും വായിക്കാനായില്ല.';

  @override
  String descNotPlacedInField(String lines) {
    return 'ഒരിടത്തും ചേർക്കാത്തവ: $lines';
  }

  @override
  String get actionHideScannedText => 'സ്കാൻ ചെയ്ത വാചകം മറയ്ക്കുക';

  @override
  String get actionShowScannedText => 'സ്കാൻ ചെയ്ത വാചകം കാണിക്കുക';

  @override
  String get emptyNothingRecognized => 'ഒന്നും തിരിച്ചറിഞ്ഞില്ല.';

  @override
  String get actionRetake => 'വീണ്ടും എടുക്കുക';

  @override
  String get labelRelationshipLabel => 'ബന്ധത്തിന്റെ പേര്';

  @override
  String get hintRelationshipExample => 'ഉദാ. അച്ഛൻ';

  @override
  String get titlePickCategory => 'വിഭാഗം തിരഞ്ഞെടുക്കുക';

  @override
  String titleHowIsRelated(String name) {
    return '$name-ന്റെ ബന്ധം എന്താണ്?';
  }

  @override
  String get titleLinkContact => 'വിലാസവിവരം ബന്ധിപ്പിക്കുക';

  @override
  String get hintSearchContacts => 'വിലാസവിവരങ്ങൾ തിരയുക';

  @override
  String get emptyNoContactsAvailable => 'വിലാസവിവരങ്ങളൊന്നും ലഭ്യമല്ല';

  @override
  String titleWhereBelongs(String name) {
    return '$name ഏത് വിഭാഗത്തിലാണ്?';
  }

  @override
  String get errorAirQrPayload =>
      'ഈ വിലാസവിവരത്തിനായി AirQR ഡാറ്റ തയ്യാറാക്കാനായില്ല.';

  @override
  String get labelFrameParity => 'പരിശോധനാ ഖണ്ഡം';

  @override
  String get labelFrameSystematic => 'ഡാറ്റാ ഖണ്ഡം';

  @override
  String descAirGapStream(int count) {
    return 'ദൃശ്യ QR പ്രവാഹം ($count ഫ്രെയിമുകൾ)';
  }

  @override
  String get errorFrameRender => 'ഫ്രെയിം കാണിക്കുന്നതിൽ പിശക്';

  @override
  String labelFrameProgress(int current, int total, String type) {
    return 'ഫ്രെയിം $current / $total • $type';
  }

  @override
  String get tooltipPauseStream => 'പ്രവാഹം നിർത്തിവയ്ക്കുക';

  @override
  String get tooltipResumeStream => 'പ്രവാഹം പുനരാരംഭിക്കുക';

  @override
  String errorCouldNotShareQr(String error) {
    return 'QR പങ്കിടാനായില്ല: $error';
  }

  @override
  String get descScanToAddContact =>
      'ഈ വിലാസവിവരം ചേർക്കാൻ ഏത് ഫോൺ ക്യാമറ ഉപയോഗിച്ചും സ്കാൻ ചെയ്യുക.';

  @override
  String get errorContactTooBigForQr =>
      'ഈ വിലാസവിവരത്തിൽ QR കോഡിൽ ഒതുങ്ങാത്തത്ര വിവരങ്ങളുണ്ട്.';

  @override
  String get tooltipAirGapStream => 'പൂർണ്ണ QR പ്രവാഹം';

  @override
  String get actionShare => 'പങ്കിടുക';

  @override
  String get titleScannedContact => 'സ്കാൻ ചെയ്ത വിലാസവിവരം';

  @override
  String get titleSecurityCheck => 'സുരക്ഷാ പരിശോധന';

  @override
  String labelContactsToImport(int count) {
    return 'ഇറക്കുമതി ചെയ്യേണ്ടവ ($count):';
  }

  @override
  String get labelUnnamedContact => 'പേരില്ലാത്ത വിലാസവിവരം';

  @override
  String labelPhonesList(String numbers) {
    return 'ഫോണുകൾ: $numbers';
  }

  @override
  String labelEmailsList(String emails) {
    return 'ഇമെയിലുകൾ: $emails';
  }

  @override
  String labelWebLinksList(String links) {
    return 'വെബ് ലിങ്കുകൾ: $links';
  }

  @override
  String get actionImportSafeOnly => 'സുരക്ഷിതമായവ മാത്രം';

  @override
  String get actionImport => 'ഇറക്കുമതി ചെയ്യുക';

  @override
  String get actionImportAll => 'എല്ലാം ഇറക്കുമതി ചെയ്യുക';

  @override
  String get titleChooseContact => 'വിലാസവിവരം തിരഞ്ഞെടുക്കുക';

  @override
  String errorCouldNotLoadContacts(String error) {
    return 'വിലാസവിവരങ്ങൾ ലോഡ് ചെയ്യാനായില്ല: $error';
  }

  @override
  String get tooltipClearSearch => 'തിരച്ചിൽ മായ്ക്കുക';

  @override
  String get emptyNoContactsWithNumber =>
      'നമ്പറുള്ള വിലാസവിവരങ്ങളൊന്നും ഇതുവരെ ഇല്ല.';

  @override
  String get emptyNoContactsYet => 'ഇതുവരെ വിലാസവിവരങ്ങളൊന്നുമില്ല.';

  @override
  String emptyNoContactsMatch(String query) {
    return '“$query” എന്നതുമായി പൊരുത്തപ്പെടുന്ന വിലാസവിവരങ്ങളില്ല.';
  }

  @override
  String get labelNoName => '(പേരില്ല)';

  @override
  String get emptyNoContactsFound => 'വിലാസവിവരങ്ങളൊന്നും കണ്ടെത്തിയില്ല';

  @override
  String get actionAdd => 'ചേർക്കുക';

  @override
  String get labelSuggested => 'നിർദ്ദേശിച്ചവ';

  @override
  String get labelAllContacts => 'എല്ലാ വിലാസവിവരങ്ങളും';

  @override
  String get labelAlreadyAdded => 'ഇതിനകം ചേർത്തു';

  @override
  String get tooltipVoiceSearch => 'ശബ്ദ തിരച്ചിൽ';

  @override
  String get errorVoiceUnavailable =>
      'ശബ്ദ ഇൻപുട്ട് ലഭ്യമല്ല — മൈക്രോഫോൺ അനുമതി പരിശോധിക്കുക.';

  @override
  String get tooltipStopListening => 'കേൾക്കൽ നിർത്തുക';

  @override
  String get labelDefaultPhoneApp => 'സ്വതവേയുള്ള ഫോൺ ആപ്പ്';

  @override
  String get descHandlesYourCalls =>
      'നിങ്ങളുടെ ഫോൺ വിളികൾ SreerajP Contacts Sphere കൈകാര്യം ചെയ്യുന്നു';

  @override
  String get descSetAsDefaultDialer =>
      'SreerajP Contacts Sphere-നെ സ്വതവേയുള്ള ഫോൺ ആപ്പാക്കുക';

  @override
  String get errorCallPermissionDenied => 'ഫോൺ വിളിക്കുള്ള അനുമതി നിഷേധിച്ചു';

  @override
  String errorCouldNotPlaceCall(String error) {
    return 'ഫോൺ വിളി നടത്താനായില്ല: $error';
  }

  @override
  String get labelUsualSimForCall => 'പതിവ് സിം';

  @override
  String get titleCallWith => 'ഇതുവഴി വിളിക്കുക';

  @override
  String get descChooseSimForCall => 'ഈ ഫോൺ വിളിക്കുള്ള സിം തിരഞ്ഞെടുക്കുക';

  @override
  String titleCallName(String name) {
    return '$name-നെ വിളിക്കുക';
  }

  @override
  String get descChooseNumber => 'ഒരു നമ്പർ തിരഞ്ഞെടുക്കുക';

  @override
  String get actionYes => 'അതെ';

  @override
  String get actionNo => 'ഇല്ല';

  @override
  String get tooltipSettings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get labelToday => 'ഇന്ന്';

  @override
  String get labelYesterday => 'ഇന്നലെ';

  @override
  String labelDurationSeconds(int seconds) {
    return '$seconds സെ.';
  }

  @override
  String labelDurationMinutes(int minutes) {
    return '$minutes മി.';
  }

  @override
  String labelDurationMinutesSeconds(int minutes, int seconds) {
    return '$minutes മി. $seconds സെ.';
  }

  @override
  String get labelOutcomeMissed => 'എടുക്കാത്തത്';

  @override
  String get labelOutcomeNoAnswer => 'മറുപടിയില്ല';

  @override
  String get labelOutcomeBusy => 'തിരക്കിലാണ്';

  @override
  String get labelOutcomeDeclined => 'നിരസിച്ചു';

  @override
  String get labelOutcomeCancelled => 'റദ്ദാക്കി';

  @override
  String get labelOutcomeFailed => 'പരാജയപ്പെട്ടു';

  @override
  String get labelBlocked => 'തടഞ്ഞു';

  @override
  String get titleClearCallHistory => 'വിളികളുടെ നാൾവഴി മായ്ക്കണോ?';

  @override
  String get descClearCallHistory =>
      'SreerajP Contacts Sphere-ൽ രേഖപ്പെടുത്തിയ എല്ലാ ഫോൺ വിളികളും ഇത് നീക്കും.';

  @override
  String get tooltipClearHistory => 'നാൾവഴി മായ്ക്കുക';

  @override
  String get hintSearchCalls => 'ഫോൺ വിളികൾ തിരയുക';

  @override
  String get emptyNoCallsYet =>
      'ഇതുവരെ ഫോൺ വിളികളൊന്നുമില്ല. നിങ്ങൾ ചെയ്യുന്ന ഫോൺ വിളികൾ ഇവിടെ കാണാം.';

  @override
  String get emptyNoCallsMatch =>
      'ഈ തിരച്ചിലിന് പൊരുത്തപ്പെടുന്ന ഫോൺ വിളികളില്ല.';

  @override
  String get tooltipCallBack => 'തിരികെ വിളിക്കുക';

  @override
  String get actionBlockNumber => 'നമ്പർ തടയുക';

  @override
  String get actionUnblockNumber => 'നമ്പർ തടയൽ നീക്കുക';

  @override
  String get actionMarkAsSpam => 'സ്പാം ആയി അടയാളപ്പെടുത്തുക';

  @override
  String get actionNotSpam => 'സ്പാം അല്ല';

  @override
  String get actionSmartRedialReachMe => 'വീണ്ടും വിളി, സന്ദേശം';

  @override
  String get actionCopyNumber => 'നമ്പർ പകർത്തുക';

  @override
  String get actionShareNumber => 'നമ്പർ പങ്കിടുക';

  @override
  String get actionRemoveFromHistory => 'നാൾവഴിയിൽ നിന്ന് നീക്കുക';

  @override
  String msgNumberBlocked(String number) {
    return '$number തടഞ്ഞു — ഇനി ഈ നമ്പറിൽ നിന്ന് വിളി വരില്ല';
  }

  @override
  String msgMarkedAsSpam(String number) {
    return '$number സ്പാം ആയി അടയാളപ്പെടുത്തി';
  }

  @override
  String msgNoLongerSpam(String number) {
    return '$number ഇനി സ്പാം ആയി അടയാളപ്പെടുത്തിയിട്ടില്ല';
  }

  @override
  String msgCopiedNumber(String number) {
    return '$number ക്ലിപ്ബോർഡിലേക്ക് പകർത്തി';
  }

  @override
  String msgSpeedDialAssigned(String slot, String name) {
    return '$slot എന്ന കീ ഇനി $name-നെ വിളിക്കും';
  }

  @override
  String msgCallingName(String name) {
    return '$name-നെ വിളിക്കുന്നു…';
  }

  @override
  String get actionHideKeypad => 'കീപാഡ് മറയ്ക്കുക';

  @override
  String get tooltipBack => 'പിന്നോട്ട്';

  @override
  String get titleKeypadDtmf => 'കീപാഡ് (DTMF)';

  @override
  String get titleAddCall => 'ഫോൺ വിളി ചേർക്കുക';

  @override
  String get tooltipMore => 'കൂടുതൽ';

  @override
  String get titleSettings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get hintStartTypingToFind => 'വിലാസവിവരം കണ്ടെത്താൻ ടൈപ്പ് ചെയ്യുക';

  @override
  String get tooltipVoiceDialing => 'ശബ്ദം വഴി വിളിക്കൽ';

  @override
  String labelMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count പൊരുത്തങ്ങൾ',
      one: 'ഒരു പൊരുത്തം',
    );
    return '$_temp0';
  }

  @override
  String get emptyNoContactForNumber =>
      'ഈ നമ്പറിന് ഇതുവരെ സൂക്ഷിച്ച വിലാസവിവരമില്ല.';

  @override
  String emptyNoVoiceMatch(String query) {
    return '“$query” എന്നതുമായി പൊരുത്തപ്പെടുന്ന വിലാസവിവരമില്ല.';
  }

  @override
  String labelHeardQuery(String query) {
    return 'കേട്ടത്: “$query”';
  }

  @override
  String get emptyStarContact =>
      'ഇവിടെ കാണാൻ ഒരു വിലാസവിവരത്തിന് നക്ഷത്രം നൽകുക';

  @override
  String get labelFavorites => 'പ്രിയപ്പെട്ടവ';

  @override
  String get labelFamilyFriends => 'കുടുംബവും സുഹൃത്തുക്കളും';

  @override
  String get labelLikelyToAnswer => 'ഇപ്പോൾ എടുക്കാൻ സാധ്യതയുള്ളവർ';

  @override
  String get labelTopContacts => 'പ്രധാന വിലാസവിവരങ്ങൾ';

  @override
  String get actionAddToContacts => 'വിലാസവിവരങ്ങളിൽ ചേർക്കുക';

  @override
  String get tooltipCall => 'വിളിക്കുക';

  @override
  String get tooltipBackspace => 'മായ്ക്കുക (അമർത്തിപ്പിടിക്കാം)';

  @override
  String get labelUnknownCaller => 'അജ്ഞാതം';

  @override
  String get labelIncomingCall => 'വരുന്ന ഫോൺ വിളി';

  @override
  String get labelCalling => 'വിളിക്കുന്നു…';

  @override
  String get labelOnHold => 'കാത്തുനിർത്തി';

  @override
  String get labelCallEnded => 'ഫോൺ വിളി അവസാനിച്ചു';

  @override
  String get labelConnected => 'ബന്ധിപ്പിച്ചു';

  @override
  String get labelSecondCall => 'രണ്ടാമത്തെ ഫോൺ വിളി';

  @override
  String get tooltipTapToSwitchCall => 'ഫോൺ വിളി മാറ്റാൻ തൊടുക';

  @override
  String labelNameOnHold(String name) {
    return '$name — കാത്തുനിർത്തി';
  }

  @override
  String get labelAboutThisContact => 'ഈ വിലാസവിവരത്തെക്കുറിച്ച്';

  @override
  String get labelWhyCalling => 'വിളിക്കുന്നതിന്റെ കാരണം';

  @override
  String get labelCallerIdNotVerified => 'വിളിക്കുന്നയാളെ സ്ഥിരീകരിച്ചിട്ടില്ല';

  @override
  String get labelReply => 'മറുപടി';

  @override
  String get labelMute => 'നിശ്ശബ്ദം';

  @override
  String get labelHold => 'കാത്തുനിർത്തുക';

  @override
  String get labelSpeaker => 'സ്പീക്കർ';

  @override
  String get labelKeypad => 'കീപാഡ്';

  @override
  String get labelMerge => 'ലയിപ്പിക്കുക';

  @override
  String get labelSwap => 'മാറ്റുക';

  @override
  String get labelConferenceCall => 'കോൺഫറൻസ് വിളി';

  @override
  String labelConferencePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count പേർ',
      one: 'ഒരാൾ',
    );
    return '$_temp0';
  }

  @override
  String get labelManage => 'നിയന്ത്രിക്കുക';

  @override
  String get titlePeopleOnCall => 'ഈ വിളിയിലുള്ളവർ';

  @override
  String get actionPrivate => 'സ്വകാര്യം';

  @override
  String get actionDrop => 'ഒഴിവാക്കുക';

  @override
  String get tooltipPrivateTalk => 'ഈ ആളുമായി മാത്രം സംസാരിക്കുക';

  @override
  String get tooltipDropFromCall => 'ഈ ആളെ വിളിയിൽ നിന്ന് ഒഴിവാക്കുക';

  @override
  String get labelBlock => 'തടയുക';

  @override
  String get titleUnblockThisNumber => 'ഈ നമ്പറിന്റെ തടയൽ നീക്കണോ?';

  @override
  String get titleBlockThisNumber => 'ഈ നമ്പർ തടയണോ?';

  @override
  String descUnblockNumber(String number) {
    return '$number-ൽ നിന്നുള്ള ഫോൺ വിളികൾ വീണ്ടും സാധാരണ പോലെ റിംഗ് ചെയ്യും.';
  }

  @override
  String descBlockNumberFuture(String number) {
    return '$number-ൽ നിന്നുള്ള ഇനിയുള്ള ഫോൺ വിളികൾ നിങ്ങളുടെ ഫോൺ റിംഗ് ചെയ്യുന്നതിനു മുമ്പ് നിരസിക്കപ്പെടും.';
  }

  @override
  String get descCallWillDisconnect => 'ഈ ഫോൺ വിളി ഉടൻ വിച്ഛേദിക്കപ്പെടും.';

  @override
  String get descManageBlockedNumbers =>
      'ക്രമീകരണങ്ങൾ → വിലാസവിവരങ്ങൾ → തടഞ്ഞ നമ്പറുകൾ എന്നതിൽ തടഞ്ഞ നമ്പറുകൾ നിയന്ത്രിക്കാം.';

  @override
  String get actionUnblock => 'തടയൽ നീക്കുക';

  @override
  String get titleReplyWithMessage => 'സന്ദേശത്തിലൂടെ മറുപടി';

  @override
  String get descDeclinesAndTexts =>
      'ഫോൺ വിളി നിരസിച്ച് വിളിക്കുന്നയാൾക്ക് സന്ദേശം അയയ്ക്കുന്നു';

  @override
  String get actionWriteYourOwn => 'സ്വന്തമായി എഴുതുക…';

  @override
  String get titleReplyWith => 'മറുപടി…';

  @override
  String get labelMessage => 'സന്ദേശം';

  @override
  String get hintTypeMessageToSend => 'അയയ്ക്കാനുള്ള സന്ദേശം എഴുതുക';

  @override
  String get actionSend => 'അയയ്ക്കുക';

  @override
  String get actionHide => 'മറയ്ക്കുക';

  @override
  String get errorRingtoneMissing =>
      'ഈ റിംഗ്ടോൺ ഇപ്പോൾ ലഭ്യമല്ല — തിരുത്തുക എന്നതിൽ പുതിയത് തിരഞ്ഞെടുക്കുക.';

  @override
  String get errorRingVolumeMuted =>
      'റിംഗ് ശബ്ദം നിശ്ശബ്ദമാണ് — കേൾക്കാൻ ശബ്ദം കൂട്ടുക.';

  @override
  String get actionShareVcard => 'vCard (.vcf) ആയി പങ്കിടുക';

  @override
  String get descShareVcard =>
      'വിലാസവിവര കാർഡ് WhatsApp-ലേക്കോ മറ്റേതെങ്കിലും ആപ്പിലേക്കോ അയയ്ക്കുക';

  @override
  String get actionShareAsText => 'വാചകമായി പങ്കിടുക';

  @override
  String get descShareAsText => 'പേരും ഫോൺ നമ്പറുകളും ഒരു സന്ദേശമായി അയയ്ക്കുക';

  @override
  String get actionCopyNamePhone => 'പേരും ഫോണും പകർത്തുക';

  @override
  String get descCopyContactDetails =>
      'വിലാസവിവരങ്ങൾ ക്ലിപ്ബോർഡിലേക്ക് പകർത്തുക';

  @override
  String get actionShareAsQr => 'QR കോഡായി പങ്കിടുക';

  @override
  String get descShareAsQr =>
      'സ്കാൻ ചെയ്യാവുന്ന കോഡ് കാണിക്കുക, അല്ലെങ്കിൽ ചിത്രമായി അയയ്ക്കുക';

  @override
  String get actionShareViaBluetooth => 'ബ്ലൂടൂത്ത് വഴി പങ്കിടുക';

  @override
  String get descSendToNearbyPhone =>
      'അടുത്തുള്ള ഫോണിലേക്ക് നേരിട്ട് അയയ്ക്കുക';

  @override
  String errorCouldNotShareContact(String error) {
    return 'വിലാസവിവരം പങ്കിടാനായില്ല: $error';
  }

  @override
  String errorCouldNotShareText(String error) {
    return 'വാചകം പങ്കിടാനായില്ല: $error';
  }

  @override
  String get msgContactDetailsCopied =>
      'വിലാസവിവരങ്ങൾ ക്ലിപ്ബോർഡിലേക്ക് പകർത്തി';

  @override
  String errorCouldNotCopyDetails(String error) {
    return 'വിലാസവിവരങ്ങൾ പകർത്താനായില്ല: $error';
  }

  @override
  String errorCouldNotCopyNumber(String error) {
    return 'നമ്പർ പകർത്താനായില്ല: $error';
  }

  @override
  String errorFailedToLoadContact(String error) {
    return 'വിലാസവിവരം ലോഡ് ചെയ്യാനായില്ല: $error';
  }

  @override
  String get errorCouldNotOpenApp => 'ഈ ആപ്പ് തുറക്കാനായില്ല.';

  @override
  String errorCouldNotUpdateFavorite(String error) {
    return 'പ്രിയപ്പെട്ടവ നവീകരിക്കാനായില്ല: $error';
  }

  @override
  String titleDeleteContactConfirm(String name) {
    return '$name ഇല്ലാതാക്കണോ?';
  }

  @override
  String get descDeleteContactAndDevice =>
      'ഈ വിലാസവിവരം ആപ്പിൽ നിന്നും ഫോണിലെ വിലാസപ്പുസ്തകത്തിൽ നിന്നും നീക്കും.';

  @override
  String get descDeleteContactApp => 'ഈ വിലാസവിവരം ആപ്പിൽ നിന്ന് നീക്കും.';

  @override
  String errorDeleteFailed(String error) {
    return 'ഇല്ലാതാക്കൽ പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get labelContact => 'വിലാസവിവരം';

  @override
  String get tooltipAddToFavorites => 'പ്രിയപ്പെട്ടവയിൽ ചേർക്കുക';

  @override
  String get tooltipRemoveFromFavorites => 'പ്രിയപ്പെട്ടവയിൽ നിന്ന് നീക്കുക';

  @override
  String get actionEdit => 'തിരുത്തുക';

  @override
  String get actionRemove => 'നീക്കുക';

  @override
  String get emptyContactNotFound => 'വിലാസവിവരം കണ്ടെത്തിയില്ല';

  @override
  String get labelBirthday => 'ജന്മദിനം';

  @override
  String get labelAnniversary => 'വിവാഹ വാർഷികം';

  @override
  String get labelMeetiversary => 'പരിചയ വാർഷികം';

  @override
  String get labelGender => 'ലിംഗം';

  @override
  String get labelFormalName => 'ഔപചാരിക നാമം';

  @override
  String get labelBloodGroup => 'രക്തഗ്രൂപ്പ്';

  @override
  String get labelCustomRingtone => 'സ്വന്തം റിംഗ്ടോൺ';

  @override
  String get labelRingtone => 'റിംഗ്ടോൺ';

  @override
  String get tooltipStop => 'നിർത്തുക';

  @override
  String get tooltipPreview => 'കേട്ടുനോക്കുക';

  @override
  String get labelChosenSim => 'തിരഞ്ഞെടുത്ത സിം';

  @override
  String get descCallsGoOutOnSim => 'ഫോൺ വിളികൾ ഈ സിമ്മിലൂടെ പോകും';

  @override
  String get labelCallingCard => 'വിളി കാർഡ്';

  @override
  String get labelRelationships => 'ബന്ധങ്ങൾ';

  @override
  String get tooltipViewSphere => 'ബന്ധവലയം കാണുക';

  @override
  String get tooltipAddRelationship => 'ബന്ധം ചേർക്കുക';

  @override
  String get emptyNoRelationships =>
      'ഇതുവരെ ബന്ധങ്ങളൊന്നുമില്ല. ഒരു വിലാസവിവരം ബന്ധിപ്പിക്കാൻ ലിങ്ക് ചിഹ്നം തൊടുക.';

  @override
  String get tooltipEditType => 'തരം തിരുത്തുക';

  @override
  String get labelConnectedApps => 'ബന്ധിപ്പിച്ച ആപ്പുകൾ';

  @override
  String get descBirthdayComingUp => '🎂 ഒരാഴ്ചയ്ക്കുള്ളിൽ ജന്മദിനം';

  @override
  String descLastCall(String duration) {
    return 'അവസാന ഫോൺ വിളി: $duration';
  }

  @override
  String descTheirTime(String time) {
    return 'അവരുടെ സമയം: $time';
  }

  @override
  String descRecentInteractions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count സമീപകാല ഇടപെടലുകൾ',
      one: 'ഒരു സമീപകാല ഇടപെടൽ',
    );
    return '$_temp0';
  }

  @override
  String get labelBeforeYouCall => 'വിളിക്കുന്നതിനു മുമ്പ്';

  @override
  String descEphemeralAutoDelete(int count) {
    return 'ഒരു ഫോൺ വിളിക്കു ശേഷം സ്വയം ഇല്ലാതാകും ($count/1 വിളി രേഖപ്പെടുത്തി)';
  }

  @override
  String get descEphemeralExpired =>
      'കാലാവധി കഴിഞ്ഞു — ഉടൻ സ്വയം ഇല്ലാതാകും...';

  @override
  String descEphemeralCountdown(String hours, String minutes, String seconds) {
    return 'സ്വയം ഇല്ലാതാകാൻ: $hours മ. $minutes മി. $seconds സെ.';
  }

  @override
  String get labelEphemeralContact => 'താൽക്കാലിക വിലാസവിവരം';

  @override
  String get labelSqlcipherLocalOnly => 'SQLCipher · ഈ ഫോണിൽ മാത്രം';

  @override
  String get actionAdd24Hours => '+24 മണിക്കൂർ';

  @override
  String get actionKeepPermanently => 'സ്ഥിരമായി സൂക്ഷിക്കുക';

  @override
  String get actionScrubNow => 'ഇപ്പോൾ മായ്ക്കുക';

  @override
  String get errorAuthRequiredSecret =>
      'രഹസ്യ വിലാസവിവരങ്ങൾ കാണാൻ സ്ഥിരീകരണം ആവശ്യമാണ്';

  @override
  String msgDeletedName(String name) {
    return '$name ഇല്ലാതാക്കി';
  }

  @override
  String titleDeleteContactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count വിലാസവിവരങ്ങൾ ഇല്ലാതാക്കണോ?',
      one: 'ഒരു വിലാസവിവരം ഇല്ലാതാക്കണോ?',
    );
    return '$_temp0';
  }

  @override
  String get descDeleteSelected =>
      'ഇവ ആപ്പിൽ നിന്നും, ബന്ധിപ്പിച്ചിട്ടുള്ളവ ഫോണിലെ വിലാസപ്പുസ്തകത്തിൽ നിന്നും നീക്കും.';

  @override
  String msgDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count വിലാസവിവരങ്ങൾ ഇല്ലാതാക്കി',
      one: 'ഒരു വിലാസവിവരം ഇല്ലാതാക്കി',
    );
    return '$_temp0';
  }

  @override
  String msgDeletedCountFailed(int deleted, int failed) {
    return '$deleted ഇല്ലാതാക്കി, $failed പരാജയപ്പെട്ടു';
  }

  @override
  String errorNoPhoneFor(String name) {
    return '$name-ന് ഫോൺ നമ്പറില്ല';
  }

  @override
  String errorNoEmailFor(String name) {
    return '$name-ന് ഇമെയിൽ വിലാസമില്ല';
  }

  @override
  String get errorNoEmailApp => 'ഇമെയിൽ ആപ്പ് ലഭ്യമല്ല';

  @override
  String get errorCouldNotOpenEmail => 'ഇമെയിൽ ആപ്പ് തുറക്കാനായില്ല';

  @override
  String get titleImportExport => 'ഇറക്കുമതി / കയറ്റുമതി';

  @override
  String get actionImportCsv => 'CSV ഇറക്കുമതി ചെയ്യുക';

  @override
  String get actionExportCsv => 'CSV കയറ്റുമതി ചെയ്യുക';

  @override
  String get actionImportVcf => 'vCard (.vcf) ഇറക്കുമതി';

  @override
  String get actionExportVcf => 'vCard (.vcf) കയറ്റുമതി';

  @override
  String get titleBluetoothTransfer => 'ബ്ലൂടൂത്ത് കൈമാറ്റം';

  @override
  String get actionSendAllViaBluetooth => 'എല്ലാം ബ്ലൂടൂത്ത് വഴി അയയ്ക്കുക';

  @override
  String msgImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count വിലാസവിവരങ്ങൾ ഇറക്കുമതി ചെയ്തു',
      one: 'ഒരു വിലാസവിവരം ഇറക്കുമതി ചെയ്തു',
    );
    return '$_temp0';
  }

  @override
  String get msgNothingImported => 'ഒന്നും ഇറക്കുമതി ചെയ്തില്ല';

  @override
  String errorImportFailed(String error) {
    return 'ഇറക്കുമതി പരാജയപ്പെട്ടു: $error';
  }

  @override
  String errorExportFailed(String error) {
    return 'കയറ്റുമതി പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get errorNoContactsToSend => 'അയയ്ക്കാൻ വിലാസവിവരങ്ങളില്ല';

  @override
  String errorCouldNotStartBleShareDetail(String error) {
    return 'ബ്ലൂടൂത്ത് പങ്കിടൽ ആരംഭിക്കാനായില്ല: $error';
  }

  @override
  String get tooltipSecretContacts => 'രഹസ്യ വിലാസവിവരങ്ങൾ';

  @override
  String get tooltipRelationStatus => 'ബന്ധങ്ങളുടെ നില';

  @override
  String get tooltipGroups => 'ഗ്രൂപ്പുകൾ';

  @override
  String get actionMyProfile => 'എന്റെ പ്രൊഫൈൽ';

  @override
  String get actionScanQrCode => 'QR കോഡ് സ്കാൻ ചെയ്യുക';

  @override
  String get actionScanBusinessCard => 'ബിസിനസ് കാർഡ് സ്കാൻ ചെയ്യുക';

  @override
  String get actionFindDuplicates => 'ഇരട്ടിപ്പുകൾ കണ്ടെത്തുക';

  @override
  String get tooltipCancelSelection => 'തിരഞ്ഞെടുക്കൽ റദ്ദാക്കുക';

  @override
  String labelSelectedCount(int count) {
    return '$count തിരഞ്ഞെടുത്തു';
  }

  @override
  String get tooltipSelectAll => 'എല്ലാം തിരഞ്ഞെടുക്കുക';

  @override
  String get tooltipDeleteSelected => 'തിരഞ്ഞെടുത്തവ ഇല്ലാതാക്കുക';

  @override
  String get labelAll => 'എല്ലാം';

  @override
  String msgSyncingContacts(int processed, int total) {
    return 'വിലാസവിവരങ്ങൾ സമന്വയിപ്പിക്കുന്നു… $total-ൽ $processed';
  }

  @override
  String get msgReadingDeviceContacts => 'ഫോണിലെ വിലാസവിവരങ്ങൾ വായിക്കുന്നു…';

  @override
  String get emptyNoFavorites =>
      'ഇതുവരെ പ്രിയപ്പെട്ടവയൊന്നുമില്ല.\nഇവിടെ കാണാൻ ഒരു വിലാസവിവരത്തിന് നക്ഷത്രം നൽകുക.';

  @override
  String get emptyNoContactsTapPlus =>
      'ഇതുവരെ വിലാസവിവരങ്ങളൊന്നുമില്ല. ചേർക്കാൻ + തൊടുക.';

  @override
  String get labelOneCallBadge => '⏱️ ഒറ്റ വിളി';

  @override
  String get labelEphemeralBadge => '⏱️ താൽക്കാലികം';

  @override
  String get labelYou => 'നിങ്ങൾ';

  @override
  String get labelProfile => 'പ്രൊഫൈൽ';

  @override
  String labelDaysAgo(int count) {
    return '$count ദിവസം മുമ്പ്';
  }

  @override
  String labelWeeksAgo(int count) {
    return '$count ആഴ്ച മുമ്പ്';
  }

  @override
  String labelMonthsAgo(int count) {
    return '$count മാസം മുമ്പ്';
  }

  @override
  String labelYearsAgo(int count) {
    return '$count വർഷം മുമ്പ്';
  }

  @override
  String get labelTypeMobile => 'മൊബൈൽ';

  @override
  String get labelTypeHome => 'വീട്';

  @override
  String get labelTypeWork => 'ജോലിസ്ഥലം';

  @override
  String get labelTypeMain => 'പ്രധാനം';

  @override
  String get labelTypeFax => 'ഫാക്സ്';

  @override
  String get labelTypeOther => 'മറ്റുള്ളവ';

  @override
  String get labelTypePersonal => 'വ്യക്തിപരം';

  @override
  String get labelTypeSchool => 'വിദ്യാലയം';

  @override
  String get labelTypeWebsite => 'വെബ്സൈറ്റ്';

  @override
  String get labelGenderMale => 'പുരുഷൻ';

  @override
  String get labelGenderFemale => 'സ്ത്രീ';

  @override
  String get labelGenderNonBinary => 'നോൺ-ബൈനറി';

  @override
  String get labelGenderPreferNotToSay => 'പറയാൻ താൽപ്പര്യമില്ല';

  @override
  String get labelAddressPersonal => 'വ്യക്തിഗത വിലാസം';

  @override
  String get labelAddressOfficial => 'ജോലി വിലാസം';

  @override
  String errorCouldNotPickImage(String error) {
    return 'ചിത്രം എടുക്കാനായില്ല: $error';
  }

  @override
  String errorCouldNotPickCard(String error) {
    return 'വിളി കാർഡ് എടുക്കാനായില്ല: $error';
  }

  @override
  String get actionTakePhoto => 'ഫോട്ടോ എടുക്കുക';

  @override
  String get actionChooseFromGallery => 'ഗാലറിയിൽ നിന്ന് തിരഞ്ഞെടുക്കുക';

  @override
  String get errorCameraPermission =>
      'ഫോട്ടോ എടുക്കാൻ ക്യാമറ അനുമതി ആവശ്യമാണ്.';

  @override
  String errorCouldNotPickRingtone(String error) {
    return 'റിംഗ്ടോൺ തിരഞ്ഞെടുക്കാനായില്ല: $error';
  }

  @override
  String get titlePhoneRingtones => 'ഫോണിലെ റിംഗ്ടോണുകൾ';

  @override
  String get descPhoneRingtones =>
      'ഈ ഫോണിലെ റിംഗ്ടോണുകളിൽ നിന്ന് തിരഞ്ഞെടുക്കുക';

  @override
  String get titleAudioFile => 'ഓഡിയോ ഫയൽ';

  @override
  String get descAudioFile =>
      'നിങ്ങളുടെ ഫോൾഡറുകളിൽ നിന്ന് ഒരു ഓഡിയോ ഫയൽ തിരഞ്ഞെടുക്കുക';

  @override
  String get errorRingtoneRevert =>
      'ഈ റിംഗ്ടോൺ ഇപ്പോൾ ലഭ്യമല്ല — സ്വതവേയുള്ളതിലേക്ക് മടങ്ങുന്നു.';

  @override
  String get titleRemovePhone => 'ഫോൺ നമ്പർ നീക്കണോ?';

  @override
  String get descRemovePhone => 'ഈ ഫോൺ നമ്പർ വിലാസവിവരത്തിൽ നിന്ന് നീക്കും.';

  @override
  String get titleRemoveEmail => 'ഇമെയിൽ നീക്കണോ?';

  @override
  String get descRemoveEmail => 'ഈ ഇമെയിൽ വിലാസവിവരത്തിൽ നിന്ന് നീക്കും.';

  @override
  String get titleRemoveSocialLink => 'സോഷ്യൽ ലിങ്ക് നീക്കണോ?';

  @override
  String get descRemoveSocialLink =>
      'ഈ സോഷ്യൽ ലിങ്ക് വിലാസവിവരത്തിൽ നിന്ന് നീക്കും.';

  @override
  String get errorFirstNameRequired => 'ആദ്യ പേര് ആവശ്യമാണ്';

  @override
  String errorInvalidPhoneNumber(String number, String reason) {
    return 'അസാധുവായ ഫോൺ നമ്പർ: $number ($reason)';
  }

  @override
  String get errorPhoneEmpty => 'നമ്പർ ശൂന്യമാണ്';

  @override
  String get errorPhoneTooShort => 'നമ്പർ വളരെ ചെറുതാണ്';

  @override
  String get errorPhoneTooLong => 'നമ്പർ വളരെ നീളമുള്ളതാണ്';

  @override
  String errorPhoneInvalidFormatFor(String code) {
    return '+$code-ന് നമ്പറിന്റെ രൂപം തെറ്റാണ്';
  }

  @override
  String get errorPhoneInvalidFormat => 'നമ്പറിന്റെ രൂപം തെറ്റാണ്';

  @override
  String errorSaveFailed(String error) {
    return 'സൂക്ഷിക്കൽ പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get labelPhoneNumbers => 'ഫോൺ നമ്പറുകൾ';

  @override
  String get actionAddPhone => 'ഫോൺ നമ്പർ ചേർക്കുക';

  @override
  String get labelEmails => 'ഇമെയിലുകൾ';

  @override
  String get actionAddEmail => 'ഇമെയിൽ ചേർക്കുക';

  @override
  String get labelSocialLinks => 'സോഷ്യൽ ലിങ്കുകൾ';

  @override
  String get hintUrlOrHandle => 'URL അല്ലെങ്കിൽ @പേര്';

  @override
  String get actionAddSocialLink => 'സോഷ്യൽ ലിങ്ക് ചേർക്കുക';

  @override
  String get titleEditMe => 'എന്നെ തിരുത്തുക';

  @override
  String get titleAddMe => 'എന്നെ ചേർക്കുക';

  @override
  String get titleEditContact => 'വിലാസവിവരം തിരുത്തുക';

  @override
  String get titleAddContact => 'വിലാസവിവരം ചേർക്കുക';

  @override
  String get actionChangePhoto => 'ഫോട്ടോ മാറ്റുക';

  @override
  String get actionAddPhoto => 'ഫോട്ടോ ചേർക്കുക';

  @override
  String get labelSalutation => 'അഭിസംബോധന';

  @override
  String get hintSalutation => 'ശ്രീ / ശ്രീമതി / ഡോ.';

  @override
  String get labelFirstNameRequired => 'ആദ്യ പേര് *';

  @override
  String get hintEnterFirstName => 'ആദ്യ പേര് നൽകുക';

  @override
  String get labelMiddleName => 'മധ്യ പേര്';

  @override
  String get labelLastName => 'അവസാന പേര്';

  @override
  String get hintOptional => 'ഐച്ഛികം';

  @override
  String get hintFormalName => 'ഔപചാരികമായി എങ്ങനെ സംബോധന ചെയ്യുന്നു';

  @override
  String get labelPersonalDetails => 'വ്യക്തിഗത വിവരങ്ങൾ';

  @override
  String get labelDateOfBirth => 'ജനനത്തീയതി';

  @override
  String get labelMeetiversaryDayYouMet => 'പരിചയ വാർഷികം · കണ്ട ദിനം';

  @override
  String get labelPreferredSim => 'ഇഷ്ട സിം';

  @override
  String get descPreferredSim =>
      'ഈ വ്യക്തിയെ ഏത് സിമ്മിൽ നിന്ന് വിളിക്കണം. പതിവ് സിം ഉപയോഗിക്കാൻ സ്വതവേയുള്ളതിൽ വിടുക.';

  @override
  String get descUseSimInSettings => 'ക്രമീകരണങ്ങളിലെ സിം ഉപയോഗിക്കുക';

  @override
  String get labelOnThisPhone => 'ഈ ഫോണിൽ';

  @override
  String get labelSelected => 'തിരഞ്ഞെടുത്തത്';

  @override
  String get labelNone => 'ഒന്നുമില്ല';

  @override
  String get actionAddCallingCard => 'വിളി കാർഡ് ചേർക്കുക';

  @override
  String get descCallingCardShown =>
      'ഫോൺ വിളിയുടെ സമയത്ത് മുഴുവൻ സ്ക്രീനിൽ കാണിക്കുന്ന ഫോട്ടോ';

  @override
  String get labelSelect => 'തിരഞ്ഞെടുക്കുക';

  @override
  String get actionClear => 'മായ്ക്കുക';

  @override
  String get hintDescribe => 'വിവരിക്കുക';

  @override
  String get hintCustom => 'സ്വന്തം';

  @override
  String get actionCustomLabel => '+ സ്വന്തം';

  @override
  String get labelAddTag => 'അടയാളം ചേർക്കുക';

  @override
  String get hintTypeAndEnter => 'ടൈപ്പ് ചെയ്ത് എന്റർ അമർത്തുക';

  @override
  String get labelTagSuggestVip => 'വിഐപി';

  @override
  String get labelTagSuggestMentor => 'മാർഗദർശി';

  @override
  String get labelTagSuggestClient => 'ഇടപാടുകാരൻ';

  @override
  String get labelTagSuggestInvestor => 'നിക്ഷേപകൻ';

  @override
  String get labelTagSuggestNeighbor => 'അയൽക്കാരൻ';

  @override
  String get labelAddToGroup => 'ഗ്രൂപ്പിൽ ചേർക്കുക';

  @override
  String get hintGroupSearch =>
      'തിരയാൻ ടൈപ്പ് ചെയ്യുക, എല്ലാം കാണാൻ *, അല്ലെങ്കിൽ പുതിയത് ചേർക്കുക';

  @override
  String get descLinkToPeople =>
      'ഈ വ്യക്തിക്ക് പരിചയമുള്ളവരുമായി ബന്ധിപ്പിക്കുക.';

  @override
  String get actionAddAddress => 'വിലാസം ചേർക്കുക';

  @override
  String labelAddressNumber(int index) {
    return 'വിലാസം $index';
  }

  @override
  String get hintStreet => 'വീട്ടുനമ്പർ, തെരുവ്';

  @override
  String get labelCityTown => 'നഗരം / പട്ടണം';

  @override
  String get labelCompanyName => 'സ്ഥാപനത്തിന്റെ പേര്';

  @override
  String get hintWhereTheyWork => 'ജോലി ചെയ്യുന്ന സ്ഥലം';

  @override
  String get labelOfficeStreet => 'ഓഫീസ് / തെരുവ്';

  @override
  String get hintBuildingStreet => 'കെട്ടിടം, തെരുവ്';

  @override
  String get labelOfficialDetails => 'ഔദ്യോഗിക വിവരങ്ങൾ';

  @override
  String get hintJobTitle => 'സ്ഥാനപ്പേര്';

  @override
  String get labelDepartment => 'വകുപ്പ്';

  @override
  String get hintTeam => 'സംഘം';

  @override
  String get labelEphemeralToggle => '⏱️ താൽക്കാലിക വിലാസവിവരം';

  @override
  String get descEphemeralToggle =>
      'താൽക്കാലികം. സമയമാകുമ്പോൾ സ്വയം ഇല്ലാതാകും.';

  @override
  String get labelExpiryOptions => 'കാലാവധി';

  @override
  String get labelExpiry2Hours => '2 മണിക്കൂർ';

  @override
  String get labelExpiry24Hours => '24 മണിക്കൂർ';

  @override
  String get labelExpiry7Days => '7 ദിവസം';

  @override
  String get labelExpiryAfterOneCall => 'ഒരു വിളിക്കു ശേഷം മായ്ക്കുക';

  @override
  String get descEphemeralStorage =>
      'പ്രാദേശിക SQLCipher ഡാറ്റാബേസിൽ മാത്രം സൂക്ഷിക്കുന്നു. Google-ലേക്കോ ഫോണിലെ വിലാസവിവരങ്ങളിലേക്കോ ഒരിക്കലും സമന്വയിപ്പിക്കില്ല.';

  @override
  String get labelSecretContact => 'രഹസ്യ വിലാസവിവരം';

  @override
  String get descHiddenBehindAuth => 'സ്ഥിരീകരണത്തിനു പിന്നിൽ മറച്ചിരിക്കുന്നു';

  @override
  String get titleSelectCountryCode => 'രാജ്യ കോഡ് തിരഞ്ഞെടുക്കുക';

  @override
  String get hintSearchCountry => 'രാജ്യമോ കോഡോ തിരയുക';

  @override
  String emptyNoCountriesMatch(String query) {
    return '“$query” എന്നതുമായി പൊരുത്തപ്പെടുന്ന രാജ്യങ്ങളില്ല';
  }

  @override
  String get titleSecurity => 'സുരക്ഷ';

  @override
  String get descSecurityCard =>
      'ആപ്പ് പൂട്ട്, സ്ക്രീൻഷോട്ട് തടയൽ, മാറ്റങ്ങളുടെ രേഖ';

  @override
  String get titleSpeedDial => 'വേഗ വിളി';

  @override
  String get descSpeedDialCard =>
      'സൂക്ഷിച്ച ഒരാളെ വിളിക്കാൻ കീപാഡിലെ 1-9 കീ അമർത്തിപ്പിടിക്കുക';

  @override
  String get descContactsCard => 'നിങ്ങളുടെ പ്രൊഫൈലും വിലാസവിവര ക്രമീകരണങ്ങളും';

  @override
  String get titleSyncToAnotherDevice => 'മറ്റൊരു ഉപകരണവുമായി സമന്വയം';

  @override
  String get descSyncCard =>
      'Wi-Fi വഴി വിലാസവിവരങ്ങൾ അയയ്ക്കുക അല്ലെങ്കിൽ സ്വീകരിക്കുക';

  @override
  String get titleOnlineProviderSync => 'ഓൺലൈൻ സമന്വയം';

  @override
  String get descOnlineSyncCard =>
      'Google, Microsoft, CardDAV എന്നിവയുമായി നേരിട്ടുള്ള ഇരുവശ സമന്വയം';

  @override
  String get titleBackupRestore => 'കരുതൽശേഖരം, പുനഃസ്ഥാപനം';

  @override
  String get descBackupCard =>
      'നിങ്ങളുടെ എല്ലാ വിവരങ്ങളും ഒരു ഫയലിലേക്ക് സൂക്ഷിക്കുക, അല്ലെങ്കിൽ തിരികെ കൊണ്ടുവരിക';

  @override
  String get titleEncryptedCloudBackup => 'ഗൂഢീകരിച്ച ക്ലൗഡ് കരുതൽശേഖരം';

  @override
  String get descCloudBackupCard =>
      '.csbak കരുതൽശേഖരം Google Drive, OneDrive, WebDAV എന്നിവയിലൊന്നിൽ സൂക്ഷിക്കുക';

  @override
  String get titleSimCalling => 'സിമ്മും വിളിയും';

  @override
  String get descSimCard =>
      'സ്വതവേയുള്ള സിം, വിളിക്കുന്നയാളെ തിരിച്ചറിയൽ, സ്പാം അരിക്കൽ';

  @override
  String get descRingtoneCard =>
      'ശബ്ദനില, കമ്പനം, ഓരോ സിമ്മിനുമുള്ള റിംഗ്ടോണുകൾ';

  @override
  String get titleEmergencyInfo => 'അടിയന്തര വിവരങ്ങൾ';

  @override
  String get descEmergencyCard =>
      'ലോക്ക് സ്ക്രീനിൽ ഒരു സഹായിക്ക് വായിക്കാവുന്ന കാർഡ്';

  @override
  String get titleDefaultCountry => 'സ്വതവേയുള്ള രാജ്യം';

  @override
  String descCountrySubtitle(String country) {
    return '$country · വിളിക്കുന്നവരെ തിരിച്ചറിയാൻ';
  }

  @override
  String get titleAppearance => 'രൂപഭംഗി';

  @override
  String get descAppearanceCard => 'തീം രീതിയും പ്രധാന നിറവും';

  @override
  String get titleFeatures => 'സവിശേഷതകൾ';

  @override
  String get descFeaturesCard =>
      'SreerajP Contacts Sphere-ന്റെ എല്ലാ സവിശേഷതകളും കാണുക';

  @override
  String get titlePermissions => 'അനുമതികൾ';

  @override
  String get descPermissionsCard => 'ആപ്പിന് എന്തെല്ലാം ഉപയോഗിക്കാം, എന്തിന്';

  @override
  String get titleHelp => 'സഹായം';

  @override
  String get descHelpCard =>
      'സമന്വയം പോലുള്ള സവിശേഷതകൾ എങ്ങനെ പ്രവർത്തിക്കുന്നു';

  @override
  String get titleAbout => 'ആപ്പിനെക്കുറിച്ച്';

  @override
  String get descAboutCard => 'പതിപ്പ്, രചയിതാവ്, നിർമ്മിതി വിവരങ്ങൾ';

  @override
  String get descAuthReasonSync => 'വിവരങ്ങൾ സമന്വയിപ്പിക്കാൻ സ്ഥിരീകരിക്കുക';

  @override
  String get errorAuthRequiredSync =>
      'വിവരങ്ങൾ സമന്വയിപ്പിക്കാൻ സ്ഥിരീകരണം ആവശ്യമാണ്';

  @override
  String get titleNoScreenLock => 'സ്ക്രീൻ ലോക്ക് ഇല്ല';

  @override
  String get descNoLockSync =>
      'നിങ്ങളുടെ ഉപകരണത്തിൽ സ്ക്രീൻ ലോക്ക് ഇല്ലാത്തതിനാൽ സമന്വയിപ്പിക്കുന്ന വിവരങ്ങൾ സ്ഥിരീകരണം കൊണ്ട് സംരക്ഷിക്കാനാവില്ല. ഇതിൽ രഹസ്യ വിലാസവിവരങ്ങളും ഉണ്ടാകാം. എന്നിട്ടും തുടരണോ?';

  @override
  String get descAuthReasonBackup =>
      'കരുതൽശേഖരം എടുക്കാനോ പുനഃസ്ഥാപിക്കാനോ സ്ഥിരീകരിക്കുക';

  @override
  String get errorAuthRequiredBackup =>
      'കരുതൽശേഖരത്തിനോ പുനഃസ്ഥാപനത്തിനോ സ്ഥിരീകരണം ആവശ്യമാണ്';

  @override
  String get descNoLockBackup =>
      'നിങ്ങളുടെ ഉപകരണത്തിൽ സ്ക്രീൻ ലോക്ക് ഇല്ലാത്തതിനാൽ കരുതൽശേഖരം സ്ഥിരീകരണം കൊണ്ട് സംരക്ഷിക്കാനാവില്ല. കരുതൽശേഖരത്തിൽ രഹസ്യ വിലാസവിവരങ്ങളും ഉണ്ടാകാം. എന്നിട്ടും തുടരണോ?';

  @override
  String get titleDialerTopContacts => 'ഡയലറിലെ പ്രധാനികൾ';

  @override
  String get labelMostRecent => 'ഏറ്റവും പുതിയവ';

  @override
  String get descTopRelations => 'ബന്ധുക്കളായി ബന്ധിപ്പിച്ച വിലാസവിവരങ്ങൾ';

  @override
  String get descTopLikely =>
      'ദിവസത്തിലെ ഈ സമയത്ത് സാധാരണ എടുക്കുന്നവരുടെ ക്രമത്തിൽ';

  @override
  String get descTopRecent =>
      'ഏറ്റവും കൂടുതൽ ബന്ധപ്പെട്ടവർ, പിന്നെ ഏറ്റവും പുതിയ വിളികൾ';

  @override
  String get titleDialpadScriptLayout => 'കീപാഡ് ലിപി';

  @override
  String get labelScriptAuto => 'സ്വയം (ഉപകരണ ഭാഷ)';

  @override
  String get labelScriptMalayalam => 'മലയാളം';

  @override
  String get labelScriptDevanagari => 'ദേവനാഗരി';

  @override
  String get labelScriptCyrillic => 'സിറിലിക്';

  @override
  String get labelScriptArabic => 'അറബിക് (العربية)';

  @override
  String get labelScriptGreek => 'ഗ്രീക്ക് (Ελληνικά)';

  @override
  String get labelScriptNone => 'ഇംഗ്ലീഷ് മാത്രം';

  @override
  String get descScriptAuto => 'ഉപകരണത്തിന്റെ ഭാഷ പിന്തുടരുന്നു';

  @override
  String get descScriptMalayalam => 'ഇംഗ്ലീഷും മലയാളവും ചേർന്ന വിന്യാസം (ക-ങ)';

  @override
  String get descScriptDevanagari =>
      'ഇംഗ്ലീഷും ദേവനാഗരിയും ചേർന്ന വിന്യാസം (क-ङ)';

  @override
  String get descScriptCyrillic =>
      'ഇംഗ്ലീഷും സിറിലിക്കും ചേർന്ന വിന്യാസം (АБВГ)';

  @override
  String get descScriptArabic =>
      'ഇംഗ്ലീഷും അറബിക്കും ചേർന്ന വിന്യാസം (ا ب ت ث)';

  @override
  String get descScriptGreek => 'ഇംഗ്ലീഷും ഗ്രീക്കും ചേർന്ന വിന്യാസം (ΑΒΓ)';

  @override
  String get descScriptNone => 'സാധാരണ ഇംഗ്ലീഷ് അക്ഷരങ്ങൾ മാത്രം (A-Z)';

  @override
  String get titleSync => 'സമന്വയം';

  @override
  String get labelSaveContactsTo => 'വിലാസവിവരങ്ങൾ സൂക്ഷിക്കേണ്ടത്';

  @override
  String get labelCallLog => 'വിളി രേഖ';

  @override
  String get errorSyncFailed => 'സമന്വയം പരാജയപ്പെട്ടു';

  @override
  String get labelWorking => 'പ്രവർത്തിക്കുന്നു…';

  @override
  String get errorContactsPermissionSync =>
      'സമന്വയിപ്പിക്കാൻ വിലാസവിവര അനുമതി ആവശ്യമാണ്';

  @override
  String get actionAddDeviceToApp => 'ഫോണിലെ വിലാസവിവരങ്ങൾ ആപ്പിൽ ചേർക്കുക';

  @override
  String get descAddDeviceToApp => 'ഫോണിലെ വിലാസപ്പുസ്തകം ആപ്പിലേക്ക് എടുക്കുക';

  @override
  String msgContactsSynced(int count) {
    return 'വിലാസവിവരങ്ങൾ സമന്വയിപ്പിച്ചു — $count ചേർത്തു അല്ലെങ്കിൽ നവീകരിച്ചു';
  }

  @override
  String get msgContactsUpToDate => 'വിലാസവിവരങ്ങൾ ഇതിനകം പുതുക്കിയതാണ്';

  @override
  String get actionAddAppToDevice => 'ആപ്പിലെ വിലാസവിവരങ്ങൾ ഫോണിൽ ചേർക്കുക';

  @override
  String get descAddAppToDevice => 'ആപ്പിലെ വിലാസവിവരങ്ങൾ ഫോണിലേക്ക് പകർത്തുക';

  @override
  String errorCouldNotSaveTo(String target, int failed) {
    return '$target-ൽ സൂക്ഷിക്കാനായില്ല — $failed പരാജയപ്പെട്ടു';
  }

  @override
  String get msgNoContactsToSyncToDevice =>
      'ഫോണിലേക്ക് സമന്വയിപ്പിക്കാൻ വിലാസവിവരങ്ങളില്ല';

  @override
  String msgSavedTo(String target, int total) {
    return '$target-ൽ സൂക്ഷിച്ചു — $total ചേർത്തു അല്ലെങ്കിൽ നവീകരിച്ചു';
  }

  @override
  String msgSavedToWithFailed(String target, int total, int failed) {
    return '$target-ൽ സൂക്ഷിച്ചു — $total ചേർത്തു അല്ലെങ്കിൽ നവീകരിച്ചു ($failed പരാജയപ്പെട്ടു)';
  }

  @override
  String get actionMirrorDeviceToApp => 'ഫോൺ → ആപ്പ് (മായ്ക്കലോടെ)';

  @override
  String get descMirrorDeviceToApp =>
      'ആപ്പ് ഫോണിന് സമാനമാക്കുന്നു — ഫോണിൽ ഇല്ലാത്ത ആപ്പ് വിലാസവിവരങ്ങൾ നീക്കുന്നു';

  @override
  String get titleMirrorDeviceToApp => 'ഫോൺ ആപ്പിലേക്ക് പകർത്തണോ?';

  @override
  String get descMirrorDeviceToAppConfirm =>
      'ഇത് ഫോണിലെ വിലാസവിവരങ്ങൾ ഇറക്കുമതി ചെയ്യുന്നു, പിന്നെ ഫോണിൽ നിന്ന് വന്നതും ഇപ്പോൾ അതിൽ ഇല്ലാത്തതുമായ ആപ്പ് വിലാസവിവരങ്ങൾ ഇല്ലാതാക്കുന്നു.\n\nനിങ്ങളുടെ \"ഞാൻ\" വിലാസവിവരം, രഹസ്യ വിലാസവിവരങ്ങൾ, ആപ്പിൽ മാത്രം സൃഷ്ടിച്ച വിലാസവിവരങ്ങൾ എന്നിവ ഒരിക്കലും ഇല്ലാതാക്കില്ല.';

  @override
  String get actionMirror => 'പകർത്തുക';

  @override
  String msgMirroredFromDevice(int removed) {
    return 'ഫോണിൽ നിന്ന് പകർത്തി — $removed നീക്കി';
  }

  @override
  String get msgMirroredFromDeviceNone =>
      'ഫോണിൽ നിന്ന് പകർത്തി — നീക്കാൻ ഒന്നുമില്ല';

  @override
  String get actionMirrorAppToDevice => 'ആപ്പ് → ഫോൺ (മായ്ക്കലോടെ)';

  @override
  String get descMirrorAppToDevice =>
      'ഫോൺ ആപ്പിന് സമാനമാക്കുന്നു — ആപ്പിൽ ഇല്ലാത്ത ഫോൺ വിലാസവിവരങ്ങൾ നീക്കുന്നു';

  @override
  String get titleMirrorAppToDevice => 'ആപ്പ് ഫോണിലേക്ക് പകർത്തണോ?';

  @override
  String get descMirrorAppToDeviceConfirm =>
      'ഇത് ആപ്പിലെ വിലാസവിവരങ്ങൾ ഫോണിലേക്ക് പകർത്തുന്നു, പിന്നെ ആപ്പിൽ ഇല്ലാത്ത ഫോൺ വിലാസവിവരങ്ങൾ ഇല്ലാതാക്കുന്നു.\n\nനിങ്ങളുടെ \"ഞാൻ\" വിലാസവിവരവുമായോ ഒരു രഹസ്യ വിലാസവിവരവുമായോ ചേരുന്ന ഫോൺ വിലാസവിവരങ്ങൾ ഒരിക്കലും ഇല്ലാതാക്കില്ല.';

  @override
  String msgMirroredTo(String target, int removed) {
    return '$target-ലേക്ക് പകർത്തി — $removed നീക്കി';
  }

  @override
  String msgMirroredToNone(String target) {
    return '$target-ലേക്ക് പകർത്തി — നീക്കാൻ ഒന്നുമില്ല';
  }

  @override
  String get actionImportCallLog => 'ഫോണിലെ വിളി രേഖ ആപ്പിൽ ചേർക്കുക';

  @override
  String get descImportCallLog =>
      'ഫോണിലെ പഴയ വിളി ചരിത്രം സമീപകാലം എന്നതിലേക്ക് ഇറക്കുമതി ചെയ്യുക';

  @override
  String get errorCouldNotReadCallLog =>
      'ഫോണിലെ വിളി രേഖ വായിക്കാനായില്ല — Android ക്രമീകരണങ്ങളിൽ “കോൾ ലോഗുകൾ” അനുമതി അനുവദിക്കുക';

  @override
  String get msgCallLogUpToDate => 'വിളി രേഖ ഇതിനകം പുതുക്കിയതാണ്';

  @override
  String labelCountAdded(int count) {
    return '$count ചേർത്തു';
  }

  @override
  String labelCountUpdated(int count) {
    return '$count നവീകരിച്ചു';
  }

  @override
  String msgCallLogImported(String parts) {
    return 'വിളി രേഖ ഇറക്കുമതി ചെയ്തു — $parts';
  }

  @override
  String get actionReplaceCallLog => 'വിളി രേഖ ഫോണിൽ നിന്ന് (മായ്ക്കലോടെ)';

  @override
  String get descReplaceCallLog =>
      'സമീപകാലം ഫോണിലെ വിളി ചരിത്രം കൊണ്ട് മാറ്റുക';

  @override
  String get titleReplaceCallHistory => 'വിളികളുടെ നാൾവഴി മാറ്റണോ?';

  @override
  String get descReplaceCallHistoryConfirm =>
      'ഇത് ആപ്പിലെ വിളികളുടെ നാൾവഴി മായ്ച്ച് ഫോണിലെ വിളി രേഖയിൽ നിന്ന് വീണ്ടും നിർമ്മിക്കുന്നു. ആപ്പിൽ സൂക്ഷിച്ച വിളി കുറിപ്പുകളും പ്രതികരണങ്ങളും നഷ്ടപ്പെടും.';

  @override
  String get actionReplace => 'മാറ്റിസ്ഥാപിക്കുക';

  @override
  String msgCallLogReplaced(int count) {
    return 'വിളി രേഖ മാറ്റി — $count ചേർത്തു';
  }

  @override
  String get labelContactCountsIndex => 'എണ്ണവും തിരച്ചിൽ സൂചികയും';

  @override
  String get descContactCountsIndex =>
      'ഫോണിലെയും ആപ്പിലെയും വിലാസവിവരങ്ങളുടെ എണ്ണവും തിരച്ചിൽ സൂചികയുടെ നിലയും കാണുക';

  @override
  String get labelMyProfileAddMe => 'എന്റെ പ്രൊഫൈൽ';

  @override
  String get descMyProfileAddMe =>
      'നിങ്ങളുടെ സ്വന്തം വിലാസവിവര കാർഡ് സൃഷ്ടിക്കുക അല്ലെങ്കിൽ തിരുത്തുക';

  @override
  String get labelDisplayFormatting => 'പ്രദർശനവും രൂപവും';

  @override
  String get descDisplayFormatting => 'ക്രമം, പേരിന്റെ രൂപം, പ്രദർശന അരിപ്പകൾ';

  @override
  String get labelDeviceCloudSync => 'ഫോൺ, ക്ലൗഡ് സമന്വയം';

  @override
  String get descDeviceCloudSync =>
      'ഫോൺ പകർപ്പും ക്ലൗഡ് അക്കൗണ്ടുകളും ക്രമീകരിക്കുക';

  @override
  String get labelCustomRelationshipLabels => 'സ്വന്തം ബന്ധപ്പേരുകൾ';

  @override
  String get descCustomRelationshipLabels =>
      'വിലാസവിവരങ്ങൾക്കുള്ള സ്വന്തം ബന്ധപ്പേരുകൾ നിയന്ത്രിക്കുക';

  @override
  String get descBlockedNumbersCard =>
      'റിംഗ് ചെയ്യാതെ തടഞ്ഞ നമ്പറുകൾ കാണുകയും നിയന്ത്രിക്കുകയും ചെയ്യുക';

  @override
  String get labelSecretContactsExport => 'രഹസ്യ വിലാസവിവരങ്ങളും കയറ്റുമതിയും';

  @override
  String get descSecretContactsExport =>
      'കയറ്റുമതി ക്രമീകരണങ്ങളും രഹസ്യ വിലാസവിവര കയറ്റുമതി നിയന്ത്രണങ്ങളും';

  @override
  String msgSyncedWith(String name) {
    return '$name-മായി വിജയകരമായി സമന്വയിപ്പിച്ചു';
  }

  @override
  String get msgSyncCompleted => 'സമന്വയം പൂർത്തിയായി';

  @override
  String get titleAddOnlineAccount => 'ഓൺലൈൻ അക്കൗണ്ട് ചേർക്കുക';

  @override
  String get labelProvider => 'സേവനദാതാവ്';

  @override
  String get labelAccountEmailName => 'അക്കൗണ്ട് ഇമെയിൽ / പേര്';

  @override
  String get labelServerUrl => 'സെർവർ URL';

  @override
  String get labelUsername => 'ഉപയോക്തൃനാമം';

  @override
  String get labelAccount => 'അക്കൗണ്ട്';

  @override
  String get descOnlineSyncIntro =>
      'Google, Microsoft, CardDAV എന്നിവയുമായി നിങ്ങൾ തിരഞ്ഞെടുത്താൽ മാത്രമുള്ള ഇരുവശ സമന്വയം. വിവരശേഖരണമില്ല, നേരിട്ടുള്ള API അഭ്യർത്ഥനകൾ മാത്രം.';

  @override
  String get labelConfiguredProviders => 'ക്രമീകരിച്ച സേവനദാതാക്കൾ';

  @override
  String get actionAddAccount => 'അക്കൗണ്ട് ചേർക്കുക';

  @override
  String get emptyNoCloudAccounts =>
      'ക്ലൗഡ് സമന്വയ അക്കൗണ്ടുകളൊന്നും ക്രമീകരിച്ചിട്ടില്ല.';

  @override
  String descProviderLastSynced(String provider, String when) {
    return 'സേവനദാതാവ്: $provider\nഅവസാനം സമന്വയിപ്പിച്ചത്: $when';
  }

  @override
  String get labelNever => 'ഒരിക്കലുമില്ല';

  @override
  String get tooltipSyncNow => 'ഇപ്പോൾ സമന്വയിപ്പിക്കുക';

  @override
  String get labelSimCardsAccounts => 'സിം കാർഡുകളും അക്കൗണ്ടുകളും';

  @override
  String get descSimCardsAccounts =>
      'സ്വതവേയുള്ള സിം, ഓരോ വിളിക്കും ചോദിക്കൽ, സിം നിറങ്ങൾ';

  @override
  String get labelIdentification => 'തിരിച്ചറിയൽ';

  @override
  String get descIdentification =>
      'വിളിക്കുന്നയാളെ തിരിച്ചറിയലും സ്പാം അരിക്കലും';

  @override
  String get labelSpokenAnnouncement => 'വിളിക്കുന്നയാളുടെ പേര് പറയൽ';

  @override
  String get descSpokenAnnouncement =>
      'റിംഗ്ടോണിനൊപ്പം വിളിക്കുന്നയാളുടെ പേര് പറയുക';

  @override
  String get labelTierQuietHours => 'ബന്ധനില അനുസരിച്ച് നിശ്ശബ്ദ സമയം';

  @override
  String get descTierQuietHours =>
      'തിരഞ്ഞെടുത്ത ബന്ധനിലകൾ ഒഴികെ രാത്രിയിലെ വിളികൾ നിശ്ശബ്ദമാക്കുക';

  @override
  String get labelQuickReplies => 'പെട്ടെന്നുള്ള മറുപടികൾ';

  @override
  String get descQuickReplies =>
      'ഒരു വിളി സന്ദേശത്തോടെ നിരസിക്കുമ്പോൾ നൽകുന്ന സന്ദേശങ്ങൾ';

  @override
  String get labelPostCallOptions => 'വിളിക്കു ശേഷമുള്ള ക്രമീകരണങ്ങൾ';

  @override
  String get descPostCallOptions =>
      'വിളിക്കു ശേഷമുള്ള പ്രതികരണ ഷീറ്റ് ക്രമീകരിക്കുക';

  @override
  String get titleSmartRedialReachMe => 'വീണ്ടും വിളി, സന്ദേശം';

  @override
  String get descSmartRedialCard =>
      'വിളിക്ക് മറുപടിയില്ലാത്തപ്പോൾ സ്വയം വീണ്ടും വിളിയും സന്ദേശവും';

  @override
  String get descSmartRedialIntro =>
      'വിളിക്ക് മറുപടിയില്ലാത്തപ്പോൾ ഒറ്റ ടാപ്പിൽ സ്വയം വീണ്ടും വിളിയും സന്ദേശവും നൽകുക';

  @override
  String get labelDefaultRetryDelay => 'സ്വതവേയുള്ള കാത്തിരിപ്പ്';

  @override
  String get labelPresetReachMe => 'മുൻകൂട്ടിയുള്ള സന്ദേശം';

  @override
  String get labelActiveScheduledRedials => 'സജീവ വീണ്ടും വിളികൾ';

  @override
  String labelActiveCount(int count) {
    return '$count സജീവം';
  }

  @override
  String labelMinutesLong(int count) {
    return '$count മിനിറ്റ്';
  }

  @override
  String get hintPresetReachMe => 'മുൻകൂട്ടിയുള്ള സന്ദേശം എഴുതുക...';

  @override
  String get titleActiveAutoRedials => 'സജീവ സ്വയം വിളികൾ';

  @override
  String get emptyNoActiveRedials => 'സജീവമായ വീണ്ടും വിളികളൊന്നുമില്ല.';

  @override
  String labelRedialIn(String number, int minutes) {
    return '$number · $minutes മിനിറ്റിൽ';
  }

  @override
  String get errorEnterPassphrase => 'കരുതൽശേഖരത്തിനുള്ള രഹസ്യവാക്യം നൽകുക';

  @override
  String msgBackupUploadedFile(String file) {
    return 'ഗൂഢീകരിച്ച കരുതൽശേഖരം വിജയകരമായി അപ്‌ലോഡ് ചെയ്തു: $file';
  }

  @override
  String get msgBackupUploaded => 'കരുതൽശേഖരം അപ്‌ലോഡ് ചെയ്തു';

  @override
  String errorUploadFailed(String error) {
    return 'അപ്‌ലോഡ് പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get descCloudBackupIntro =>
      'ആപ്പിലെ എല്ലാ വിവരങ്ങളും (.csbak) നിങ്ങളുടെ രഹസ്യവാക്യം ഉപയോഗിച്ച് PBKDF2 (300k ആവർത്തനങ്ങൾ) + AES-GCM-256 വഴി ഗൂഢീകരിച്ച് നിങ്ങളുടെ ക്ലൗഡ് സംഭരണത്തിൽ സൂക്ഷിക്കുന്നു.';

  @override
  String get emptyNoCloudStorage =>
      'ക്ലൗഡ് സംഭരണ അക്കൗണ്ടുകളൊന്നും ക്രമീകരിച്ചിട്ടില്ല.';

  @override
  String get actionAddAccountInProviderSync =>
      'ഓൺലൈൻ സമന്വയത്തിൽ അക്കൗണ്ട് ചേർക്കുക';

  @override
  String get labelTargetCloudAccount => 'ലക്ഷ്യ ക്ലൗഡ് അക്കൗണ്ട്';

  @override
  String get labelEncryptionPassphrase => 'ഗൂഢീകരണ രഹസ്യവാക്യം';

  @override
  String get hintPassphrase => '.csbak ഗൂഢീകരണത്തിനുള്ള രഹസ്യവാക്യം നൽകുക';

  @override
  String get actionUploadBackupNow => 'ഇപ്പോൾ അപ്‌ലോഡ് ചെയ്യുക';

  @override
  String get labelRemoteCloudBackups => 'ക്ലൗഡിലെ കരുതൽശേഖരങ്ങൾ';

  @override
  String get emptyNoCloudBackups =>
      'ഈ അക്കൗണ്ടിൽ ക്ലൗഡ് കരുതൽശേഖരങ്ങളൊന്നും കണ്ടെത്തിയില്ല.';

  @override
  String descBackupSizeDate(int bytes, String date) {
    return 'വലുപ്പം: $bytes ബൈറ്റ് | തീയതി: $date';
  }

  @override
  String get labelCallerIdentification => 'വിളിക്കുന്നയാളെ തിരിച്ചറിയൽ';

  @override
  String get descCallerIdentification =>
      'നിങ്ങളുടെ വിലാസവിവരങ്ങളിൽ ഇല്ലാത്ത വിളിക്കുന്നവരെ അടയാളപ്പെടുത്തുക — ടെലിമാർക്കറ്റിംഗ്, സേവന നമ്പറുകൾ, നിങ്ങൾ സ്പാം ആയി അടയാളപ്പെടുത്തിയ നമ്പറുകൾ';

  @override
  String get labelFilterSuspectedSpam => 'സംശയമുള്ള സ്പാം അരിക്കുക';

  @override
  String get descFilterSpam =>
      'സംശയമുള്ള സ്പാം വിളികൾ ശബ്ദമില്ലാതെ വരും. അവ ഇപ്പോഴും സമീപകാലത്തിൽ കാണാം, എടുക്കുകയും ചെയ്യാം';

  @override
  String get labelHowIdentificationWorks => 'തിരിച്ചറിയൽ എങ്ങനെ';

  @override
  String get descHowIdentificationWorks =>
      'തിരിച്ചറിയൽ നിങ്ങളുടെ ഫോണിൽ തന്നെ നടക്കുന്നു — ഒന്നും എവിടേക്കും അയയ്ക്കുന്നില്ല. രജിസ്റ്റർ ചെയ്ത ടെലിമാർക്കറ്റിംഗ് (140…), സേവന (160…) നമ്പർ ശ്രേണികളും സമീപകാലത്തിൽ നിന്ന് നിങ്ങൾ സ്പാം ആയി അടയാളപ്പെടുത്തിയ നമ്പറുകളും SreerajP Contacts Sphere തിരിച്ചറിയുന്നു; വിളിക്കുന്നയാളുടെ നമ്പർ സ്ഥിരീകരിക്കാനായില്ലെന്ന് നെറ്റ്‌വർക്ക് അറിയിക്കുമ്പോൾ മുന്നറിയിപ്പും കാണിക്കുന്നു.\n\nമൊബൈൽ നെറ്റ്‌വർക്കുകൾ വിളിക്കുന്നയാളുടെ നമ്പർ മാത്രമേ നൽകൂ, പേര് നൽകില്ല; അതിനാൽ നിങ്ങളുടെ വിലാസവിവരങ്ങൾക്ക് പുറത്തുള്ളവരെ പേരുകൊണ്ട് തിരിച്ചറിയാനാവില്ല. സ്പാം അരിക്കലിന് SreerajP Contacts Sphere നിങ്ങളുടെ സ്വതവേയുള്ള ഫോൺ ആപ്പ് ആയിരിക്കണം.';

  @override
  String get titleAccentColor => 'പ്രധാന നിറം';

  @override
  String get labelLivePreview => 'തത്സമയ കാഴ്ച';

  @override
  String get labelSampleText => 'മാതൃകാ വാചകം';

  @override
  String get labelPresets => 'മുൻനിശ്ചിതങ്ങൾ';

  @override
  String get labelCustomColorWheel => 'സ്വന്തം നിറചക്രം';

  @override
  String get actionResetDarkToDefault => 'ഇരുണ്ട രൂപം പഴയപടിയാക്കുക';

  @override
  String get actionResetLightToDefault => 'തെളിഞ്ഞ രൂപം പഴയപടിയാക്കുക';

  @override
  String get descContrastAuto =>
      'വായനാസൗകര്യത്തിനായി വാചകത്തിന്റെ തെളിച്ചം സ്വയം ക്രമീകരിക്കുന്നു.';

  @override
  String get labelSortOrder => 'ക്രമം';

  @override
  String get descSortOrder => 'പട്ടികകളിൽ വിലാസവിവരങ്ങൾ ക്രമീകരിക്കുന്ന രീതി';

  @override
  String get labelFirstName => 'ആദ്യ പേര്';

  @override
  String get labelHideNoPhone => 'ഫോൺ നമ്പറില്ലാത്തവ മറയ്ക്കുക';

  @override
  String get descHideNoPhone =>
      'ഇമെയിലോ വിലാസമോ മാത്രമുള്ള വിലാസവിവരങ്ങൾ പ്രധാന പട്ടികയിൽ കാണിക്കില്ല';

  @override
  String get titleThemeMode => 'തീം രീതി';

  @override
  String get labelLight => 'തെളിഞ്ഞ രൂപം';

  @override
  String get labelDark => 'ഇരുണ്ട രൂപം';

  @override
  String get labelSystem => 'സിസ്റ്റം';

  @override
  String get descSystemTheme =>
      'സിസ്റ്റം രീതി നിങ്ങളുടെ ഉപകരണത്തിന്റെ ഇരുണ്ട രൂപ ക്രമീകരണം സ്വയം പിന്തുടരുന്നു.';

  @override
  String get labelVolumeVibration => 'ശബ്ദനിലയും കമ്പനവും';

  @override
  String get descVolumeVibration =>
      'റിംഗ്ടോൺ ശബ്ദനിലയും വരുന്ന വിളികളുടെ കമ്പനവും';

  @override
  String get labelPerSimRingtones => 'ഓരോ സിമ്മിനും റിംഗ്ടോൺ';

  @override
  String get descPerSimRingtones =>
      'ഓരോ സിമ്മിലും വരുന്ന വിളികൾക്ക് വെവ്വേറെ റിംഗ്ടോണുകൾ നൽകുക';

  @override
  String get titleTypography => 'അക്ഷരരൂപവും വലുപ്പവും';

  @override
  String get labelFont => 'അക്ഷരരൂപം';

  @override
  String get labelTextSize => 'അക്ഷരവലുപ്പം';

  @override
  String get labelScaleSmall => 'ചെറുത്';

  @override
  String get labelScaleDefault => 'സ്വതവേ';

  @override
  String get labelScaleLarge => 'വലുത്';

  @override
  String get labelScaleLarger => 'കൂടുതൽ വലുത്';

  @override
  String get titleScreenshotGuard => 'സ്ക്രീൻഷോട്ട് സംരക്ഷണം';

  @override
  String get labelBlockScreenshots => 'സ്ക്രീൻഷോട്ടുകൾ തടയുക';

  @override
  String get descBlockScreenshots =>
      'വിലാസവിവരങ്ങളും വിളികളും സ്ക്രീൻഷോട്ടുകളിലും സ്ക്രീൻ റെക്കോർഡിങ്ങുകളിലും സമീപകാല ആപ്പ് കാഴ്ചയിലും വരാതെ സൂക്ഷിക്കുന്നു';

  @override
  String get featureC0Name => 'സ്മാർട്ട് ഡയലറും വിളിയും';

  @override
  String get featureC0Subtitle =>
      'വേഗമേറിയ T9 തിരച്ചിൽ, ഇരട്ട-സിം നിയന്ത്രണങ്ങൾ, ബുദ്ധിപരമായ വിളി സൗകര്യങ്ങൾ';

  @override
  String get featureC0F0Title => 'ബഹുലിപി T9 കീപാഡ് തിരച്ചിൽ';

  @override
  String get featureC0F0Desc =>
      'ഡയൽപാഡിൽ അക്കങ്ങളോ അക്ഷരങ്ങളോ ടൈപ്പ് ചെയ്ത് നിമിഷനേരം കൊണ്ട് വിലാസവിവരങ്ങൾ തിരയുക. ഇംഗ്ലീഷ്, മലയാളം (സ്വരങ്ങളും ചില്ലക്ഷരങ്ങളും ഉൾപ്പെടെ), ദേവനാഗരി തുടങ്ങിയവ പൂർണ്ണമായി പിന്തുണയ്ക്കുന്നു.';

  @override
  String get featureC0F0H0 => 'ഇംഗ്ലീഷും മലയാളവും';

  @override
  String get featureC0F0H1 => 'ബഹുലിപി ലിപ്യന്തരണം';

  @override
  String get featureC0F0H2 => 'ഏതു രീതിയിലും പേരുകൾ കണ്ടെത്തുന്നു';

  @override
  String get featureC0F1Title => 'വേഗ വിളി';

  @override
  String get featureC0F1Desc =>
      'കീപാഡിലെ 1 മുതൽ 9 വരെയുള്ള കീകളിൽ ഒരാളെ സൂക്ഷിക്കുക, തുടർന്ന് ആ കീ അമർത്തിപ്പിടിച്ച് അവരെ വിളിക്കുക. നമ്പർ പെട്ടി ശൂന്യമായിരിക്കുമ്പോഴാണ് അമർത്തിപ്പിടിക്കൽ പ്രവർത്തിക്കുക; നൽകിയ കീകളിൽ ചെറിയൊരു കുത്ത് കാണാം. രഹസ്യ വിലാസവിവരങ്ങൾ ഒരിക്കലും ഒരു കീയിൽ വയ്ക്കാനാവില്ല.';

  @override
  String get featureC0F1H0 => '1-9 കീകൾ';

  @override
  String get featureC0F1H1 => 'കീ അമർത്തിപ്പിടിച്ച് വിളിക്കുക';

  @override
  String get featureC0F1H2 => 'കീപാഡിൽ നിന്നോ ക്രമീകരണങ്ങളിൽ നിന്നോ നൽകാം';

  @override
  String get featureC0F2Title => 'ശബ്ദം വഴി വിളി';

  @override
  String get featureC0F2Desc =>
      'ഡയൽപാഡിലെ മൈക്രോഫോൺ തൊട്ട് ഒരു നമ്പറോ പേരോ പറയുക. നിങ്ങളുടെ ഫോണിൽ തന്നെ, ഇംഗ്ലീഷിലോ മലയാളത്തിലോ, സംസാരം വാചകമാക്കുന്നു; \"വിളിക്കുക\" പോലുള്ള തുടക്ക വാക്കുകൾ സ്വയം ഒഴിവാക്കുന്നു.';

  @override
  String get featureC0F2H0 => 'നമ്പറോ പേരോ പറയുക';

  @override
  String get featureC0F2H1 => 'ഇംഗ്ലീഷും മലയാളവും';

  @override
  String get featureC0F2H2 => 'ഫോണിൽ തന്നെയുള്ള ശബ്ദതിരിച്ചറിയൽ';

  @override
  String get featureC0F3Title => 'തിരുത്താവുന്ന ഡയലറും കൃത്യമായ തിരുത്തലും';

  @override
  String get featureC0F3Desc =>
      'ടൈപ്പ് ചെയ്ത നമ്പറിൽ എവിടെയും തൊട്ട് കഴ്സർ നീക്കുക, അക്കങ്ങൾ തിരഞ്ഞെടുക്കുക, ഫോൺ നമ്പറുകൾ എളുപ്പത്തിൽ പകർത്തുക, ഒട്ടിക്കുക.';

  @override
  String get featureC0F3H0 => 'കഴ്സർ സ്ഥാനം';

  @override
  String get featureC0F3H1 => 'നമ്പറുകൾ ഒട്ടിക്കുക';

  @override
  String get featureC0F3H2 => 'കഴ്സറിൽ നിന്ന് മായ്ക്കൽ';

  @override
  String get featureC0F4Title => 'പ്രധാന വിലാസവിവരങ്ങളിലേക്ക് വേഗം';

  @override
  String get featureC0F4Desc =>
      'ഒറ്റ ടാപ്പിൽ വിളിക്കാൻ ഡയൽപാഡിന് തൊട്ടുമുകളിൽ ഒരു നിര. അതിൽ എന്ത് വരണമെന്ന് തിരഞ്ഞെടുക്കുക: ഏറ്റവും കൂടുതൽ ബന്ധപ്പെടുന്നവർ, നിങ്ങൾ ബന്ധിപ്പിച്ച കുടുംബവും സുഹൃത്തുക്കളും, അല്ലെങ്കിൽ ദിവസത്തിലെ ഈ സമയത്ത് സാധാരണ എടുക്കുന്നവർ.';

  @override
  String get featureC0F4H0 => 'പ്രിയപ്പെട്ടവരുടെ നിര';

  @override
  String get featureC0F4H1 => 'കുടുംബവും സുഹൃത്തുക്കളും മാത്രം';

  @override
  String get featureC0F4H2 => 'ഇപ്പോൾ എടുക്കാൻ സാധ്യതയുള്ളവർ';

  @override
  String get featureC0F5Title => 'ഇരട്ട-സിം വിളി നിയന്ത്രണങ്ങൾ';

  @override
  String get featureC0F5Desc =>
      'ഓരോ വിളിക്കും സിം 1-ഓ സിം 2-ഓ തിരഞ്ഞെടുക്കുക, അല്ലെങ്കിൽ ഓരോ തവണയും ചോദിക്കാതിരിക്കാൻ ഒരു സ്വതവേയുള്ള സിം നിശ്ചയിക്കുക. ഓരോ വിലാസവിവരത്തിനും സ്വന്തം ഇഷ്ട സിമ്മും വയ്ക്കാം, അത് സ്വതവേയുള്ളതിനേക്കാൾ മുൻഗണന നേടും. ഓരോ സിമ്മിനും സ്വന്തം നിറമുണ്ട്, ഏത് സിമ്മാണ് ഉപയോഗിച്ചതെന്ന് സമീപകാലം കാണിക്കുന്നു.';

  @override
  String get featureC0F5H0 => 'സിം 1 / സിം 2 തിരഞ്ഞെടുക്കൽ';

  @override
  String get featureC0F5H1 => 'സ്വതവേയുള്ള സിം അല്ലെങ്കിൽ ഓരോ തവണയും ചോദിക്കൽ';

  @override
  String get featureC0F5H2 => 'ഓരോ വിലാസവിവരത്തിനും ഇഷ്ട സിം';

  @override
  String get featureC0F5H3 => 'സമീപകാലത്തിൽ സിം കാണിക്കുന്നു';

  @override
  String get featureC0F6Title => 'സ്മാർട്ട് റീഡയലും \"ബന്ധപ്പെടാൻ\" രീതിയും';

  @override
  String get featureC0F6Desc =>
      'ഒരു വിളിക്ക് മറുപടിയില്ലാതിരിക്കുകയോ തിരക്കിലാവുകയോ ചെയ്യുമ്പോൾ, നിങ്ങൾ തിരഞ്ഞെടുക്കുന്ന സമയത്തിനു ശേഷം വീണ്ടും വിളിക്കാൻ ക്രമീകരിക്കുക, അല്ലെങ്കിൽ ഒറ്റ ടാപ്പിൽ മുൻകൂട്ടി തയ്യാറാക്കിയ \"ബന്ധപ്പെടാൻ ശ്രമിക്കുന്നു\" സന്ദേശം അയയ്ക്കുക.';

  @override
  String get featureC0F6H0 => 'നിങ്ങളുടെ സമയത്തിനു ശേഷം വീണ്ടും വിളി';

  @override
  String get featureC0F6H1 => 'ഒറ്റ ടാപ്പ് SMS';

  @override
  String get featureC0F6H2 => 'കാത്തിരിക്കുന്ന വിളി റദ്ദാക്കുക';

  @override
  String get featureC0F7Title => 'വിളിക്കുന്നയാളുടെ പേര് ഉറക്കെ';

  @override
  String get featureC0F7Desc =>
      'ഫോൺ റിംഗ് ചെയ്യുമ്പോൾ സൂക്ഷിച്ച വിളിക്കുന്നയാളുടെ പേര് ഉറക്കെ കേൾക്കാം — വാഹനമോടിക്കുമ്പോഴോ ഹെഡ്‌ഫോൺ ധരിക്കുമ്പോഴോ ഉത്തമം. മലയാളം പേര് മലയാളത്തിൽ തന്നെ പറയുന്നു.';

  @override
  String get featureC0F7H0 => 'ശബ്ദത്തിലൂടെ തിരിച്ചറിയൽ';

  @override
  String get featureC0F7H1 => 'മലയാളത്തിൽ പേര് പറയൽ';

  @override
  String get featureC0F7H2 => 'നിശ്ശബ്ദ സമയത്തിനുള്ള ഒഴിവ്';

  @override
  String get featureC0F8Title => 'വേഗത്തിൽ നിരസിക്കാനുള്ള SMS മറുപടികൾ';

  @override
  String get featureC0F8Desc =>
      '\"മീറ്റിംഗിലാണ്, ഉടൻ തിരികെ വിളിക്കാം\" പോലുള്ള മുൻകൂട്ടി തയ്യാറാക്കിയ ഒറ്റ ടാപ്പ് SMS സന്ദേശങ്ങളോടെ വരുന്ന വിളികൾ മാന്യമായി നിരസിക്കുക.';

  @override
  String get featureC0F8H0 => 'ഒറ്റ ടാപ്പിൽ നിരസിക്കൽ SMS';

  @override
  String get featureC0F8H1 => 'സ്വന്തം ചെറു മാതൃകകൾ';

  @override
  String get featureC0F8H2 => 'ഉടനടി അയയ്ക്കൽ';

  @override
  String get featureC1Name => 'വിളിക്കിടയിലും വിളിക്കുന്നയാളെക്കുറിച്ചും';

  @override
  String get featureC1Subtitle =>
      'വിശദമായ പശ്ചാത്തലവും സുഗമമായ വിളി നിയന്ത്രണങ്ങളും കൊണ്ട് ആരാണ് വിളിക്കുന്നതെന്ന് അറിയുക';

  @override
  String get featureC1F0Title => 'ആധുനിക വിളി സ്ക്രീനും കോൺഫറൻസ് വിളിയും';

  @override
  String get featureC1F0Desc =>
      'നിശ്ശബ്ദമാക്കൽ, ഉച്ചഭാഷിണി, വിളി കാത്തുനിർത്തൽ, അക്ക കീപാഡ്, സജീവ വിളികൾ മാറ്റൽ, പല ആളുകളുമായുള്ള കോൺഫറൻസ് വിളികൾ ലയിപ്പിക്കൽ എന്നിവയുള്ള മനോഹരമായ വിളി സ്ക്രീൻ.';

  @override
  String get featureC1F0H0 => 'സ്പീക്കറും നിശ്ശബ്ദമാക്കലും';

  @override
  String get featureC1F0H1 => 'കാത്തുനിർത്തലും മാറ്റലും';

  @override
  String get featureC1F0H2 => 'കോൺഫറൻസ് ലയനം';

  @override
  String get featureC1F0H3 => 'മുഴുവൻ സ്ക്രീനിൽ വരുന്ന വിളി';

  @override
  String get featureC1F1Title => 'ബന്ധ പശ്ചാത്തല കാർഡുകൾ';

  @override
  String get featureC1F1Desc =>
      'ഫോൺ റിംഗ് ചെയ്യുമ്പോൾ തന്നെ വിളിക്കുന്നയാളുടെ ബന്ധ അടയാളം, അവസാനം സംസാരിച്ചിട്ട് എത്ര നാളായി, സ്വകാര്യ കുറിപ്പുകൾ, വരാനിരിക്കുന്ന ജന്മദിനങ്ങൾ എന്നിവ കാണുക.';

  @override
  String get featureC1F1H0 => 'ബന്ധ അടയാളം';

  @override
  String get featureC1F1H1 => 'അവസാനം സംസാരിച്ച ദിവസങ്ങൾ';

  @override
  String get featureC1F1H2 => 'കുറിപ്പുകൾ ഉടനടി';

  @override
  String get featureC1F2Title => 'വിളിക്കുന്നതിനു മുമ്പുള്ള സംഗ്രഹം';

  @override
  String get featureC1F2Desc =>
      'ഒരാളെ വിളിക്കുന്നതിനു മുമ്പ്, അവസാനം എപ്പോൾ സംസാരിച്ചു, ആ വിളി എത്ര നേരം നീണ്ടു, നിങ്ങൾ എന്ത് കുറിച്ചു, വിലാസം സൂക്ഷിച്ചിട്ടുണ്ടെങ്കിൽ അവരുടെ നഗരത്തിലെ പ്രാദേശിക സമയം എന്നിവ കാണുക.';

  @override
  String get featureC1F2H0 => 'വീണ്ടും ബന്ധപ്പെടാനുള്ള ഓർമ്മപ്പെടുത്തൽ';

  @override
  String get featureC1F2H1 => 'അവരുടെ പ്രാദേശിക സമയം';

  @override
  String get featureC1F2H2 => 'ഇടപെടലുകളുടെ സമയരേഖ';

  @override
  String get featureC1F3Title => 'വിളിക്കു ശേഷമുള്ള കുറിപ്പുകളും ശബ്ദ എഴുത്തും';

  @override
  String get featureC1F3Desc =>
      'ഫോൺ വച്ചയുടൻ, കീബോർഡ് ഉപയോഗിച്ചോ ഉറക്കെ പറഞ്ഞ് സ്വയം വാചകമാക്കിയോ, സംസാരിച്ച കാര്യം വേഗം കുറിച്ചുവയ്ക്കുക.';

  @override
  String get featureC1F3H0 => 'ശബ്ദത്തിൽ നിന്ന് വാചകം';

  @override
  String get featureC1F3H1 => 'വിളിക്കു ശേഷമുള്ള ചോദ്യം';

  @override
  String get featureC1F3H2 => 'തുടർ ഓർമ്മപ്പെടുത്തൽ';

  @override
  String get featureC2Name => 'വിലാസവിവര പരിപാലനവും ബന്ധങ്ങളും';

  @override
  String get featureC2Subtitle =>
      'നിങ്ങളുടെ ബന്ധങ്ങളെ അർത്ഥമുള്ള വലയങ്ങളായി ക്രമീകരിക്കുക';

  @override
  String get featureC2F0Title => 'വിശദമായ വിലാസവിവര പ്രൊഫൈലുകൾ';

  @override
  String get featureC2F0Desc =>
      'പല ഫോൺ നമ്പറുകൾ, ഇമെയിലുകൾ, വീട്/ജോലി വിലാസങ്ങൾ, ജന്മദിനങ്ങൾ, വിവാഹ വാർഷികങ്ങൾ, സോഷ്യൽ ലിങ്കുകൾ, ഔദ്യോഗിക വിവരങ്ങൾ, ഉച്ചാരണ പേരുകൾ എന്നിവ സൂക്ഷിക്കുക.';

  @override
  String get featureC2F0H0 => 'പല ഫോണും ഇമെയിലും';

  @override
  String get featureC2F0H1 => 'ജന്മദിന ഓർമ്മപ്പെടുത്തലുകൾ';

  @override
  String get featureC2F0H2 => 'സ്വന്തം പേരുകൾ';

  @override
  String get featureC2F1Title => '7 ബന്ധ വലയങ്ങൾ';

  @override
  String get featureC2F1Desc =>
      'നിങ്ങൾ സൂക്ഷിക്കുന്ന ഓരോ ബന്ധവും ഏഴ് വിഭാഗങ്ങളിൽ ഒന്നിലാണ്: അടുത്ത കുടുംബം, വിശാല കുടുംബം, വിവാഹബന്ധുക്കൾ, തൊഴിൽ, വിദ്യാഭ്യാസം, സാമൂഹികം, സേവനം. അതിനുള്ളിലെ പേര് — \"അച്ഛൻ\", \"മാനേജർ\" — നിങ്ങൾ ടൈപ്പ് ചെയ്യുന്നതെന്തോ അതാണ്.';

  @override
  String get featureC2F1H0 => 'ഏഴ് സ്ഥിര വിഭാഗങ്ങൾ';

  @override
  String get featureC2F1H1 => 'നിങ്ങളുടെ സ്വന്തം ബന്ധപ്പേരുകൾ';

  @override
  String get featureC2F1H2 => 'ഇരു വിലാസവിവരങ്ങളിലും സൂക്ഷിക്കുന്നു';

  @override
  String get featureC2F2Title => 'ബന്ധ നിശ്ശബ്ദ സമയം (DND അരിപ്പ)';

  @override
  String get featureC2F2Desc =>
      'നിങ്ങൾ നിശ്ചയിക്കുന്ന സമയങ്ങൾക്കിടയിൽ വിളികൾ നിശ്ശബ്ദമാക്കുക, എന്നിട്ടും ആരൊക്കെ കടന്നുവരണമെന്ന് പട്ടികപ്പെടുത്തുക — നക്ഷത്രമിട്ടവർ, മുഴുവൻ ബന്ധ വിഭാഗങ്ങൾ, ഒരു അടയാളം, അല്ലെങ്കിൽ പേരെടുത്ത വ്യക്തികൾ. മറ്റെല്ലാവരും നിശ്ശബ്ദം.';

  @override
  String get featureC2F2H0 => 'നിശ്ശബ്ദ സമയം നിശ്ചയിക്കുക';

  @override
  String get featureC2F2H1 => 'അനുവദിക്കുന്നവരുടെ പട്ടിക, തടയൽ പട്ടികയല്ല';

  @override
  String get featureC2F2H2 => 'വിഭാഗം, അടയാളം, അല്ലെങ്കിൽ വ്യക്തി';

  @override
  String get featureC2F3Title => 'അടയാളങ്ങളും സ്വന്തം ഗ്രൂപ്പുകളും';

  @override
  String get featureC2F3Desc =>
      'നിങ്ങളുടെ സ്വന്തം ചെറുവാക്കുകൾ കൊണ്ട് വിലാസവിവരങ്ങൾക്ക് അടയാളം നൽകുക, സ്വന്തം റിംഗ്ടോൺ ഉണ്ടാകാവുന്ന ഗ്രൂപ്പുകൾ (\"പ്രോജക്ട് ടീം\", \"പുസ്തക ക്ലബ്\" പോലെ) ഉണ്ടാക്കുക.';

  @override
  String get featureC2F3H0 => 'അടയാള മേഘം';

  @override
  String get featureC2F3H1 => 'സ്വന്തം ഗ്രൂപ്പുകൾ';

  @override
  String get featureC2F3H2 => 'ഗ്രൂപ്പ് റിംഗ്ടോണുകൾ';

  @override
  String get featureC2F4Title => 'ഇരട്ടിപ്പ് കണ്ടെത്തലും ബുദ്ധിപരമായ ലയനവും';

  @override
  String get featureC2F4Desc =>
      'ഫോൺ നമ്പർ കൊണ്ടും പേര് കൊണ്ടും — മറ്റൊരു ലിപിയിൽ എഴുതിയ പേരുകൾ ഉൾപ്പെടെ — ഇരട്ടിപ്പുകൾ കണ്ടെത്തുക, ഒരു വിവരവും നഷ്ടപ്പെടാതെ അവ വൃത്തിയായി ലയിപ്പിക്കുക.';

  @override
  String get featureC2F4H0 => 'പേരും നമ്പറും ഒത്തുനോക്കൽ';

  @override
  String get featureC2F4H1 => 'സുരക്ഷിതമായ ലയനം';

  @override
  String get featureC2F4H2 => 'ലയിപ്പിക്കുന്നതിനു മുമ്പ് പരിശോധന';

  @override
  String get featureC2F5Title => 'താൽക്കാലിക വിലാസവിവരങ്ങൾ';

  @override
  String get featureC2F5Desc =>
      'ഒരു ഡെലിവറി ഡ്രൈവറെയോ ഒറ്റത്തവണ വിൽപ്പനക്കാരനെയോ താൽക്കാലിക വിലാസവിവരമായി സൂക്ഷിക്കുക, അത് സ്വയം ഇല്ലാതാകും — 2 മണിക്കൂർ, 24 മണിക്കൂർ, 7 ദിവസം, അല്ലെങ്കിൽ ഒരു വിളിക്കു ശേഷം.';

  @override
  String get featureC2F5H0 => 'സ്വയം ഇല്ലാതാകുന്നത്';

  @override
  String get featureC2F5H1 => 'കാലാവധി ബാനർ';

  @override
  String get featureC2F5H2 => 'സ്ഥിരമായി സൂക്ഷിക്കാം';

  @override
  String get featureC2F6Title => 'ബന്ധിപ്പിച്ച സന്ദേശ ആപ്പുകൾ';

  @override
  String get featureC2F6Desc =>
      'ഒരു വിലാസവിവരത്തിൽ അവരെ ബന്ധപ്പെടാവുന്ന സന്ദേശ ആപ്പുകൾ കാണാം — WhatsApp, Telegram, Arattai തുടങ്ങിയവ — നിങ്ങളുടെ ഫോണിലെ വിലാസപ്പുസ്തകത്തിൽ നിന്ന് വായിക്കുന്നു. ഒന്ന് തൊട്ടാൽ അവിടെ ചാറ്റ് തുറക്കും.';

  @override
  String get featureC2F6H0 => 'നേരിട്ട് ചാറ്റ് തുറക്കുക';

  @override
  String get featureC2F6H1 => 'നിങ്ങളുടെ ഫോണിൽ നിന്ന് വായിക്കുന്നു';

  @override
  String get featureC2F6H2 => 'അക്കൗണ്ട് ആവശ്യമില്ല';

  @override
  String get featureC3Name => 'സ്വകാര്യത, സുരക്ഷ, രഹസ്യ അറ';

  @override
  String get featureC3Subtitle =>
      'നിങ്ങളുടെ സ്വകാര്യ വിലാസവിവരങ്ങളും സംഭാഷണങ്ങളും സംരക്ഷിക്കുക';

  @override
  String get featureC3F0Title => 'രഹസ്യ വിലാസവിവര അറ';

  @override
  String get featureC3F0Desc =>
      'സ്വകാര്യമോ ബിസിനസോ ആയ സംവേദനക്ഷമ വിലാസവിവരങ്ങൾ സുരക്ഷിതമായ ഒരു അറയിൽ ഒളിപ്പിക്കുക. തുറക്കുന്നതുവരെ പ്രധാന പട്ടികയിൽ അവ പൂർണ്ണമായും അദൃശ്യമാണ്.';

  @override
  String get featureC3F0H0 => 'ബയോമെട്രിക് / PIN തുറക്കൽ';

  @override
  String get featureC3F0H1 => 'പ്രധാന പട്ടികയിൽ മറഞ്ഞത്';

  @override
  String get featureC3F0H2 => 'ഗൂഢീകരിച്ച ഡാറ്റാബേസ്';

  @override
  String get featureC3F1Title =>
      'ആപ്പ് പൂട്ട്: ഓഫ്, ഉപകരണ പൂട്ട്, അല്ലെങ്കിൽ ആപ്പ് PIN';

  @override
  String get featureC3F1Desc =>
      'ഫോണിന്റെ വിരലടയാളവും മുഖവും കൊണ്ടോ, ഒറ്റത്തവണ വീണ്ടെടുക്കൽ കോഡുള്ള 4–6 അക്ക ആപ്പ് PIN കൊണ്ടോ ആപ്പ് മുഴുവൻ പൂട്ടുക. രഹസ്യ വിലാസവിവരങ്ങൾ, കരുതൽശേഖരങ്ങൾ, സമന്വയം എന്നിവ അതിനു പുറമേ വീണ്ടും ചോദിക്കും.';

  @override
  String get featureC3F1H0 => 'വിരലടയാളവും മുഖവും കൊണ്ട് തുറക്കൽ';

  @override
  String get featureC3F1H1 => 'പ്രത്യേക ആപ്പ് PIN';

  @override
  String get featureC3F1H2 => 'ഒറ്റത്തവണ വീണ്ടെടുക്കൽ കോഡ്';

  @override
  String get featureC3F2Title => 'സ്ക്രീൻഷോട്ട് സംരക്ഷണം';

  @override
  String get featureC3F2Desc =>
      'സ്വകാര്യ വിവരങ്ങളുള്ള ഒരു സ്ക്രീനിലായിരിക്കുമ്പോൾ — വിലാസവിവരങ്ങൾ, നടന്നുകൊണ്ടിരിക്കുന്ന വിളി, പൂട്ട് സ്ക്രീൻ, രഹസ്യ വിലാസവിവരങ്ങൾ, മാറ്റങ്ങളുടെ രേഖ — സ്ക്രീൻഷോട്ടുകൾ, സ്ക്രീൻ റെക്കോർഡിംഗ്, സമീപകാല ആപ്പ് കാഴ്ച എന്നിവ തടയുന്നു.';

  @override
  String get featureC3F2H0 => 'സ്ക്രീൻഷോട്ട് തടയൽ';

  @override
  String get featureC3F2H1 => 'സ്ക്രീൻ റെക്കോർഡിംഗ് പ്രതിരോധം';

  @override
  String get featureC3F2H2 => 'സമീപകാല കാഴ്ച മറച്ചു';

  @override
  String get featureC3F3Title => 'വിലാസവിവര മാറ്റങ്ങളുടെ രേഖ';

  @override
  String get featureC3F3Desc =>
      'സൃഷ്ടിച്ചതും തിരുത്തിയതും ഇല്ലാതാക്കിയതുമായ ഓരോ വിലാസവിവരത്തിന്റെയും, മുമ്പും ശേഷവും എങ്ങനെയായിരുന്നു എന്നതടക്കമുള്ള, കൃത്രിമം തിരിച്ചറിയാവുന്ന സ്വകാര്യ ചരിത്രം — അബദ്ധത്തിലുള്ള മാറ്റം പഴയപടിയാക്കാം.';

  @override
  String get featureC3F3H0 => 'മുമ്പും ശേഷവുമുള്ള ചിത്രങ്ങൾ';

  @override
  String get featureC3F3H1 => 'മാറ്റം പഴയപടിയാക്കുക';

  @override
  String get featureC3F3H2 => 'ഒപ്പിട്ട കയറ്റുമതി';

  @override
  String get featureC4Name => 'വേഗത്തിലുള്ള പങ്കിടലും സ്കാനിംഗും';

  @override
  String get featureC4Subtitle =>
      'ടൈപ്പ് ചെയ്യാതെ വിലാസവിവര കാർഡുകൾ വേഗം കൈമാറുക';

  @override
  String get featureC4F0Title => 'vCard QR കോഡ് നിർമ്മാണവും സ്കാനിംഗും';

  @override
  String get featureC4F0Desc =>
      'മറ്റുള്ളവർക്ക് നിമിഷങ്ങൾക്കുള്ളിൽ സ്കാൻ ചെയ്യാൻ നിങ്ങളുടെ വിലാസവിവര കാർഡിന്റെ QR കോഡ് ഉണ്ടാക്കുക, അല്ലെങ്കിൽ ക്യാമറ ഉപയോഗിച്ച് ആരുടെയും QR കാർഡ് സ്കാൻ ചെയ്ത് സൂക്ഷിക്കുക.';

  @override
  String get featureC4F0H0 => 'ഉടനടി QR vCard';

  @override
  String get featureC4F0H1 => 'അന്തർനിർമ്മിത ക്യാമറ സ്കാനർ';

  @override
  String get featureC4F0H2 => 'ഒറ്റ ടാപ്പിൽ വിലാസപ്പുസ്തകത്തിലേക്ക്';

  @override
  String get featureC4F1Title => 'AirQR ചലിക്കുന്ന കോഡ് പ്രവാഹം';

  @override
  String get featureC4F1Desc =>
      'ഒരു ഫോട്ടോയോ നീണ്ട വിലാസവിവര കാർഡോ ഒരു QR കോഡിൽ ഒതുങ്ങില്ല. AirQR അതിനെ പല ഫ്രെയിമുകളായി വിഭജിച്ച് മറ്റേ ഫോണിന്റെ ക്യാമറയ്ക്ക് വായിക്കാൻ ഒരു ചലച്ചിത്രമായി കാണിക്കുന്നു — ബ്ലൂടൂത്തോ നെറ്റ്‌വർക്കോ ജോടിയാക്കലോ വേണ്ട.';

  @override
  String get featureC4F1H0 => 'ഫോട്ടോകളും പൂർണ്ണ കാർഡുകളും അയയ്ക്കുന്നു';

  @override
  String get featureC4F1H1 => 'ക്യാമറ മാത്രം വഴിയുള്ള കൈമാറ്റം';

  @override
  String get featureC4F1H2 => 'പ്രവാഹത്തിനിടെ തത്സമയ പുരോഗതി';

  @override
  String get featureC4F2Title => 'ഫോണിൽ തന്നെയുള്ള ബിസിനസ് കാർഡ് സ്കാനർ';

  @override
  String get featureC4F2Desc =>
      'ഏതൊരു ബിസിനസ് കാർഡിന്റെയും ഫോട്ടോ എടുത്ത് പേര്, ഫോൺ, ഇമെയിൽ, സ്ഥാപന വിവരങ്ങൾ എന്നിവ ഉടനടി എടുക്കുക — ക്ലൗഡിലേക്ക് അയയ്ക്കാതെ 100% നിങ്ങളുടെ ഫോണിൽ തന്നെ.';

  @override
  String get featureC4F2H0 => 'ഫോണിലെ AI OCR';

  @override
  String get featureC4F2H1 => 'ക്ലൗഡിലേക്ക് ഒന്നും അയയ്ക്കുന്നില്ല';

  @override
  String get featureC4F2H2 => 'തിരഞ്ഞെടുത്ത വിവരങ്ങൾ മാത്രം ചേർക്കൽ';

  @override
  String get featureC4F3Title => 'ഓഫ്‌ലൈൻ ബ്ലൂടൂത്ത് LE പങ്കിടൽ';

  @override
  String get featureC4F3Desc =>
      'അടുത്തുള്ള ContactSphere ഉപകരണങ്ങൾ കണ്ടെത്തി, ഇന്റർനെറ്റോ ജോടിയാക്കൽ കോഡോ ഇല്ലാതെ, Bluetooth Low Energy വഴി നേരിട്ട് വിലാസവിവരങ്ങൾ അയയ്ക്കുക.';

  @override
  String get featureC4F3H0 => 'ഇന്റർനെറ്റ് ആവശ്യമില്ല';

  @override
  String get featureC4F3H1 => 'ഉപകരണങ്ങൾ സ്വയം കണ്ടെത്തുന്നു';

  @override
  String get featureC4F3H2 => 'സ്വീകരിക്കുന്നയാൾ സ്ഥിരീകരിക്കണം';

  @override
  String get featureC4F4Title => 'CSV, vCard ഇറക്കുമതി / കയറ്റുമതി';

  @override
  String get featureC4F4Desc =>
      'CSV അല്ലെങ്കിൽ vCard (.vcf) ഫയലിൽ നിന്ന് വിലാസവിവരങ്ങൾ കൊണ്ടുവരിക, അല്ലെങ്കിൽ നിങ്ങളുടെ വിലാസപ്പുസ്തകം അങ്ങനെയൊരു ഫയലായി എഴുതുക, തുടർന്ന് സിസ്റ്റം പങ്കിടൽ ഷീറ്റ് വഴി അത് എവിടേക്ക് പോകണമെന്ന് തിരഞ്ഞെടുക്കുക.';

  @override
  String get featureC4F4H0 => 'CSV അകത്തും പുറത്തും';

  @override
  String get featureC4F4H1 => 'vCard (.vcf) അകത്തും പുറത്തും';

  @override
  String get featureC4F4H2 => 'രഹസ്യ വിലാസവിവരങ്ങൾ ഒഴിവാക്കുന്നു';

  @override
  String get featureC5Name => 'ഡാറ്റ സമന്വയവും കരുതൽശേഖരവും';

  @override
  String get featureC5Subtitle =>
      'നിങ്ങളുടെ വിലാസവിവരങ്ങൾ സുരക്ഷിതമായും സമന്വയിപ്പിച്ചും എവിടെയും വീണ്ടെടുക്കാവുന്നതായും സൂക്ഷിക്കുക';

  @override
  String get featureC5F0Title =>
      'ഫോൺ വിലാസവിവരങ്ങളും വിളി രേഖയും സമന്വയിപ്പിക്കൽ';

  @override
  String get featureC5F0Desc =>
      'ആപ്പിനും ഫോണിലെ വിലാസപ്പുസ്തകത്തിനുമിടയിൽ നിങ്ങൾ തിരഞ്ഞെടുക്കുന്ന ദിശയിൽ വിലാസവിവരങ്ങൾ പകർത്തുക — ഓരോന്നും നിങ്ങൾ തന്നെ നടത്തുന്നു. ഫോണിലെ വിളി രേഖ സ്വയം സമീപകാലത്തിലേക്ക് എത്തുന്നു.';

  @override
  String get featureC5F0H0 => 'ഏതു ദിശയിലും, ആവശ്യമുള്ളപ്പോൾ';

  @override
  String get featureC5F0H1 =>
      'ചേർക്കുകയും നവീകരിക്കുകയും ചെയ്യുന്നു, ഒരിക്കലും ഇല്ലാതാക്കുന്നില്ല';

  @override
  String get featureC5F0H2 => 'വിളി രേഖ സ്വയം എത്തുന്നു';

  @override
  String get featureC5F1Title =>
      'പ്രാദേശിക Wi-Fi വഴി ഉപകരണങ്ങൾക്കിടയിലെ സമന്വയം';

  @override
  String get featureC5F1Desc =>
      'ഒരേ Wi-Fi നെറ്റ്‌വർക്കിലുള്ള രണ്ട് ഫോണുകൾക്കിടയിൽ, സ്ക്രീനിൽ നിന്ന് പുറത്തുപോകാത്ത ജോടിയാക്കൽ കോഡ് കൊണ്ട് ഗൂഢീകരിച്ച്, വിലാസവിവരങ്ങൾ കൈമാറുക. ഒന്നും അപ്‌ലോഡ് ചെയ്യുന്നില്ല, സ്വീകരിക്കുന്ന ഫോണിൽ ഒന്നും ഇല്ലാതാക്കുന്നില്ല.';

  @override
  String get featureC5F1H0 => 'ഫോണിൽ നിന്ന് ഫോണിലേക്ക് നേരിട്ട്';

  @override
  String get featureC5F1H1 => 'QR ജോടിയാക്കൽ കോഡ് കൊണ്ട് ഗൂഢീകരിച്ചത്';

  @override
  String get featureC5F1H2 => 'ക്ലൗഡ് ആവശ്യമില്ല';

  @override
  String get featureC5F2Title =>
      'ഓൺലൈൻ സമന്വയവും ഗൂഢീകരിച്ച ക്ലൗഡ് കരുതൽശേഖരവും';

  @override
  String get featureC5F2Desc =>
      'വേണമെങ്കിൽ Google, Microsoft, അല്ലെങ്കിൽ ഒരു CardDAV സെർവറുമായി വിലാസവിവരങ്ങൾ സമന്വയിപ്പിക്കുക, പാസ്‌വേഡ് കൊണ്ട് ഗൂഢീകരിച്ച ഒരു കരുതൽശേഖര ഫയൽ Google Drive, OneDrive, അല്ലെങ്കിൽ നിങ്ങളുടെ സ്വന്തം WebDAV സംഭരണത്തിലേക്ക് അപ്‌ലോഡ് ചെയ്യുക.';

  @override
  String get featureC5F2H0 => 'Google, Microsoft, WebDAV';

  @override
  String get featureC5F2H1 => 'പാസ്‌വേഡ് കൊണ്ട് ഗൂഢീകരിച്ച ഫയൽ';

  @override
  String get featureC5F2H2 =>
      'രഹസ്യ വിലാസവിവരങ്ങൾ ഒരിക്കലും അപ്‌ലോഡ് ചെയ്യുന്നില്ല';

  @override
  String get featureC5F3Title => 'ഓഫ്‌ലൈൻ കരുതൽശേഖര, പുനഃസ്ഥാപന ഫയലുകൾ';

  @override
  String get featureC5F3Desc =>
      'എല്ലാം — വിലാസവിവരങ്ങൾ, വിളി ചരിത്രം, ഫോട്ടോകൾ, ക്രമീകരണങ്ങൾ, അടിയന്തര കാർഡ് — പാസ്‌വേഡ് കൊണ്ട് പൂട്ടിയ ഒരൊറ്റ ഫയലിൽ സൂക്ഷിച്ച് ഏത് ഫോണിലും പുനഃസ്ഥാപിക്കുക. പാസ്‌വേഡ് മാത്രമാണ് താക്കോൽ; ആപ്പ് അത് ഒരിക്കലും സൂക്ഷിക്കുന്നില്ല.';

  @override
  String get featureC5F3H0 => 'ഫയലിലേക്ക് കയറ്റുമതി';

  @override
  String get featureC5F3H1 => 'സുരക്ഷിത ഗൂഢീകരിച്ച രൂപം';

  @override
  String get featureC5F3H2 => 'പുനഃസ്ഥാപനം എല്ലാം മാറ്റിസ്ഥാപിക്കുന്നു';

  @override
  String get featureC6Name => 'വിളി പ്രതിരോധവും സ്പാം തടയലും';

  @override
  String get featureC6Subtitle =>
      'സ്പാം വിളികളിൽ നിന്നും വേണ്ടാത്ത നമ്പറുകളിൽ നിന്നും സ്വയം സംരക്ഷിക്കുക';

  @override
  String get featureC6F0Title => 'സ്വയമേവയുള്ള വിളി പരിശോധന';

  @override
  String get featureC6F0Desc =>
      'ഫോൺ റിംഗ് ചെയ്യുന്നതിനു മുമ്പ് അന്തർനിർമ്മിത പരിശോധനാ സേവനം വരുന്ന ഓരോ നമ്പറും നോക്കി, നിങ്ങളുടെ തടഞ്ഞ പട്ടികയിലുള്ളവയെ നിരസിക്കുന്നു — പൂർണ്ണമായും ഈ ഫോണിൽ, നിങ്ങളുടെ സ്വന്തം പട്ടികയുമായി ഒത്തുനോക്കി.';

  @override
  String get featureC6F0H0 => 'റിംഗ് ചെയ്യുന്നതിനു മുമ്പ് നിരസിക്കുന്നു';

  @override
  String get featureC6F0H1 => 'ഓൺലൈനിൽ ഒന്നും തിരയുന്നില്ല';

  @override
  String get featureC6F0H2 => 'സ്വതവേയുള്ള ഡയലറുമായി ചേർന്ന്';

  @override
  String get featureC6F1Title => 'തടഞ്ഞ നമ്പറുകളുടെ നിയന്ത്രണം';

  @override
  String get featureC6F1Desc =>
      'സമീപകാലത്തിൽ അമർത്തിപ്പിടിച്ചോ, വിളിക്കിടെ തടയുക നിയന്ത്രണം വഴിയോ, സ്വയം ടൈപ്പ് ചെയ്തോ ഒരു നമ്പർ തടയുക. നടന്നുകൊണ്ടിരിക്കുന്ന വിളിക്കിടെ തടഞ്ഞാൽ അത് ഉടൻ വിച്ഛേദിക്കും; ആരാണ് ശ്രമിച്ചതെന്ന് കാണാൻ തടഞ്ഞ വിളികൾ സമീപകാലത്തിൽ തുടർന്നും കാണാം.';

  @override
  String get featureC6F1H0 => 'സമീപകാലത്തിൽ നിന്നോ വിളിക്കിടയിലോ തടയുക';

  @override
  String get featureC6F1H1 => 'തടയൽ പട്ടിക നിയന്ത്രണം';

  @override
  String get featureC6F1H2 => 'എപ്പോൾ വേണമെങ്കിലും തടയൽ നീക്കുക';

  @override
  String get featureC6F2Title => 'അജ്ഞാത വിളികൾ തടയുക';

  @override
  String get featureC6F2Desc =>
      'നമ്പറില്ലാതെയോ മറച്ച നമ്പറോടെയോ വരുന്ന വിളികൾ നിരസിക്കുക. റിംഗ് ചെയ്യുന്നതിനു മുമ്പ് അവ നിരസിക്കപ്പെടുന്നു, എന്നാലും തടഞ്ഞവയായി സമീപകാലത്തിൽ രേഖപ്പെടുത്തുന്നു.';

  @override
  String get featureC6F2H0 => 'മറച്ച നമ്പറുകൾ നിരസിക്കുന്നു';

  @override
  String get featureC6F2H1 => 'എന്നാലും സമീപകാലത്തിൽ രേഖപ്പെടുത്തുന്നു';

  @override
  String get featureC6F2H2 => 'ഒരു സ്വിച്ചിൽ ഓണാക്കാം';

  @override
  String get featureC6F3Title =>
      'വിളിക്കുന്നയാളെ തിരിച്ചറിയലും സ്പാം അരിപ്പയും';

  @override
  String get featureC6F3Desc =>
      'പ്രാദേശികമായി കണ്ടെത്താവുന്നവ ഉപയോഗിച്ച് നിങ്ങളുടെ വിലാസവിവരങ്ങളിൽ ഇല്ലാത്ത വിളിക്കുന്നവരെ അടയാളപ്പെടുത്തുക — ടെലിമാർക്കറ്റിംഗ്, സേവന നമ്പർ ശ്രേണികൾ, നിങ്ങൾ സ്പാം ആയി അടയാളപ്പെടുത്തിയ നമ്പറുകൾ, നെറ്റ്‌വർക്കിന്റെ സ്ഥിരീകരിച്ച-വിളിക്കുന്നയാൾ അടയാളം. അടയാളപ്പെടുത്തിയവ ഉച്ചത്തിലല്ലാതെ നിശ്ശബ്ദമായി റിംഗ് ചെയ്യാം.';

  @override
  String get featureC6F3H0 => 'അജ്ഞാത വിളിക്കുന്നവരെ അടയാളപ്പെടുത്തുന്നു';

  @override
  String get featureC6F3H1 => 'സ്പാം നിശ്ശബ്ദമായി റിംഗ് ചെയ്യുന്നു';

  @override
  String get featureC6F3H2 => 'ഒരു നമ്പർ സ്പാം ആയി അടയാളപ്പെടുത്തുക';

  @override
  String get featureC7Name => 'വ്യക്തിഗതമാക്കലും ലഭ്യതയും';

  @override
  String get featureC7Subtitle =>
      'രൂപം, ശബ്ദം, പ്രാദേശിക ക്രമീകരണങ്ങൾ എന്നിവ നിങ്ങളുടെ ഇഷ്ടത്തിന് ക്രമീകരിക്കുക';

  @override
  String get featureC7F0Title => 'തീം, പ്രധാന നിറം, അക്ഷരരൂപം';

  @override
  String get featureC7F0Desc =>
      'തെളിഞ്ഞ, ഇരുണ്ട, അല്ലെങ്കിൽ സിസ്റ്റം രീതി തിരഞ്ഞെടുക്കുക, ഒരു പ്രധാന നിറം തിരഞ്ഞെടുക്കുക, അക്ഷരരൂപവും അക്ഷരവലുപ്പവും നിശ്ചയിക്കുക. ആപ്പിനൊപ്പമുള്ള മൂന്ന് അക്ഷരരൂപങ്ങൾ മലയാളവും ഇംഗ്ലീഷും ഉൾക്കൊള്ളുന്നു.';

  @override
  String get featureC7F0H0 => 'ഇരുണ്ടതും തെളിഞ്ഞതുമായ രൂപം';

  @override
  String get featureC7F0H1 => 'തിരഞ്ഞെടുത്ത നിറക്കൂട്ടുകൾ';

  @override
  String get featureC7F0H2 => 'അക്ഷരരൂപവും വലുപ്പവും';

  @override
  String get featureC7F1Title =>
      'ഓരോ സിമ്മിനും ഗ്രൂപ്പിനും വിലാസവിവരത്തിനും റിംഗ്ടോൺ';

  @override
  String get featureC7F1Desc =>
      'സിം 1-നും സിം 2-നും, ഒരു ഗ്രൂപ്പിനും, അല്ലെങ്കിൽ ഒരൊറ്റ വിലാസവിവരത്തിനും വ്യത്യസ്ത റിംഗ്ടോണുകൾ നൽകുക. ഏറ്റവും കൃത്യമായത് ജയിക്കുന്നു: വിലാസവിവരത്തിന്റേത്, പിന്നെ അവരുടെ ഗ്രൂപ്പിന്റേത്, പിന്നെ സിമ്മിന്റേത്.';

  @override
  String get featureC7F1H0 => 'ഓരോ സിമ്മിനും വ്യത്യസ്ത റിംഗ്ടോൺ';

  @override
  String get featureC7F1H1 => 'ഗ്രൂപ്പ് റിംഗ്ടോണുകൾ';

  @override
  String get featureC7F1H2 => 'ഓരോ വിലാസവിവരത്തിനും റിംഗ്ടോൺ';

  @override
  String get featureC7F2Title => 'അടിയന്തര വിവര പൂട്ട് സ്ക്രീൻ കാർഡ്';

  @override
  String get featureC7F2Desc =>
      'പ്രധാന ആരോഗ്യ വിവരങ്ങൾ (രക്തഗ്രൂപ്പ്, അലർജികൾ, അടിയന്തര ബന്ധങ്ങൾ) തുറക്കാതെ തന്നെ ആദ്യം എത്തുന്ന രക്ഷാപ്രവർത്തകർക്ക് പൂട്ട് സ്ക്രീനിൽ കാണാവുന്ന രീതിയിൽ സജ്ജമാക്കുക.';

  @override
  String get featureC7F2H0 => 'പൂട്ട് സ്ക്രീനിൽ ലഭ്യം';

  @override
  String get featureC7F2H1 => 'ഓരോ വിവരത്തിനും സ്വകാര്യത സ്വിച്ച്';

  @override
  String get featureC7F2H2 => 'നേരിട്ടുള്ള അടിയന്തര വിളി';

  @override
  String get featureC7F3Title => 'സ്വതവേയുള്ള രാജ്യ ഡയലിംഗ് കോഡ്';

  @override
  String get featureC7F3Desc =>
      'മുൻകോഡില്ലാത്ത സാധാരണ നമ്പറുകൾ ഏത് രാജ്യത്തിന്റേതാണെന്ന് ആപ്പിനോട് പറയുക. +91 98765 43210-ൽ നിന്നുള്ള വിളി നിങ്ങളുടെ വിലാസവിവരങ്ങളിലെ 98765 43210 ആയി തിരിച്ചറിയുന്നത് ഇതുകൊണ്ടാണ്; തടഞ്ഞ നമ്പറുകൾ ഒത്തുനോക്കാനും ഇത് ഉപയോഗിക്കുന്നു.';

  @override
  String get featureC7F3H0 => 'സ്വയം രാജ്യ മുൻകോഡ്';

  @override
  String get featureC7F3H1 => 'അന്താരാഷ്ട്ര രൂപം';

  @override
  String get featureC7F3H2 =>
      'വിളിക്കുന്നവരെ വിലാസവിവരങ്ങളുമായി ഒത്തുനോക്കുന്നു';

  @override
  String get featureC7F4Title => 'വിലാസവിവര എണ്ണവും തിരച്ചിൽ സൂചികയും';

  @override
  String get featureC7F4Desc =>
      'ഫോണിലും ആപ്പിലും എത്ര വിലാസവിവരങ്ങൾ ഉണ്ടെന്ന് കാണുക, T9, പേര് തിരച്ചിൽ വേഗമാക്കുന്ന തിരച്ചിൽ സൂചികയുടെ ആരോഗ്യം പരിശോധിക്കുക. ഒരു വിലാസവിവരം തിരച്ചിലിൽ വരാതായാൽ നിമിഷങ്ങൾക്കുള്ളിൽ അത് പുനർനിർമ്മിക്കുക.';

  @override
  String get featureC7F4H0 => 'ഫോണിലെയും ആപ്പിലെയും എണ്ണം';

  @override
  String get featureC7F4H1 => 'സൂചികാ ആരോഗ്യ പരിശോധന';

  @override
  String get featureC7F4H2 => 'ഒറ്റ ടാപ്പിൽ പുനർനിർമ്മാണം';

  @override
  String get featureC7F5Title => 'ആപ്പിനുള്ളിലെ സഹായവും മാർഗ്ഗനിർദ്ദേശങ്ങളും';

  @override
  String get featureC7F5Desc =>
      'ഇവിടെയുള്ള ഓരോ സവിശേഷതയും — വിളി, തടയൽ, സമന്വയം, കരുതൽശേഖരം, സ്വകാര്യത, പങ്കിടൽ തുടങ്ങിയവ — ലളിതമായി വിശദീകരിക്കുന്ന ഇരുപതിലധികം മാർഗ്ഗനിർദ്ദേശങ്ങൾ, ഒപ്പം ചോദ്യോത്തരങ്ങളും പ്രശ്നപരിഹാര താളും. എല്ലാം ഓഫ്‌ലൈനായി, ആപ്പിനുള്ളിൽ.';

  @override
  String get featureC7F5H0 => 'ഓരോ സവിശേഷതയ്ക്കും മാർഗ്ഗനിർദ്ദേശം';

  @override
  String get featureC7F5H1 => 'ചോദ്യോത്തരങ്ങളും പ്രശ്നപരിഹാരവും';

  @override
  String get featureC7F5H2 => 'ഓഫ്‌ലൈനായി പ്രവർത്തിക്കുന്നു';

  @override
  String get titleFeaturesHeader => 'SreerajP Contacts Sphere സവിശേഷതകൾ';

  @override
  String get descFeaturesHeader =>
      'നിങ്ങൾക്കായി രൂപകൽപ്പന ചെയ്ത ഓരോ ബുദ്ധിപരമായ ഉപകരണവും സ്വകാര്യതാ സംരക്ഷണവും വിളി സവിശേഷതയും കണ്ടെത്തുക.';

  @override
  String get msgSavedCardOff => 'സൂക്ഷിച്ചു. പൂട്ട് സ്ക്രീൻ കാർഡ് ഓഫാണ്.';

  @override
  String get msgSavedNothingOn =>
      'സൂക്ഷിച്ചു. കാണിക്കാൻ ഇതുവരെ ഒന്നും ഓണാക്കിയിട്ടില്ല.';

  @override
  String get msgSavedCardOn =>
      'സൂക്ഷിച്ചു. കാർഡ് നിങ്ങളുടെ പൂട്ട് സ്ക്രീനിലുണ്ട്.';

  @override
  String errorCouldNotSave(String error) {
    return 'സൂക്ഷിക്കാനായില്ല: $error';
  }

  @override
  String get titleLeaveWithoutSaving => 'സൂക്ഷിക്കാതെ പോകണോ?';

  @override
  String get descUnsavedEmergency =>
      'അടിയന്തര കാർഡിലെ നിങ്ങളുടെ മാറ്റങ്ങൾ സൂക്ഷിച്ചിട്ടില്ല.';

  @override
  String get actionKeepEditing => 'തിരുത്തൽ തുടരുക';

  @override
  String get actionDiscard => 'ഉപേക്ഷിക്കുക';

  @override
  String get errorNothingToShare => 'പങ്കിടാൻ കാർഡിൽ ഒന്നും ഓണാക്കിയിട്ടില്ല.';

  @override
  String get descShareFormatted =>
      'ക്രമീകരിച്ച വിവരങ്ങൾ സന്ദേശമായോ ഇമെയിലായോ അയയ്ക്കുക';

  @override
  String get actionShareAsCardImage => 'കാർഡ് ചിത്രമായി പങ്കിടുക';

  @override
  String get descShareCardImage => 'ICE കാർഡിന്റെ ചിത്രം (PNG) അയയ്ക്കുക';

  @override
  String get tooltipShareIceCard => 'ICE കാർഡ് പങ്കിടുക';

  @override
  String get descEmergencyWarning =>
      'ഇവിടെ നിങ്ങൾ ഓണാക്കുന്നതെന്തും നിങ്ങളുടെ PIN ഇല്ലാതെ, ഫോൺ കയ്യിലുള്ള ആർക്കും വായിക്കാം. അതാണ് ഒരു അടിയന്തര കാർഡിന്റെ ലക്ഷ്യം — അതിനാൽ ഒരു അപരിചിതൻ കാണേണ്ടത് മാത്രം ഓണാക്കുക.';

  @override
  String get labelShowOnLockScreen => 'പൂട്ട് സ്ക്രീനിൽ കാണിക്കുക';

  @override
  String get descShowOnLockScreen =>
      'ഒറ്റ ടാപ്പ് അടിയന്തര വിളിയുള്ള സ്ഥിരമായ അറിയിപ്പ് ചേർക്കുന്നു. ഉയർന്ന തെളിച്ചമുള്ള അടിയന്തര QR കോഡോടെ പൂട്ട് സ്ക്രീനിന് മുകളിൽ കാർഡ് തുറക്കുന്നു.';

  @override
  String get labelNameOnCard => 'കാർഡിൽ കാണിക്കുന്ന പേര്';

  @override
  String get labelShowTheName => 'പേര് കാണിക്കുക';

  @override
  String get descNotificationsOff =>
      'ഈ ആപ്പിന്റെ അറിയിപ്പുകൾ ഓഫാണ്, അതിനാൽ കാർഡ് എവിടെയും കാണിക്കാനാവില്ല.';

  @override
  String get descNotificationSilent =>
      'ഈ അറിയിപ്പ് നിശ്ശബ്ദമാക്കിയിരിക്കുന്നു. പല ഫോണുകളിലും പൂട്ട് സ്ക്രീൻ നിശ്ശബ്ദ അറിയിപ്പുകൾ മറയ്ക്കുന്നു.';

  @override
  String get actionOpenNotificationSettings => 'അറിയിപ്പ് ക്രമീകരണം തുറക്കുക';

  @override
  String get titleNotSeeingOnLock => 'പൂട്ട് സ്ക്രീനിൽ കാണുന്നില്ലേ?';

  @override
  String get descLockScreenTips =>
      'പൂട്ട് സ്ക്രീൻ ഏത് അറിയിപ്പുകൾ കാണിക്കണമെന്ന് ഫോൺ ആണ് തീരുമാനിക്കുന്നത്. ഈ സിസ്റ്റം ക്രമീകരണം പരിശോധിക്കുക:\n\nSettings → Notifications → Notifications on lock screen\n\n\"Show conversations, default and silent\" തിരഞ്ഞെടുക്കുക. അത് \"Hide silent notifications\" അല്ലെങ്കിൽ \"Don\'t show any notifications\" ആണെങ്കിൽ അടിയന്തര കാർഡ് അവിടെ വരില്ല — ഒരു ആപ്പിനും അത് മറികടക്കാനാവില്ല.';

  @override
  String get labelMedicalDetails => 'ആരോഗ്യ വിവരങ്ങൾ';

  @override
  String get labelAllergies => 'അലർജികൾ';

  @override
  String get labelMedicines => 'മരുന്നുകൾ';

  @override
  String get labelConditions => 'രോഗാവസ്ഥകൾ';

  @override
  String get labelAddressField => 'വിലാസം';

  @override
  String get hintAllergies => 'ഉദാ. പെനിസിലിൻ, നിലക്കടല';

  @override
  String get hintMedicines => 'നിങ്ങൾ പതിവായി കഴിക്കുന്ന മരുന്നുകൾ';

  @override
  String get hintConditions => 'ഉദാ. പ്രമേഹം, അപസ്മാരം';

  @override
  String get hintHomeAddress => 'വീട്ടുവിലാസം';

  @override
  String get hintEmergencyNotes => 'ഒരു സഹായി അറിയേണ്ട മറ്റെന്തും';

  @override
  String get labelOrganDonor => 'അവയവദാതാവ്';

  @override
  String get labelShowOrganDonor => '\"അവയവദാതാവ്\" കാണിക്കുക';

  @override
  String get labelPeopleToCall => 'വിളിക്കേണ്ടവർ';

  @override
  String get descPeopleToCall =>
      'ഓരോരുത്തർക്കും കാർഡിൽ ഒരു വിളി ബട്ടൺ ലഭിക്കും. പൂട്ട് സ്ക്രീനിൽ നിന്ന് നേരിട്ട് വിളിക്കും.';

  @override
  String get emptyNoOneAdded => 'ഇതുവരെ ആരെയും ചേർത്തിട്ടില്ല.';

  @override
  String get actionFromContacts => 'വിലാസവിവരങ്ങളിൽ നിന്ന്';

  @override
  String get actionTypeANumber => 'നമ്പർ ടൈപ്പ് ചെയ്യുക';

  @override
  String get tooltipShownOnCard => 'കാർഡിൽ കാണിക്കുന്നു';

  @override
  String get tooltipHidden => 'മറച്ചിരിക്കുന്നു';

  @override
  String get labelWhatStrangerSees => 'ഒരു അപരിചിതൻ കാണുന്നത്';

  @override
  String get descCardSwitchedOff => 'ഒന്നുമില്ല — കാർഡ് ഓഫാണ്.';

  @override
  String get descNothingYetFill =>
      'ഇതുവരെ ഒന്നുമില്ല. ഒരു വിവരം പൂരിപ്പിച്ച് ഓണാക്കുക.';

  @override
  String get descTapSaveToApply =>
      'പൂട്ട് സ്ക്രീനിൽ മാറ്റങ്ങൾ വരുത്താൻ \"സൂക്ഷിക്കുക\" തൊടുക.';

  @override
  String get titleChoosePersonToCall => 'വിളിക്കേണ്ടയാളെ തിരഞ്ഞെടുക്കുക';

  @override
  String get titleAddPerson => 'ഒരാളെ ചേർക്കുക';

  @override
  String get titleEditPerson => 'വ്യക്തിയെ തിരുത്തുക';

  @override
  String get labelNumber => 'നമ്പർ';

  @override
  String get labelRelationOptional => 'ബന്ധം (ഐച്ഛികം)';

  @override
  String get hintRelationExample => 'ഉദാ. ഭാര്യ, ഡോക്ടർ';

  @override
  String get errorNameAndNumberNeeded => 'പേരും നമ്പറും രണ്ടും വേണം.';

  @override
  String get labelNotSet => 'നിശ്ചയിച്ചിട്ടില്ല';

  @override
  String errorFailedLoadGroups(String error) {
    return 'ഗ്രൂപ്പുകൾ ലോഡ് ചെയ്യാനായില്ല: $error';
  }

  @override
  String get errorCouldNotCreateGroup =>
      'ഗ്രൂപ്പ് സൃഷ്ടിക്കാനായില്ല (പേര് ഇതിനകം ഉണ്ടാകാം)';

  @override
  String get titleGroupName => 'ഗ്രൂപ്പിന്റെ പേര്';

  @override
  String get hintGroupExample => 'ഉദാ. കുടുംബം';

  @override
  String get actionOk => 'ശരി';

  @override
  String errorCouldNotSaveRingtone(String error) {
    return 'റിംഗ്ടോൺ സൂക്ഷിക്കാനായില്ല: $error';
  }

  @override
  String errorCouldNotClearRingtone(String error) {
    return 'റിംഗ്ടോൺ മായ്ക്കാനായില്ല: $error';
  }

  @override
  String get errorNoContactsToAdd => 'ചേർക്കാൻ വിലാസവിവരങ്ങളില്ല';

  @override
  String titleAddToGroup(String name) {
    return '\"$name\"-ൽ ചേർക്കുക';
  }

  @override
  String get msgNoNewContactsAdded => 'പുതിയ വിലാസവിവരങ്ങളൊന്നും ചേർത്തില്ല';

  @override
  String msgContactsAddedToGroup(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count വിലാസവിവരങ്ങൾ \"$name\"-ൽ ചേർത്തു',
      one: 'ഒരു വിലാസവിവരം \"$name\"-ൽ ചേർത്തു',
    );
    return '$_temp0';
  }

  @override
  String errorCouldNotAddContacts(String error) {
    return 'വിലാസവിവരങ്ങൾ ചേർക്കാനായില്ല: $error';
  }

  @override
  String titleDeleteGroupConfirm(String name) {
    return '\"$name\" ഇല്ലാതാക്കണോ?';
  }

  @override
  String get descDeleteGroup =>
      'ഗ്രൂപ്പ് നീക്കും; അതിലെ വിലാസവിവരങ്ങൾ ഇല്ലാതാക്കില്ല.';

  @override
  String get emptyNoGroups => 'ഇതുവരെ ഗ്രൂപ്പുകളൊന്നുമില്ല';

  @override
  String get actionAddContactsEllipsis => 'വിലാസവിവരങ്ങൾ ചേർക്കുക…';

  @override
  String get actionRingtoneEllipsis => 'റിംഗ്ടോൺ…';

  @override
  String get actionClearRingtone => 'റിംഗ്ടോൺ മായ്ക്കുക';

  @override
  String get emptyNoTags =>
      'ഇതുവരെ അടയാളങ്ങളൊന്നുമില്ല. ഒരു വിലാസവിവരത്തിന് അടയാളങ്ങൾ ചേർത്താൽ അവ ഇവിടെ കാണാം.';

  @override
  String get descTagCloudHint =>
      'ഒരു അടയാളത്തിലെ വിലാസവിവരങ്ങൾ കാണാൻ അത് തൊടുക. പേരുമാറ്റാനോ ലയിപ്പിക്കാനോ ഇല്ലാതാക്കാനോ അമർത്തിപ്പിടിക്കുക.';

  @override
  String titleAddToTag(String tag) {
    return '#$tag-ൽ ചേർക്കുക';
  }

  @override
  String msgContactsAddedToTag(int count, String tag) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count വിലാസവിവരങ്ങൾ #$tag-ൽ ചേർത്തു',
      one: 'ഒരു വിലാസവിവരം #$tag-ൽ ചേർത്തു',
    );
    return '$_temp0';
  }

  @override
  String titleRemoveTagConfirm(String tag) {
    return '#$tag നീക്കണോ?';
  }

  @override
  String descRemoveTagFrom(String name) {
    return '$name-ൽ നിന്ന് അടയാളം നീക്കും. വിലാസവിവരം ഇല്ലാതാക്കില്ല.';
  }

  @override
  String get descRemoveTagFromThis =>
      'ഈ വിലാസവിവരത്തിൽ നിന്ന് അടയാളം നീക്കും. വിലാസവിവരം ഇല്ലാതാക്കില്ല.';

  @override
  String msgRemovedTag(String tag) {
    return '#$tag നീക്കി';
  }

  @override
  String errorCouldNotRemove(String error) {
    return 'നീക്കാനായില്ല: $error';
  }

  @override
  String get tooltipRenameMergeDeleteTag =>
      'പേരുമാറ്റുക, ലയിപ്പിക്കുക, ഇല്ലാതാക്കുക';

  @override
  String get actionAddContacts => 'വിലാസവിവരങ്ങൾ ചേർക്കുക';

  @override
  String get emptyTagNoContacts =>
      'ഒരു വിലാസവിവരത്തിനും ഈ അടയാളമില്ല.\n\nതാഴെ ചിലത് ചേർക്കുക, അല്ലെങ്കിൽ മുകളിലെ മെനുവിൽ നിന്ന് അടയാളം ഇല്ലാതാക്കുക.';

  @override
  String get tooltipRemoveTagFromContact =>
      'ഈ വിലാസവിവരത്തിൽ നിന്ന് അടയാളം നീക്കുക';

  @override
  String get labelNoPhone => 'ഫോണില്ല';

  @override
  String errorFailedFindDuplicates(String error) {
    return 'ഇരട്ടിപ്പുകൾ കണ്ടെത്താനായില്ല: $error';
  }

  @override
  String get titleMergeThisSet => 'ഈ കൂട്ടം ലയിപ്പിക്കണോ?';

  @override
  String descMergeThisSet(int count) {
    return 'തിരഞ്ഞെടുത്ത വിലാസവിവരം നിലനിർത്തി മറ്റ് $count എണ്ണം അതിൽ ലയിപ്പിക്കും. ഇത് പഴയപടിയാക്കാനാവില്ല.';
  }

  @override
  String msgMergedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count വിലാസവിവരങ്ങൾ ലയിപ്പിച്ചു',
      one: 'ഒരു വിലാസവിവരം ലയിപ്പിച്ചു',
    );
    return '$_temp0';
  }

  @override
  String errorMergeFailed(String error) {
    return 'ലയനം പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get errorNothingSelectedToMerge =>
      'ലയിപ്പിക്കാൻ ഒന്നും തിരഞ്ഞെടുത്തിട്ടില്ല';

  @override
  String get titleMergeAllSets => 'എല്ലാ കൂട്ടങ്ങളും ലയിപ്പിക്കണോ?';

  @override
  String descMergeAllSets(int sets, int total) {
    return '$sets കൂട്ടം പരിഹരിച്ച് $total വിലാസവിവരം നിലനിർത്തിയവയിൽ ലയിപ്പിക്കും. ഇത് പഴയപടിയാക്കാനാവില്ല.';
  }

  @override
  String get actionMerge => 'ലയിപ്പിക്കുക';

  @override
  String get labelScanning => 'പരിശോധിക്കുന്നു…';

  @override
  String labelDuplicateSetsFound(int count) {
    return '$count ഇരട്ടിപ്പ് കൂട്ടം കണ്ടെത്തി';
  }

  @override
  String get labelNoDuplicates => 'ഇരട്ടിപ്പുകളില്ല';

  @override
  String get descTapToKeep =>
      'ഏത് നിലനിർത്തണമെന്ന് തിരഞ്ഞെടുക്കാൻ ഒരു വിലാസവിവരം തൊടുക; ബാക്കിയുള്ളവയുടെ ടിക്ക് മാറ്റുക.';

  @override
  String get labelAllCleanedUp => 'എല്ലാം വൃത്തിയായി';

  @override
  String get descNoMoreDuplicates =>
      'ഇനി ഇരട്ടിപ്പ് വിലാസവിവരങ്ങളില്ല. നിങ്ങളുടെ വിലാസപ്പുസ്തകം വൃത്തിയാണ്.';

  @override
  String get labelUnnamed => 'പേരില്ലാത്തത്';

  @override
  String get labelKeep => 'നിലനിർത്തുക';

  @override
  String labelKeepingMerging(int count) {
    return 'ഒന്ന് നിലനിർത്തുന്നു · $count ലയിപ്പിക്കുന്നു';
  }

  @override
  String get labelNothingSelected => 'ഒന്നും തിരഞ്ഞെടുത്തിട്ടില്ല';

  @override
  String get labelToMerge => 'ലയിപ്പിക്കാൻ';

  @override
  String get actionMergeAllSets => 'എല്ലാ കൂട്ടങ്ങളും ലയിപ്പിക്കുക';

  @override
  String msgAuditExported(int count) {
    return 'ഒപ്പിട്ട മാറ്റങ്ങളുടെ രേഖ വിജയകരമായി കയറ്റുമതി ചെയ്തു ($count എണ്ണം പരിശോധിച്ചു)';
  }

  @override
  String get titleClearAuditLog => 'മാറ്റങ്ങളുടെ രേഖ മായ്ക്കണോ?';

  @override
  String get descClearAuditLog =>
      'നിങ്ങളുടെ വിലാസവിവരങ്ങൾക്ക് മാറ്റമില്ല — അവ മാറിയതിന്റെ രേഖ മാത്രം മായും. ഇതുവരെ പഴയപടിയാക്കാത്തവ ഇനി പഴയപടിയാക്കാനാവില്ല.';

  @override
  String get msgAuditCleared => 'മാറ്റങ്ങളുടെ രേഖ മായ്ച്ചു';

  @override
  String get titleAuditLog => 'മാറ്റങ്ങളുടെ രേഖ';

  @override
  String get actionExportSignedAuditLog => 'ഒപ്പിട്ട രേഖ കയറ്റുമതി ചെയ്യുക';

  @override
  String get tooltipHideSecret => 'രഹസ്യ വിലാസവിവരങ്ങൾ മറയ്ക്കുക';

  @override
  String get tooltipShowSecret => 'രഹസ്യ വിലാസവിവരങ്ങൾ കാണിക്കുക';

  @override
  String get actionClearLog => 'രേഖ മായ്ക്കുക';

  @override
  String descAuditIntro(int days) {
    return 'ചേർത്തതും തിരുത്തിയതും ഇല്ലാതാക്കിയതുമായ ഓരോ വിലാസവിവരവും SHA-256 ക്രിപ്റ്റോഗ്രാഫിക് ഹാഷ് ശൃംഖലയോടെ $days ദിവസം ഇവിടെ രേഖപ്പെടുത്തുന്നു. മാറ്റങ്ങൾ കാണാൻ ഒരു എൻട്രി തൊടുക, അല്ലെങ്കിൽ കയറ്റുമതി ചെയ്യാൻ \"ഒപ്പിട്ട രേഖ കയറ്റുമതി ചെയ്യുക\" തൊടുക.';
  }

  @override
  String descChainVerified(int verified, int total) {
    return 'കൃത്രിമം തടയുന്ന ശൃംഖല പരിശോധിച്ചു ($verified / $total എണ്ണം ബന്ധിച്ചു)';
  }

  @override
  String descChainTampered(String row) {
    return 'സുരക്ഷാ മുന്നറിയിപ്പ്: #$row വരിയിൽ കൃത്രിമം കണ്ടെത്തി!';
  }

  @override
  String get labelAuditAdded => 'ചേർത്തവ';

  @override
  String get labelAuditEdited => 'തിരുത്തിയവ';

  @override
  String get labelAuditDeleted => 'ഇല്ലാതാക്കിയവ';

  @override
  String get emptyAuditNothing =>
      'ഇതുവരെ ഒന്നും രേഖപ്പെടുത്തിയിട്ടില്ല. നിങ്ങളുടെ വിലാസവിവരങ്ങളിലെ മാറ്റങ്ങൾ ഇവിടെ കാണാം.';

  @override
  String get emptyAuditFilter => 'ഈ അരിപ്പയിൽ ഒന്നും രേഖപ്പെടുത്തിയിട്ടില്ല.';

  @override
  String get labelSourceManual => 'ആപ്പിൽ';

  @override
  String get labelSourceDeviceSync => 'ഫോൺ വിലാസവിവര സമന്വയം';

  @override
  String get labelSourceMerge => 'ലയിപ്പിച്ച ഇരട്ടിപ്പുകൾ';

  @override
  String get labelSourceRestore => 'കരുതൽശേഖര പുനഃസ്ഥാപനം';

  @override
  String get labelSourceP2pSync => 'മറ്റൊരു ഉപകരണത്തിൽ നിന്നുള്ള സമന്വയം';

  @override
  String get labelSourceImport => 'ഫയൽ ഇറക്കുമതി';

  @override
  String get labelSourceUndo => 'രേഖയിൽ നിന്ന് പഴയപടിയാക്കൽ';

  @override
  String get labelSourceUnknown => 'അജ്ഞാതം';

  @override
  String get titleUndoThisChange => 'ഈ മാറ്റം പഴയപടിയാക്കണോ?';

  @override
  String get actionUndo => 'പഴയപടിയാക്കുക';

  @override
  String get msgContactRemovedAgain => 'വിലാസവിവരം വീണ്ടും നീക്കി';

  @override
  String get msgChangeUndone => 'മാറ്റം പഴയപടിയാക്കി';

  @override
  String errorUndoFailed(String error) {
    return 'പഴയപടിയാക്കൽ പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get titleChangeDetails => 'മാറ്റത്തിന്റെ വിശദാംശങ്ങൾ';

  @override
  String get descNoVisibleChange =>
      'രേഖയിൽ കാണുന്ന ഒരു വിവരവും വ്യത്യസ്തമല്ല. ഈ വിലാസവിവരത്തിൽ എന്തോ എഴുതിയതുകൊണ്ടാണ് മാറ്റം രേഖപ്പെടുത്തിയത്.';

  @override
  String get labelWhatChanged => 'എന്ത് മാറി';

  @override
  String get labelBefore => 'മുമ്പ്';

  @override
  String get labelAfter => 'ശേഷം';

  @override
  String get descUndone =>
      'ഈ മാറ്റം പഴയപടിയാക്കി. പഴയപടിയാക്കിയതും ഒരു പുതിയ എൻട്രിയായി രേഖപ്പെടുത്തുന്നു.';

  @override
  String get descCannotUndo =>
      'ഇത് പഴയപടിയാക്കാനാവില്ല — മുമ്പത്തെ രൂപത്തിന്റെ സൂക്ഷിച്ച പകർപ്പില്ല.';

  @override
  String get labelUndone => 'പഴയപടിയാക്കി';

  @override
  String get actionUndoThisChange => 'ഈ മാറ്റം പഴയപടിയാക്കുക';

  @override
  String get titleOpenThisContact => 'ഈ വിലാസവിവരം തുറക്കുക';

  @override
  String get descSeeContactNow => 'വിലാസവിവരം ഇപ്പോഴുള്ളതുപോലെ കാണുക';

  @override
  String get descUndoCreate =>
      'പഴയപടിയാക്കൽ ഈ വിലാസവിവരം വീണ്ടും ഇല്ലാതാക്കും.';

  @override
  String get descUndoUpdate => 'പഴയപടിയാക്കൽ പഴയ വിവരങ്ങൾ തിരികെ വയ്ക്കും.';

  @override
  String get descUndoDelete =>
      'പഴയപടിയാക്കൽ ഈ വിലാസവിവരം വീണ്ടും സൃഷ്ടിക്കും. ഇതിന് പുതിയ id ലഭിക്കും, അതിനാൽ പഴയ വിളി ചരിത്രം ബന്ധിപ്പിക്കപ്പെടില്ല; മറ്റേയാൾ ഇപ്പോഴും ഉള്ള ബന്ധങ്ങൾ മാത്രം തിരികെ വരും.';

  @override
  String get labelPhoto => 'ഫോട്ടോ';

  @override
  String get labelSecret => 'രഹസ്യം';

  @override
  String get labelFavourite => 'പ്രിയപ്പെട്ടത്';

  @override
  String get labelSelf => 'സ്വയം';

  @override
  String get labelPhoneContactsLink => 'ഫോൺ വിലാസവിവര ബന്ധം';

  @override
  String get labelAddresses => 'വിലാസങ്ങൾ';

  @override
  String get labelWorkDetails => 'ജോലി വിവരങ്ങൾ';

  @override
  String get actionBackUpNow => 'ഇപ്പോൾ കരുതൽശേഖരം എടുക്കുക';

  @override
  String get descBackUpNow =>
      'നിങ്ങളുടെ എല്ലാ വിലാസവിവരങ്ങളും ഫോട്ടോകളും ക്രമീകരണങ്ങളും പാസ്‌വേഡ് സുരക്ഷയുള്ള ഒരു ഫയലിൽ സൂക്ഷിക്കുക.';

  @override
  String get actionRestoreFromFile => 'ഫയലിൽ നിന്ന് പുനഃസ്ഥാപിക്കുക';

  @override
  String get descRestoreFromFile =>
      'ഒരു കരുതൽശേഖര ഫയൽ തുറക്കുക. ഇത് ഇപ്പോൾ ആപ്പിലുള്ളതെല്ലാം മാറ്റിസ്ഥാപിക്കും.';

  @override
  String get descBackupPasswordNote =>
      'കരുതൽശേഖരം നിങ്ങളുടെ പാസ്‌വേഡ് കൊണ്ട് പൂട്ടിയിരിക്കുന്നു. അത് സുരക്ഷിതമായി സൂക്ഷിക്കുക — അതില്ലാതെ ഈ ഫോണിലോ മറ്റേതെങ്കിലും ഫോണിലോ ഫയൽ തുറക്കാനാവില്ല. പുതിയ ഫോണിൽ പുനഃസ്ഥാപിക്കാനും ഇതേ പാസ്‌വേഡ് വേണം.';

  @override
  String get msgCreatingBackup => 'കരുതൽശേഖരം തയ്യാറാക്കുന്നു…';

  @override
  String get msgBackupReady =>
      'കരുതൽശേഖരം തയ്യാർ. എവിടെ സൂക്ഷിക്കണമെന്ന് തിരഞ്ഞെടുക്കുക.';

  @override
  String errorBackupFailed(String error) {
    return 'കരുതൽശേഖരം പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get msgRestoring => 'പുനഃസ്ഥാപിക്കുന്നു…';

  @override
  String get msgRestoreComplete => 'പുനഃസ്ഥാപനം പൂർത്തിയായി.';

  @override
  String errorRestoreFailed(String error) {
    return 'പുനഃസ്ഥാപനം പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get titleReplaceAllData => 'എല്ലാ വിവരങ്ങളും മാറ്റിസ്ഥാപിക്കണോ?';

  @override
  String get descReplaceAllData =>
      'പുനഃസ്ഥാപിക്കുമ്പോൾ ഇപ്പോൾ ആപ്പിലുള്ളതെല്ലാം — എല്ലാ വിലാസവിവരങ്ങളും ഫോൺ വിളി ചരിത്രവും ഗ്രൂപ്പുകളും ക്രമീകരണങ്ങളും — ഇല്ലാതാക്കി കരുതൽശേഖരം കൊണ്ട് മാറ്റിസ്ഥാപിക്കും. ഇത് പഴയപടിയാക്കാനാവില്ല.';

  @override
  String errorPasswordTooShort(int count) {
    return 'കുറഞ്ഞത് $count അക്ഷരങ്ങൾ ഉപയോഗിക്കുക.';
  }

  @override
  String get errorPasswordsDontMatch => 'പാസ്‌വേഡുകൾ ഒത്തുപോകുന്നില്ല.';

  @override
  String get errorEnterBackupPassword => 'കരുതൽശേഖരത്തിന്റെ പാസ്‌വേഡ് നൽകുക.';

  @override
  String get titleSetBackupPassword => 'കരുതൽശേഖര പാസ്‌വേഡ് സജ്ജമാക്കുക';

  @override
  String get titleBackupPassword => 'കരുതൽശേഖര പാസ്‌വേഡ്';

  @override
  String get labelPassword => 'പാസ്‌വേഡ്';

  @override
  String get labelEnterPassword => 'പാസ്‌വേഡ് നൽകുക';

  @override
  String get labelConfirmPassword => 'പാസ്‌വേഡ് സ്ഥിരീകരിക്കുക';

  @override
  String get actionBackUp => 'കരുതൽശേഖരം എടുക്കുക';

  @override
  String get actionRestore => 'പുനഃസ്ഥാപിക്കുക';

  @override
  String get titleSendToDevice => 'മറ്റൊരു ഉപകരണത്തിലേക്ക് അയയ്ക്കുക';

  @override
  String get descSendToDevice =>
      'Wi-Fi വഴി നിങ്ങളുടെ വിലാസവിവരങ്ങളും (മറ്റും) മറ്റൊരു ഫോണുമായി പങ്കിടുക.';

  @override
  String get titleReceiveFromDevice => 'മറ്റൊരു ഉപകരണത്തിൽ നിന്ന് സ്വീകരിക്കുക';

  @override
  String get descReceiveFromDevice =>
      'മറ്റൊരു ഫോണിലെ വിലാസവിവരങ്ങൾ ഈ ഫോണിലേക്ക് ചേർക്കുക. ഇവിടെ ഇപ്പോഴുള്ള ഒന്നും മാറ്റുകയോ നീക്കുകയോ ഇല്ല.';

  @override
  String get descSyncFooter =>
      'രണ്ട് ഫോണുകളും ഒരേ Wi-Fi ശൃംഖലയിലായിരിക്കണം, ഈ ആപ്പ് പ്രവർത്തിപ്പിക്കുകയും വേണം.';

  @override
  String get descSameWifi => 'രണ്ട് ഫോണുകളും ഒരേ Wi-Fi ശൃംഖലയിലായിരിക്കണം.';

  @override
  String get msgConnecting => 'ബന്ധിപ്പിക്കുന്നു…';

  @override
  String get msgWaitingForSender =>
      'ബന്ധിപ്പിച്ചു — അയയ്ക്കുന്നയാൾ തിരഞ്ഞെടുക്കുന്നതിനായി കാത്തിരിക്കുന്നു…';

  @override
  String get titleReceived => 'ലഭിച്ചു';

  @override
  String descReceivedSummary(int added, int skipped) {
    return '$added പുതിയ വിലാസവിവരങ്ങൾ ചേർത്തു (ഈ ഫോണിൽ നേരത്തേയുണ്ടായിരുന്ന $skipped എണ്ണം നിലനിർത്തി). ഒന്നും നീക്കിയില്ല.';
  }

  @override
  String get titleCouldNotReceive => 'സ്വീകരിക്കാനായില്ല';

  @override
  String get errorEnterAddressPortCode =>
      'വിലാസം, പോർട്ട്, ജോടിയാക്കൽ കോഡ് എന്നിവ നൽകുക';

  @override
  String get descReceiveAddsOnly =>
      'ഇത് മറ്റേ ഫോണിലെ വിലാസവിവരങ്ങൾ ഈ ഫോണിലേക്ക് ചേർക്കുന്നു. നിലവിലുള്ള വിലാസവിവരങ്ങൾ അതേപടി നിലനിർത്തും — ഇവിടെ ഒന്നും മാറ്റുകയോ നീക്കുകയോ ഇല്ല.';

  @override
  String get actionScanOtherPhoneQr => 'മറ്റേ ഫോണിലെ QR സ്കാൻ ചെയ്യുക';

  @override
  String get descOrEnterByHand => 'അല്ലെങ്കിൽ കൈകൊണ്ട് നൽകുക';

  @override
  String get labelOtherPhoneAddress => 'മറ്റേ ഫോണിന്റെ വിലാസം';

  @override
  String get labelPort => 'പോർട്ട്';

  @override
  String get labelPairingCode => 'ജോടിയാക്കൽ കോഡ്';

  @override
  String get hintShownOnOtherPhone => 'മറ്റേ ഫോണിൽ കാണിച്ചിരിക്കുന്നത്';

  @override
  String get actionConnect => 'ബന്ധിപ്പിക്കുക';

  @override
  String get errorNotPairingCode =>
      'ഇത് SreerajP Contacts Sphere ജോടിയാക്കൽ കോഡ് അല്ല';

  @override
  String get titleScanPairingCode => 'ജോടിയാക്കൽ കോഡ് സ്കാൻ ചെയ്യുക';

  @override
  String get titleSent => 'അയച്ചു';

  @override
  String descSentSummary(int contacts, int groups, int callLogs) {
    return '$contacts വിലാസവിവരങ്ങളും $groups ഗ്രൂപ്പുകളും $callLogs ഫോൺ വിളി രേഖകളും മറ്റേ ഫോണിലേക്ക് അയച്ചു.';
  }

  @override
  String get titleCouldNotSend => 'അയയ്ക്കാനായില്ല';

  @override
  String get descSendIntro =>
      'ഈ ഫോണിലെ SreerajP Contacts Sphere വിവരങ്ങൾ ഒരേ Wi-Fi-യിലുള്ള മറ്റൊരു ഫോണുമായി പങ്കിടുക. താഴെ ആരംഭിക്കുക, തുടർന്ന് മറ്റേ ഫോണിൽ QR സ്കാൻ ചെയ്യുക (അല്ലെങ്കിൽ കോഡ് ടൈപ്പ് ചെയ്യുക). ബന്ധിപ്പിച്ച ശേഷം എന്ത് അയയ്ക്കണമെന്ന് തിരഞ്ഞെടുക്കുക.';

  @override
  String get actionStart => 'ആരംഭിക്കുക';

  @override
  String get descScanThisCode =>
      'മറ്റേ ഫോണിൽ സ്വീകരിക്കുക തിരഞ്ഞെടുത്ത് ഈ കോഡ് സ്കാൻ ചെയ്യുക:';

  @override
  String get descEnterTheseByHand => '…അല്ലെങ്കിൽ ഇവ കൈകൊണ്ട് നൽകുക:';

  @override
  String get labelThisPhoneAddress => 'ഈ ഫോണിന്റെ വിലാസം';

  @override
  String get actionCopyCode => 'കോഡ് പകർത്തുക';

  @override
  String get msgAddressCopied => 'വിലാസം പകർത്തി';

  @override
  String get msgCodeCopied => 'കോഡ് പകർത്തി';

  @override
  String get msgWaitingForOtherPhone => 'മറ്റേ ഫോണിനായി കാത്തിരിക്കുന്നു…';

  @override
  String get labelOtherPhoneConnected => 'മറ്റേ ഫോൺ ബന്ധിപ്പിച്ചു';

  @override
  String get labelCallHistory => 'ഫോൺ വിളി ചരിത്രം';

  @override
  String get labelBlockedSpamNumbers => 'തടഞ്ഞതും സ്പാമുമായ നമ്പറുകൾ';

  @override
  String get labelEmergencyInfoCard => 'അടിയന്തര വിവര കാർഡ്';

  @override
  String get labelAppSettings => 'ആപ്പ് ക്രമീകരണങ്ങൾ';

  @override
  String get titleChooseWhatToShare => 'എന്ത് പങ്കിടണമെന്ന് തിരഞ്ഞെടുക്കുക';

  @override
  String get descNeverOverrides =>
      'ഇത് മറ്റേ ഫോണിൽ നേരത്തേയുള്ള ഒന്നിനെയും മാറ്റിയെഴുതില്ല. പൊരുത്തക്കേടുണ്ടായാൽ മറ്റേ ഫോൺ അതിന്റെ സ്വന്തം വിവരങ്ങൾ നിലനിർത്തും.';

  @override
  String get actionFullSyncNewPhone => 'പൂർണ്ണ സമന്വയം (പുതിയ ഫോണിന്)';

  @override
  String get labelOrSendOnly => 'അല്ലെങ്കിൽ ഇവ മാത്രം അയയ്ക്കുക:';

  @override
  String get labelAlwaysIncluded => 'എപ്പോഴും ഉൾപ്പെടുന്നു';

  @override
  String get actionSendSelected => 'തിരഞ്ഞെടുത്തവ അയയ്ക്കുക';

  @override
  String get titleFullSync => 'പൂർണ്ണ സമന്വയം?';

  @override
  String get descFullSync =>
      'എല്ലാം അയയ്ക്കുക (വിലാസവിവരങ്ങൾ, ഗ്രൂപ്പുകൾ, ഫോൺ വിളി ചരിത്രം, ബന്ധങ്ങൾ, തടഞ്ഞ നമ്പറുകൾ, ക്രമീകരണങ്ങൾ). പുതിയ ഫോണിന് ഏറ്റവും അനുയോജ്യം. മറ്റേ ഫോൺ നേരത്തേയുള്ള വിവരങ്ങൾ നിലനിർത്തും.';

  @override
  String get actionSendEverything => 'എല്ലാം അയയ്ക്കുക';

  @override
  String get descScreenshotGuardRow =>
      'സ്ക്രീൻഷോട്ടുകൾ, റെക്കോർഡിംഗുകൾ, സമീപകാല ആപ്പുകളിലെ ദൃശ്യം എന്നിവ തടയുക';

  @override
  String get descAuditLogRow =>
      'നിങ്ങളുടെ വിലാസവിവരങ്ങളിൽ എന്ത് മാറി, അത് എങ്ങനെ പഴയപടിയാക്കാം';

  @override
  String get descLockOff => 'ഓഫ് — ആപ്പ് പൂട്ടില്ലാതെ തുറക്കും';

  @override
  String get descLockDevice => 'ഓൺ — ഉപകരണത്തിന്റെ പൂട്ട് കൊണ്ട് തുറക്കുക';

  @override
  String get descLockAppPin => 'ഓൺ — ആപ്പ് PIN കൊണ്ട് തുറക്കുക';

  @override
  String get titleAppLock => 'ആപ്പ് പൂട്ട്';

  @override
  String get labelLockOff => 'ഓഫ്';

  @override
  String get descLockOffOption => 'ആപ്പ് തുറക്കുമ്പോൾ പൂട്ടില്ല';

  @override
  String get labelDeviceLock => 'ഉപകരണ പൂട്ട്';

  @override
  String get descDeviceLockOption => 'വിരലടയാളം, മുഖം അല്ലെങ്കിൽ ഉപകരണ PIN';

  @override
  String get descDeviceLockUnavailable =>
      'ഇത് ഉപയോഗിക്കാൻ ഉപകരണത്തിൽ സ്ക്രീൻ പൂട്ട് സജ്ജമാക്കുക';

  @override
  String get labelAppPin => 'ആപ്പ് PIN';

  @override
  String get descAppPinOption => 'ഈ ആപ്പിന് മാത്രമായി വേറൊരു PIN';

  @override
  String get descUnlockReason => 'SreerajP Contacts Sphere തുറക്കുക';

  @override
  String get titleAppLocked => 'SreerajP Contacts Sphere പൂട്ടിയിരിക്കുന്നു';

  @override
  String get descUnlockDevice =>
      'തുടരാൻ വിരലടയാളം, മുഖം അല്ലെങ്കിൽ ഉപകരണ PIN കൊണ്ട് തുറക്കുക';

  @override
  String get labelUnlocking => 'തുറക്കുന്നു…';

  @override
  String get actionUnlock => 'തുറക്കുക';

  @override
  String get descEnterAppPin => 'തുടരാൻ ആപ്പ് PIN നൽകുക';

  @override
  String get actionForgotPin => 'PIN മറന്നോ?';

  @override
  String get titleEnterRecoveryCode => 'വീണ്ടെടുക്കൽ കോഡ് നൽകുക';

  @override
  String get descEnterRecoveryCode =>
      'PIN സജ്ജമാക്കിയപ്പോൾ സൂക്ഷിച്ച വീണ്ടെടുക്കൽ കോഡ് നൽകുക. ഇത് ആപ്പ് പൂട്ട് ഓഫാക്കും, അപ്പോൾ പുതിയ PIN സജ്ജമാക്കാം.';

  @override
  String get labelRecoveryCode => 'വീണ്ടെടുക്കൽ കോഡ്';

  @override
  String get errorIncorrectCode => 'തെറ്റായ കോഡ്';

  @override
  String get titleSetAppPin => 'ആപ്പ് PIN സജ്ജമാക്കുക';

  @override
  String get titleConfirmPin => 'PIN സ്ഥിരീകരിക്കുക';

  @override
  String get titleSaveRecoveryCode => 'വീണ്ടെടുക്കൽ കോഡ് സൂക്ഷിക്കുക';

  @override
  String get descChoosePin => 'ആപ്പ് തുറക്കാൻ 4 മുതൽ 6 അക്ക PIN തിരഞ്ഞെടുക്കുക';

  @override
  String get descEnterSamePin => 'അതേ PIN വീണ്ടും നൽകുക';

  @override
  String get descRecoveryCodeInfo =>
      'PIN മറന്നാൽ ഈ കോഡ് കൊണ്ട് വീണ്ടും കയറാം. ഇത് എഴുതി സുരക്ഷിതമായി സൂക്ഷിക്കുക — ഒരിക്കൽ മാത്രമേ കാണിക്കൂ.';

  @override
  String get errorCouldNotSavePin =>
      'PIN സൂക്ഷിക്കാനായില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get errorPinsDidntMatch => 'PIN-കൾ ഒത്തുപോയില്ല — വീണ്ടും തുടങ്ങുക';

  @override
  String get actionConfirm => 'സ്ഥിരീകരിക്കുക';

  @override
  String get msgRecoveryCodeCopied => 'വീണ്ടെടുക്കൽ കോഡ് പകർത്തി';

  @override
  String get actionCopy => 'പകർത്തുക';

  @override
  String get actionSavedTurnOnLock => 'സൂക്ഷിച്ചു — ആപ്പ് പൂട്ട് ഓണാക്കുക';

  @override
  String get descThemeModeRow =>
      'ലൈറ്റ്, ഡാർക്ക്, അല്ലെങ്കിൽ സിസ്റ്റം രീതി തിരഞ്ഞെടുക്കുക';

  @override
  String get descTypographyRow => 'ആപ്പിന്റെ അക്ഷരരൂപവും അക്ഷരവലുപ്പവും';

  @override
  String get descAccentColorRow =>
      'സ്വന്തം നിറങ്ങൾ, മുൻനിശ്ചിത നിറങ്ങൾ, തത്സമയ ദൃശ്യം';

  @override
  String titleSpeedDialSlot(int slot) {
    return 'സ്പീഡ് ഡയൽ $slot';
  }

  @override
  String get descSpeedDialIntro =>
      'ഡയലറിലെ ഒരു കീ അമർത്തിപ്പിടിച്ചാൽ അതിൽ സൂക്ഷിച്ച ആളെ വിളിക്കാം. നമ്പർ പെട്ടി ശൂന്യമാകുമ്പോൾ മാത്രമേ ഇത് പ്രവർത്തിക്കൂ. രഹസ്യ വിലാസവിവരങ്ങൾ ഒരു കീയിൽ സൂക്ഷിക്കാനാവില്ല.';

  @override
  String get descTapToChooseContact => 'ഒരു വിലാസവിവരം തിരഞ്ഞെടുക്കാൻ തൊടുക';

  @override
  String tooltipRemoveFromKey(int slot) {
    return '$slot കീയിൽ നിന്ന് നീക്കുക';
  }

  @override
  String get descDefaultCountryInfo =>
      'വരുന്നതും വിളിച്ചതുമായ നമ്പറുകൾ നിങ്ങളുടെ വിലാസവിവരങ്ങളുമായി ഒത്തുനോക്കാൻ ഉപയോഗിക്കുന്നു';

  @override
  String get tooltipOpenSystemSettings => 'സിസ്റ്റം ക്രമീകരണങ്ങൾ തുറക്കുക';

  @override
  String get labelExplicitPerms => 'നേരിട്ട് അനുവദിക്കുന്നവ';

  @override
  String get descExplicitPerms =>
      'ഉപയോക്താവ് നേരിട്ട് അനുവദിക്കേണ്ട അനുമതികളും സിസ്റ്റം ചുമതലകളും.';

  @override
  String get labelImplicitPerms => 'സ്വയം ലഭിക്കുന്നവ';

  @override
  String get descImplicitPerms =>
      'ആപ്പിൽ പ്രഖ്യാപിച്ചവ; സ്ഥാപിക്കുമ്പോൾ സിസ്റ്റം സ്വയം അനുവദിക്കുന്നു.';

  @override
  String get labelGranted => 'അനുവദിച്ചു';

  @override
  String get labelDenied => 'നിരസിച്ചു';

  @override
  String get labelPermDialer => 'സ്ഥിര ഫോൺ ആപ്പ്';

  @override
  String get descPermDialer =>
      'SreerajP Contacts Sphere-ന്റെ സ്വന്തം വിളി സ്ക്രീനും വിളി പരിശോധനാ നിയന്ത്രണങ്ങളും കാണിക്കാൻ സിസ്റ്റം ഡയലറാകുക.';

  @override
  String get labelPermContacts => 'വിലാസവിവരങ്ങൾ';

  @override
  String get descPermContacts =>
      'ഉപകരണത്തിലെ വിലാസപ്പുസ്തകത്തിൽ നിന്ന് വിലാസവിവരങ്ങൾ വായിക്കാനും സമന്വയിപ്പിക്കാനും.';

  @override
  String get labelPermPhone => 'ഫോണും വിളി രേഖയും';

  @override
  String get descPermPhone =>
      'ഫോൺ വിളികൾ ചെയ്യാനും എടുക്കാനും നിയന്ത്രിക്കാനും, വിളി രേഖയിൽ നിന്ന് യഥാർത്ഥ ദൈർഘ്യം ഒത്തുനോക്കാനും.';

  @override
  String get labelPermMicrophone => 'മൈക്രോഫോൺ';

  @override
  String get descPermMicrophone => 'കുറിപ്പുകൾ ചേർക്കുമ്പോൾ ശബ്ദം വഴി എഴുതാൻ.';

  @override
  String get labelPermLocation => 'സ്ഥാനം';

  @override
  String get descPermLocation =>
      'വിലാസവിവരങ്ങളിൽ സ്ഥലങ്ങൾ അടയാളപ്പെടുത്താനും പഴയ Android-ൽ BLE തിരയലിനും.';

  @override
  String get labelPermNotifications => 'അറിയിപ്പുകൾ';

  @override
  String get descPermNotifications =>
      'ജന്മദിനങ്ങൾ, തുടർനടപടികൾ, നഷ്ടമായ ഫോൺ വിളികൾ എന്നിവയുടെ ഓർമ്മപ്പെടുത്തലുകൾ കാണിക്കാൻ.';

  @override
  String get labelPermAlarms => 'അലാറങ്ങളും ഓർമ്മപ്പെടുത്തലുകളും';

  @override
  String get descPermAlarms =>
      'ആപ്പ് അടച്ചിരുന്നാലും Smart Redial നിശ്ചിത സമയത്ത് തിരികെ വിളിക്കാൻ.';

  @override
  String get labelPermPhotos => 'ഫോട്ടോകളും മീഡിയയും';

  @override
  String get descPermPhotos =>
      'ഗാലറിയിൽ നിന്ന് വിലാസവിവരത്തിന് ഫോട്ടോ തിരഞ്ഞെടുക്കാൻ.';

  @override
  String get labelPermCamera => 'ക്യാമറ';

  @override
  String get descPermCamera =>
      'വിലാസവിവരത്തിന് പുതിയ ഫോട്ടോ എടുക്കാനോ QR കോഡുകൾ സ്കാൻ ചെയ്യാനോ.';

  @override
  String get labelPermBtScan => 'ബ്ലൂടൂത്ത് തിരയൽ';

  @override
  String get descPermBtScan =>
      'ബ്ലൂടൂത്ത് വഴി വിലാസവിവരം പങ്കിടുന്ന അടുത്തുള്ള ഫോൺ കണ്ടെത്താൻ (neverForLocation സഹിതം പ്രഖ്യാപിച്ചത്).';

  @override
  String get labelPermBtConnect => 'ബ്ലൂടൂത്ത് ബന്ധം';

  @override
  String get descPermBtConnect =>
      'ബ്ലൂടൂത്ത് വഴി വിലാസവിവരങ്ങൾ കൈമാറാൻ മറ്റൊരു ഫോണുമായി ബന്ധിപ്പിക്കാൻ.';

  @override
  String get labelPermBtAdvertise => 'ബ്ലൂടൂത്ത് ദൃശ്യത';

  @override
  String get descPermBtAdvertise =>
      'ബ്ലൂടൂത്ത് വഴി വിലാസവിവരങ്ങൾ പങ്കിടുമ്പോൾ ഈ ഫോൺ മറ്റുള്ളവർക്ക് കാണാനാകാൻ.';

  @override
  String get labelPermBiometrics => 'ബയോമെട്രിക്സ്';

  @override
  String get descPermBiometrics =>
      'വിരലടയാളമോ മുഖമോ ഉപയോഗിച്ച് രഹസ്യ വിലാസവിവരങ്ങൾ തുറക്കാനും അവ കയറ്റുമതി/സമന്വയം ചെയ്യുംമുമ്പ് സ്ഥിരീകരിക്കാനും.';

  @override
  String get labelPermProximity => 'ചെവിക്കടുത്ത് സ്ക്രീൻ ഓഫ്';

  @override
  String get descPermProximity =>
      'ഫോൺ വിളിക്കിടെ ഫോൺ ചെവിയോട് ചേർത്തുപിടിക്കുമ്പോൾ കവിൾ നിയന്ത്രണങ്ങളിൽ തൊടാതിരിക്കാൻ സ്ക്രീൻ ഓഫാക്കുന്നു.';

  @override
  String get labelPermCallService => 'വിളി സേവനവും റിംഗിംഗും';

  @override
  String get descPermCallService =>
      'സജീവ വിളി സേവനങ്ങൾ, പൂർണ്ണ സ്ക്രീൻ ഇൻകമിംഗ് അറിയിപ്പുകൾ, വിളി വരുമ്പോൾ കമ്പനം എന്നിവ പ്രവർത്തിപ്പിക്കുന്നു.';

  @override
  String get labelPermBtLegacy => 'ബ്ലൂടൂത്ത് (പഴയത്)';

  @override
  String get descPermBtLegacy =>
      'Android 11-ലും അതിന് താഴെയുമുള്ളവയിൽ ബ്ലൂടൂത്ത് ഉപയോഗം.';

  @override
  String get labelPermBoot => 'പുനരാരംഭത്തിനു ശേഷം തുടങ്ങുക';

  @override
  String get descPermBoot =>
      'ഫോൺ പുനരാരംഭിച്ച ശേഷം അടിയന്തര വിവര കാർഡ് ലോക്ക് സ്ക്രീനിൽ തിരികെ വയ്ക്കുന്നു. മറ്റൊന്നിനും ഉപയോഗിക്കുന്നില്ല.';

  @override
  String get labelPermInternet => 'ഇന്റർനെറ്റും Wi-Fi-യും';

  @override
  String get descPermInternet =>
      'P2P സമന്വയ സമയത്ത് പ്രാദേശിക Wi-Fi വഴി നിങ്ങളുടെ വിവരങ്ങൾ മറ്റൊരു ഫോണിലേക്ക് പകർത്തുന്നു. ഒരു ക്ലൗഡ് സെർവറുമായും ബന്ധപ്പെടുന്നില്ല.';

  @override
  String get tooltipRefreshSims => 'SIM-കൾ പുതുക്കുക';

  @override
  String get emptyNoSims =>
      'SIM ഒന്നും കണ്ടെത്തിയില്ല. ഒന്നിലധികം SIM ഓപ്ഷനുകൾക്ക് ഫോൺ അനുമതിയും കുറഞ്ഞത് ഒരു SIM ഉള്ള ഉപകരണവും വേണം. ഫോൺ അനുമതി നൽകി പുതുക്കുക തൊടുക.';

  @override
  String get descDefaultSimInfo =>
      'ഓരോ വിളിക്കും തിരഞ്ഞെടുക്കാത്തപ്പോൾ പുറത്തേക്കുള്ള ഫോൺ വിളികൾ ഉപയോഗിക്കുന്ന SIM';

  @override
  String get descLetAndroidChoose => 'Android തിരഞ്ഞെടുക്കട്ടെ';

  @override
  String get labelAskSimEachCall => 'ഓരോ വിളിക്കും മുമ്പ് SIM ചോദിക്കുക';

  @override
  String get descAskSimEachCall =>
      'ഓരോ തവണ വിളിക്കുമ്പോഴും SIM തിരഞ്ഞെടുക്കാൻ കാണിക്കുക';

  @override
  String get descNeedsMoreThanOneSim => 'ഒന്നിലധികം SIM വേണം';

  @override
  String get labelSimColours => 'SIM നിറങ്ങൾ';

  @override
  String get descSimColoursInfo =>
      'വിളി സ്ക്രീനിൽ SIM പേര് ഈ നിറത്തിൽ കാണിക്കും';

  @override
  String get labelDefaultColour => 'സ്ഥിര നിറം';

  @override
  String titleColourFor(String name) {
    return '$name-നുള്ള നിറം';
  }

  @override
  String get actionUseDefault => 'സ്ഥിരമായത് ഉപയോഗിക്കുക';

  @override
  String get titlePerSimRingtones => 'ഓരോ SIM-നും റിംഗ്‌ടോൺ';

  @override
  String get emptyNoSimsRingtone =>
      'SIM ഒന്നും കണ്ടെത്തിയില്ല. ഓരോ SIM-നുമുള്ള റിംഗ്‌ടോണിന് ഫോൺ അനുമതിയും കുറഞ്ഞത് ഒരു SIM ഉള്ള ഉപകരണവും വേണം. ഫോൺ അനുമതി നൽകി പുതുക്കുക തൊടുക.';

  @override
  String get labelPerSimRingtone => 'ഓരോ SIM-നും റിംഗ്‌ടോൺ';

  @override
  String get descPerSimRingtone =>
      'ഓരോ SIM-ലും വരുന്ന ഫോൺ വിളികൾക്ക് ഒരു റിംഗ്‌ടോൺ';

  @override
  String get tooltipChangeRingtone => 'റിംഗ്‌ടോൺ മാറ്റുക';

  @override
  String get tooltipPickRingtone => 'റിംഗ്‌ടോൺ തിരഞ്ഞെടുക്കുക';

  @override
  String get descPerContactRingtoneNote =>
      'ഒരു വിലാസവിവരത്തിന് നൽകിയ റിംഗ്‌ടോണിനാണ് SIM റിംഗ്‌ടോണിനേക്കാൾ മുൻഗണന. വിലാസവിവരം തിരുത്തുന്ന സ്ക്രീനിൽ നിന്ന് അത് നൽകാം.';

  @override
  String descSlotDefaultRingtone(String slot) {
    return '$slot · സ്ഥിര റിംഗ്‌ടോൺ';
  }

  @override
  String descSlotDefaultTone(String slot, String tone) {
    return '$slot · സ്ഥിരം · $tone';
  }

  @override
  String get titleVolumeVibration => 'ശബ്ദവും കമ്പനവും';

  @override
  String get labelRingtoneVolume => 'റിംഗ്‌ടോൺ ശബ്ദം';

  @override
  String get descRingtoneMuted =>
      'നിശ്ശബ്ദം — റിംഗ്‌ടോൺ കേൾക്കില്ല, പക്ഷേ താഴെ കമ്പനം ഓണാണെങ്കിൽ ഫോൺ കമ്പനം ചെയ്യും';

  @override
  String descRingtoneVolumePercent(int value) {
    return 'വരുന്ന ഫോൺ വിളികളുടെ റിംഗ്‌ടോൺ ഫോണിന്റെ റിംഗ് ശബ്ദത്തിന്റെ $value% ൽ കേൾപ്പിക്കുന്നു';
  }

  @override
  String get labelVibrateIncoming => 'വരുന്ന ഫോൺ വിളികളിൽ കമ്പനം';

  @override
  String get descVibrateIncoming =>
      'ഫോണിന്റെ ക്രമീകരണങ്ങൾക്കാണ് മുൻഗണന: നിശ്ശബ്ദ രീതി, ശല്യപ്പെടുത്തരുത്, ഫോണിന്റെ സ്വന്തം “വിളികൾക്ക് കമ്പനം” ക്രമീകരണം എന്നിവ ഇതിനെ മറികടക്കും';

  @override
  String get descQuietHoursSwitch =>
      'തിരഞ്ഞെടുത്ത അനുവദിച്ച വിലാസവിവരങ്ങൾ ഒഴികെ രാത്രിയിൽ ഫോൺ വിളികൾ നിശ്ശബ്ദമാക്കുക';

  @override
  String get labelQuietHoursRange => 'നിശ്ശബ്ദ സമയപരിധി';

  @override
  String get labelAllowedRingThrough =>
      'അനുവദിച്ച വിലാസവിവരങ്ങൾ (റിംഗ് ചെയ്യും)';

  @override
  String get descAllowedRingThrough =>
      'അനുവദിച്ച ബന്ധങ്ങളിലോ അടയാളങ്ങളിലോ ഉള്ളവരും തിരഞ്ഞെടുത്ത വിലാസവിവരങ്ങളും ഉറക്കെ റിംഗ് ചെയ്യും; മറ്റുള്ളവ നിശ്ശബ്ദമാക്കും.';

  @override
  String get labelAllowedRelationships => 'അനുവദിച്ച ബന്ധങ്ങളും വിഭാഗങ്ങളും';

  @override
  String get labelEmergencyContactsIce => 'അടിയന്തര വിലാസവിവരങ്ങൾ (ICE)';

  @override
  String get labelStarredContacts => 'നക്ഷത്രമിട്ട വിലാസവിവരങ്ങൾ';

  @override
  String get actionAddRelationship => 'ബന്ധം ചേർക്കുക';

  @override
  String get labelAllowedTags => 'അനുവദിച്ച അടയാളങ്ങൾ';

  @override
  String get actionAddTag => 'അടയാളം ചേർക്കുക';

  @override
  String get labelSpecificContacts => 'തിരഞ്ഞെടുത്ത വിലാസവിവരങ്ങൾ';

  @override
  String labelContactNumber(int id) {
    return 'വിലാസവിവരം #$id';
  }

  @override
  String get actionAddContact => 'വിലാസവിവരം ചേർക്കുക';

  @override
  String labelAllowedActiveNumbers(int count) {
    return 'അനുവദിച്ച സജീവ നമ്പറുകൾ: $count';
  }

  @override
  String get titleSelectAllowedRelationships =>
      'അനുവദിച്ച ബന്ധങ്ങൾ തിരഞ്ഞെടുക്കുക';

  @override
  String get titleSelectAllowedTags => 'അനുവദിച്ച അടയാളങ്ങൾ തിരഞ്ഞെടുക്കുക';

  @override
  String get emptyNoTagsInContacts =>
      'വിലാസവിവരങ്ങളിൽ അടയാളങ്ങളൊന്നുമില്ല. ആദ്യം വിലാസവിവരങ്ങളിൽ അടയാളങ്ങൾ ഉണ്ടാക്കുക.';

  @override
  String get titleSelectAllowedContacts =>
      'അനുവദിച്ച വിലാസവിവരങ്ങൾ തിരഞ്ഞെടുക്കുക';

  @override
  String get hintQuietStartTime =>
      'നിശ്ശബ്ദ സമയം തുടങ്ങുന്ന സമയം തിരഞ്ഞെടുക്കുക';

  @override
  String get hintQuietEndTime =>
      'നിശ്ശബ്ദ സമയം അവസാനിക്കുന്ന സമയം തിരഞ്ഞെടുക്കുക';

  @override
  String get titleNewQuickReply => 'പുതിയ ദ്രുത മറുപടി';

  @override
  String get titleEditQuickReply => 'ദ്രുത മറുപടി തിരുത്തുക';

  @override
  String get hintQuickReplyExample =>
      'ഉദാ. ഇപ്പോൾ സംസാരിക്കാനാവില്ല. പിന്നീട് വിളിക്കാം.';

  @override
  String get titleResetQuickReplies => 'ദ്രുത മറുപടികൾ പുനഃസജ്ജമാക്കണോ?';

  @override
  String get descResetQuickReplies =>
      'നിങ്ങളുടെ സ്വന്തം സന്ദേശങ്ങൾക്ക് പകരം സ്ഥിര സന്ദേശങ്ങൾ വരും.';

  @override
  String get actionReset => 'പുനഃസജ്ജമാക്കുക';

  @override
  String get tooltipResetToDefaults => 'സ്ഥിരമായവയിലേക്ക് മാറ്റുക';

  @override
  String get descQuickRepliesInfo =>
      'വരുന്ന ഫോൺ വിളി സന്ദേശത്തോടെ നിരസിക്കുമ്പോൾ ദ്രുത മറുപടികൾ കാണിക്കും. വിളി വന്ന SIM-ൽ നിന്ന് വിളിച്ചയാൾക്ക് SMS ആയി മറുപടി അയയ്ക്കും.';

  @override
  String get actionAddReply => 'ഒരു മറുപടി ചേർക്കുക';

  @override
  String get descAddReply => 'ഫോൺ വിളി നിരസിക്കുമ്പോൾ നൽകാനുള്ള സന്ദേശം എഴുതുക';

  @override
  String get emptyNoQuickReplies =>
      'ഇതുവരെ ദ്രുത മറുപടികളില്ല. ഒന്ന് ചേർക്കുക, അല്ലെങ്കിൽ മുകളിൽ വലതുവശത്തുനിന്ന് സ്ഥിരമായവയിലേക്ക് മാറ്റുക.';

  @override
  String labelRepliesCount(int count) {
    return 'മറുപടികൾ ($count)';
  }

  @override
  String get labelCatImmediateFamily => 'അടുത്ത കുടുംബം';

  @override
  String get labelCatExtendedFamily => 'വിപുല കുടുംബം';

  @override
  String get labelCatFamilyByMarriage => 'വിവാഹബന്ധുക്കൾ';

  @override
  String get labelCatProfessional => 'തൊഴിൽപരം';

  @override
  String get labelCatEducational => 'വിദ്യാഭ്യാസപരം';

  @override
  String get labelCatSocial => 'സാമൂഹികം';

  @override
  String get labelCatService => 'സേവനം';

  @override
  String get titleNewRelationship => 'പുതിയ ബന്ധം';

  @override
  String get titleEditRelationship => 'ബന്ധം തിരുത്തുക';

  @override
  String get labelRelationshipName => 'ബന്ധത്തിന്റെ പേര്';

  @override
  String get errorRelationshipExists => 'ആ ബന്ധം നിലവിലുണ്ട്';

  @override
  String get titleResetRelationshipNames =>
      'ബന്ധങ്ങളുടെ പേരുകൾ പുനഃസജ്ജമാക്കണോ?';

  @override
  String get descResetRelationshipNames =>
      'നിങ്ങളുടെ സ്വന്തം പട്ടികയ്ക്ക് പകരം ആപ്പിലെ സ്ഥിര ബന്ധപ്പേരുകൾ വരും.';

  @override
  String get titleRelationshipNames => 'ബന്ധങ്ങളുടെ പേരുകൾ';

  @override
  String get descRelationshipNamesInfo =>
      'രണ്ട് വിലാസവിവരങ്ങൾ ബന്ധിപ്പിക്കുമ്പോൾ ഈ പേരുകൾ അവ ഉൾപ്പെടുന്ന ഏഴ് വിഭാഗങ്ങളിലൊന്നിന് കീഴിൽ ചിപ്പുകളായി കാണിക്കും. ഇഷ്ടമുള്ള ഏത് പേരും ടൈപ്പ് ചെയ്യാം. ഇവിടെ തിരുത്തുന്നത് സൂക്ഷിച്ച ബന്ധങ്ങളെ മാറ്റില്ല.';

  @override
  String get actionAddRelationshipName => 'ഒരു ബന്ധം ചേർക്കുക';

  @override
  String get descAddRelationshipName =>
      'വിലാസവിവരങ്ങൾ ബന്ധിപ്പിക്കുമ്പോൾ നൽകാനുള്ള പേര് ചേർക്കുക';

  @override
  String get emptyNoRelationshipNames =>
      'ഇതുവരെ ബന്ധപ്പേരുകളില്ല. ഒന്ന് ചേർക്കുക, അല്ലെങ്കിൽ മുകളിൽ വലതുവശത്തുനിന്ന് സ്ഥിരമായവയിലേക്ക് മാറ്റുക.';

  @override
  String labelRelationshipsCount(int count) {
    return 'ബന്ധങ്ങൾ ($count)';
  }

  @override
  String get labelContactCounts => 'വിലാസവിവരങ്ങളുടെ എണ്ണം';

  @override
  String get descGrantContactsToCount =>
      'ഉപകരണത്തിലെ വിലാസവിവരങ്ങൾ എണ്ണാൻ വിലാസവിവര അനുമതി നൽകുക';

  @override
  String descDeviceAppCounts(String device, String app) {
    return 'ഉപകരണം: $device  ·  ആപ്പ്: $app';
  }

  @override
  String get labelSearchIndex => 'തിരയൽ സൂചിക';

  @override
  String get msgCheckingSearchIndex => 'തിരയൽ സൂചിക പരിശോധിക്കുന്നു...';

  @override
  String get descIndexHealthy =>
      'സൂചിക ശരിയാണ് — എല്ലാ വിലാസവിവരങ്ങളും കണ്ടെത്താം';

  @override
  String descIndexStale(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count വിലാസവിവരങ്ങൾക്ക് പഴകിയ തിരയൽ കീകൾ ഉണ്ട്',
      one: '1 വിലാസവിവരത്തിന് പഴകിയ തിരയൽ കീകൾ ഉണ്ട്',
    );
    return '$_temp0';
  }

  @override
  String get actionRebuild => 'പുനർനിർമ്മിക്കുക';

  @override
  String get descAuthExportSecret =>
      'രഹസ്യ വിലാസവിവരങ്ങൾ കയറ്റുമതി ചെയ്യാൻ സ്ഥിരീകരിക്കുക';

  @override
  String get errorAuthRequiredExportSecret =>
      'രഹസ്യ വിലാസവിവരങ്ങൾ കയറ്റുമതി ചെയ്യാൻ സ്ഥിരീകരണം ആവശ്യമാണ്';

  @override
  String msgExportedSecretTo(String path) {
    return 'രഹസ്യ വിലാസവിവരങ്ങൾ $path-ലേക്ക് കയറ്റുമതി ചെയ്തു';
  }

  @override
  String errorExportSecretFailed(String error) {
    return 'രഹസ്യ വിലാസവിവരങ്ങൾ കയറ്റുമതി ചെയ്യാനായില്ല: $error';
  }

  @override
  String get titleSecretContactsExport => 'രഹസ്യ വിലാസവിവരങ്ങളും കയറ്റുമതിയും';

  @override
  String get labelIncludeSecretInExport => 'രഹസ്യ വിലാസവിവരങ്ങളും ചേർക്കുക';

  @override
  String get descIncludeSecretInExport =>
      'ഓഫാണെങ്കിൽ സാധാരണ VCF കയറ്റുമതിയിൽ രഹസ്യമായി അടയാളപ്പെടുത്തിയ വിലാസവിവരങ്ങൾ ഒഴിവാക്കും';

  @override
  String get labelExportSecretContacts =>
      'രഹസ്യ വിലാസവിവരങ്ങൾ കയറ്റുമതി ചെയ്യുക';

  @override
  String get descExportSecretContacts =>
      'രഹസ്യ വിലാസവിവരങ്ങൾ മാത്രമുള്ള വേറൊരു VCF ഫയൽ സൂക്ഷിക്കുക (സ്ഥിരീകരണത്തോടെ)';

  @override
  String get titleSpokenAnnouncement => 'വിളിക്കുന്നയാളുടെ പേര് പറയൽ';

  @override
  String get descSpokenAnnouncementSwitch =>
      'റിംഗ്‌ടോണിനൊപ്പം വിളിക്കുന്നയാളുടെ പേര് പറയുക (\"Amma calling\" / \"അമ്മ വിളിക്കുന്നു\")';

  @override
  String get descSuppressDuringQuiet => 'നിശ്ശബ്ദ സമയത്ത് പേര് പറയൽ ഒഴിവാക്കുക';

  @override
  String get labelTestAnnouncement => 'പേര് പറയൽ പരീക്ഷിക്കുക';

  @override
  String get descTestAnnouncement =>
      'ഇംഗ്ലീഷ് അല്ലെങ്കിൽ മലയാളം ശബ്ദത്തിൽ കേട്ടുനോക്കുക';

  @override
  String get hintQuietStartTimeGeneric =>
      'നിശ്ശബ്ദ സമയം തുടങ്ങുന്ന സമയം തിരഞ്ഞെടുക്കുക';

  @override
  String get hintQuietEndTimeGeneric =>
      'നിശ്ശബ്ദ സമയം അവസാനിക്കുന്ന സമയം തിരഞ്ഞെടുക്കുക';

  @override
  String get descEnterCallerNameToTest =>
      'പരീക്ഷിക്കാൻ വിളിക്കുന്നയാളുടെ പേര് നൽകുക:';

  @override
  String get hintCallerNameExample => 'ഉദാ. Amma അല്ലെങ്കിൽ അമ്മ';

  @override
  String get actionPlayTest => 'കേട്ടുനോക്കുക';

  @override
  String get titlePostCallOptions => 'വിളിക്ക് ശേഷമുള്ള ഓപ്ഷനുകൾ';

  @override
  String get labelAskAfterCalls => 'വിളിക്ക് ശേഷം ചോദിക്കുക';

  @override
  String get descAskAfterCalls =>
      'ഫോൺ വിളി കഴിയുമ്പോൾ “എങ്ങനെയുണ്ടായിരുന്നു?” എന്ന ഷീറ്റ് കാണിക്കുക';

  @override
  String get hintRelationshipNameExample => 'ഉദാ. മാർഗ്ഗദർശി';

  @override
  String get helpHomeText1 => 'സഹായവും ഉപയോക്തൃ ഗൈഡുകളും';

  @override
  String get helpHomeHeading1 => 'ഫോൺ വിളിയും ഡയലറും';

  @override
  String get helpHomeTitle1 => 'T9 ഡയലിംഗും മലയാളവും';

  @override
  String get helpHomeSub1 =>
      'പല ലിപികളിലുള്ള T9 തിരയൽ എങ്ങനെ പ്രവർത്തിക്കുന്നു, മലയാളം സ്വരങ്ങൾ (അ മുതൽ അഃ വരെ) എവിടെ നൽകിയിരിക്കുന്നു.';

  @override
  String get helpHomeTitle2 => 'ഫോൺ വിളിയും വിളിക്കിടയിലെ നിയന്ത്രണങ്ങളും';

  @override
  String get helpHomeSub2 =>
      'കോൺഫറൻസ് ലയനം, ഹോൾഡ്, മാറ്റൽ, ഇരട്ട SIM ഓപ്ഷനുകൾ, സ്മാർട്ട് റീഡയൽ, വിളിക്കുന്നയാളുടെ പേര് പറയൽ.';

  @override
  String get helpHomeTitle3 => 'വിളി പരിശോധനയും തടയലും';

  @override
  String get helpHomeSub3 =>
      'റിംഗ് ചെയ്യുംമുമ്പ് ഒരു നമ്പർ തടയൽ, അജ്ഞാതരെ തടയൽ, സ്ഥിര ഡയലർ ചുമതല എന്തിന് വേണം.';

  @override
  String get helpHomeTitle4 => 'കോളർ ID-യും സ്പാം അരിപ്പയും';

  @override
  String get helpHomeSub4 =>
      'അജ്ഞാത വിളിക്കാരെ അടയാളപ്പെടുത്തൽ, സംശയമുള്ള സ്പാം നിശ്ശബ്ദമായി റിംഗ് ചെയ്യിക്കൽ, ഒരു നമ്പർ സ്പാം ആയി അടയാളപ്പെടുത്തൽ.';

  @override
  String get helpHomeTitle5 => 'വിളിയുടെ പശ്ചാത്തലവും കുറിപ്പുകളും';

  @override
  String get helpHomeSub5 =>
      'വിളിക്ക് മുമ്പുള്ള സംഗ്രഹം, \"ഇപ്പോൾ എടുക്കാൻ സാധ്യത\", വിളിക്ക് ശേഷം നിങ്ങൾ എഴുതുന്ന കുറിപ്പുകൾ.';

  @override
  String get helpHomeHeading2 => 'ക്രമീകരണവും പങ്കിടലും';

  @override
  String get helpHomeTitle6 => 'ബന്ധ വലയങ്ങൾ';

  @override
  String get helpHomeSub6 =>
      'അടുത്ത കുടുംബം മുതൽ സേവനം വരെയുള്ള 7 വിഭാഗങ്ങൾ, നിങ്ങളുടെ സ്വന്തം പേരുകൾ, നിശ്ശബ്ദ സമയം.';

  @override
  String get helpHomeTitle7 => 'ഗ്രൂപ്പുകളും അടയാളങ്ങളും';

  @override
  String get helpHomeSub7 =>
      'ഗ്രൂപ്പുകൾ ഉണ്ടാക്കൽ, ഗ്രൂപ്പ് റിംഗ്‌ടോണുകൾ, അടയാള മേഘം, ഒന്നിലധികം വിലാസവിവരങ്ങൾ ഒരുമിച്ച് തിരഞ്ഞെടുക്കൽ.';

  @override
  String get helpHomeTitle8 => 'ഇരട്ട വിലാസവിവരങ്ങളും ലയനവും';

  @override
  String get helpHomeSub8 =>
      'ഒരേ പേരുകളും ഫോണുകളും ഇമെയിലുകളും എങ്ങനെ കണ്ടെത്തി വിവരനഷ്ടമില്ലാതെ ലയിപ്പിക്കുന്നു.';

  @override
  String get helpHomeTitle9 => 'പങ്കിടലും കാർഡ് സ്കാനിംഗും';

  @override
  String get helpHomeSub9 =>
      'QR വിലാസവിവര കോഡുകൾ, ഉപകരണത്തിലെ ബിസിനസ് കാർഡ് സ്കാനർ, ബ്ലൂടൂത്ത് വഴി പങ്കിടൽ.';

  @override
  String get helpHomeTitle10 => 'ഫയൽ ഇറക്കുമതിയും കയറ്റുമതിയും';

  @override
  String get helpHomeSub10 =>
      'CSV, vCard ഫയലുകൾ അകത്തേക്കും പുറത്തേക്കും, ഒരു QR കോഡിൽ ഒതുങ്ങാത്തത് അയയ്ക്കാൻ AirQR.';

  @override
  String get helpHomeHeading3 => 'സ്വകാര്യതയും സംരക്ഷണവും';

  @override
  String get helpHomeTitle11 => 'സ്വകാര്യത, സുരക്ഷ, രഹസ്യ അറ';

  @override
  String get helpHomeSub11 =>
      'രഹസ്യ വിലാസവിവര അറ, ബയോമെട്രിക്/PIN സംരക്ഷണം, സ്ക്രീൻഷോട്ട് സംരക്ഷണം, സുരക്ഷാ മാറ്റങ്ങളുടെ രേഖ.';

  @override
  String get helpHomeTitle12 => 'ബയോമെട്രിക് പൂട്ടിന്റെ വിശദാംശങ്ങൾ';

  @override
  String get helpHomeSub12 =>
      'ആപ്പ് വിരലടയാളമോ മുഖമോ ചോദിക്കുന്ന എല്ലാ ഇടങ്ങളും, സ്ക്രീൻ പൂട്ടില്ലെങ്കിൽ എന്ത് സംഭവിക്കുന്നു എന്നും.';

  @override
  String get helpHomeTitle13 => 'ആപ്പ് പൂട്ടും PIN-ഉം';

  @override
  String get helpHomeSub13 =>
      'മൂന്ന് പൂട്ട് രീതികൾ, ആപ്പ് PIN സജ്ജമാക്കൽ, മറന്നാൽ വീണ്ടെടുക്കൽ കോഡ്.';

  @override
  String get helpHomeTitle14 => 'അനുമതികൾ വിശദമായി';

  @override
  String get helpHomeSub14 =>
      'ഓരോ അനുമതിയും എന്തിന്, ഏതൊക്കെ നിർബന്ധമല്ല, വേണ്ടെന്ന് പറഞ്ഞാൽ എന്ത് പ്രവർത്തിക്കാതാകും.';

  @override
  String get helpHomeTitle15 => 'അടിയന്തര വിവര കാർഡ്';

  @override
  String get helpHomeSub15 =>
      'ആദ്യം സഹായിക്കാനെത്തുന്നവർക്കായി ലോക്ക് സ്ക്രീനിൽ ആരോഗ്യ വിവരങ്ങളും അടിയന്തര വിലാസവിവരങ്ങളും സജ്ജമാക്കൽ.';

  @override
  String get helpHomeHeading4 => 'സമന്വയവും കരുതൽശേഖരവും';

  @override
  String get helpHomeTitle16 => 'പ്രാദേശിക Wi-Fi P2P ഉപകരണ സമന്വയം';

  @override
  String get helpHomeSub16 =>
      'പൂർണ്ണ എൻക്രിപ്ഷനോടെ, ക്ലൗഡ് ഇല്ലാതെ, ഉപകരണത്തിൽ നിന്ന് ഉപകരണത്തിലേക്ക് നേരിട്ടുള്ള Wi-Fi കൈമാറ്റം എങ്ങനെ.';

  @override
  String get helpHomeTitle17 => 'ഫോൺബുക്കും വിളി രേഖയും സമന്വയിപ്പിക്കൽ';

  @override
  String get helpHomeSub17 =>
      'വിലാസവിവരങ്ങളും വിളി ചരിത്രവും Android സിസ്റ്റം സംഭരണവുമായി ലയിപ്പിക്കൽ അല്ലെങ്കിൽ ഒരുപോലെയാക്കൽ.';

  @override
  String get helpHomeTitle18 => 'ക്ലൗഡ് സമന്വയവും Google Drive-ഉം';

  @override
  String get helpHomeSub18 =>
      'ഇരുവശ ഓൺലൈൻ സമന്വയം, എൻക്രിപ്റ്റ് ചെയ്ത ക്ലൗഡ് കരുതൽശേഖരം, WebDAV സജ്ജീകരണം, രഹസ്യ അറയുടെ സ്വകാര്യത.';

  @override
  String get helpHomeTitle19 => 'ഓഫ്‌ലൈൻ കരുതൽശേഖരവും പുനഃസ്ഥാപനവും';

  @override
  String get helpHomeSub19 =>
      'എൻക്രിപ്റ്റ് ചെയ്ത കരുതൽശേഖര ഫയലുകൾ കയറ്റുമതി ചെയ്യൽ, പാസ്‌വേഡ് സുരക്ഷ, പുതിയ ഫോണിൽ പുനഃസ്ഥാപിക്കൽ.';

  @override
  String get helpHomeHeading5 => 'വ്യക്തിഗതമാക്കലും ഉപകരണങ്ങളും';

  @override
  String get helpHomeTitle20 => 'രൂപം, ശബ്ദം, പ്രദേശം';

  @override
  String get helpHomeSub20 =>
      'തീമും ആക്സന്റ് നിറവും, അക്ഷരരൂപവും വലുപ്പവും, റിംഗ്‌ടോണും കമ്പനവും, സ്ഥിര രാജ്യം.';

  @override
  String get helpHomeTitle21 => 'വിലാസവിവര ഉപകരണങ്ങൾ';

  @override
  String get helpHomeSub21 =>
      'താനേ ഇല്ലാതാകുന്ന താൽക്കാലിക വിലാസവിവരങ്ങൾ, ബന്ധിപ്പിച്ച സന്ദേശ ആപ്പുകൾ, തിരയൽ സൂചിക.';

  @override
  String get helpHomeHeading6 => 'പതിവ് ചോദ്യങ്ങൾ';

  @override
  String get helpHomeTitle22 => 'പതിവ് ചോദ്യങ്ങളും പ്രശ്നപരിഹാരവും';

  @override
  String get helpHomeSub22 =>
      'പ്രധാന ചോദ്യങ്ങൾക്ക് നേരിട്ടുള്ള ഉത്തരങ്ങൾ: അനുമതികൾ, സ്ഥിര ഡയലർ, നിശ്ശബ്ദ സമയം, തിരയൽ സൂചിക.';

  @override
  String get helpHomeText2 => 'സഹായ കേന്ദ്രവും വിജ്ഞാനശേഖരവും';

  @override
  String get helpHomeText3 =>
      'SreerajP Contacts Sphere-ന്റെ എല്ലാ സവിശേഷതകൾക്കുമുള്ള വിശദമായ ഗൈഡുകളും പരിഹാരങ്ങളും കാണുക.';

  @override
  String get helpGroupsTagsTitle1 => 'ഗ്രൂപ്പുകളും അടയാളങ്ങളും';

  @override
  String get helpGroupsTagsIntro =>
      'ഒരേ വിലാസപ്പുസ്തകം ക്രമീകരിക്കാനുള്ള രണ്ട് വ്യത്യസ്ത വഴികളാണ് ഗ്രൂപ്പുകളും അടയാളങ്ങളും. ഒരു വിലാസവിവരം നിങ്ങൾ കൈകൊണ്ട് ഉണ്ടാക്കുന്ന ഗ്രൂപ്പുകളിൽ ഉൾപ്പെടുന്നു, ചെറിയ പേരുകളായി നിങ്ങൾ ടൈപ്പ് ചെയ്യുന്ന അടയാളങ്ങൾ വഹിക്കുന്നു. രണ്ടും നിങ്ങളുടേതാണ് — ആപ്പ് സ്വയം ഒന്നും ഉണ്ടാക്കുന്നില്ല.';

  @override
  String get helpGroupsTagsTitle2 => 'ഗ്രൂപ്പുകൾ';

  @override
  String get helpGroupsTagsBullet1 =>
      'എല്ലാ ഗ്രൂപ്പുകളും കാണാൻ വിലാസവിവരങ്ങൾ ടാബ് തുറന്ന് മുകളിലെ ബാറിലെ ഗ്രൂപ്പ് ചിഹ്നം തൊടുക.';

  @override
  String get helpGroupsTagsBullet2 =>
      'ഒരു ഗ്രൂപ്പ് ഉണ്ടാക്കി പേര് നൽകി അംഗങ്ങളെ ചേർക്കുക. ഒരു വിലാസവിവരം ഒന്നിലധികം ഗ്രൂപ്പുകളിൽ ആകാം.';

  @override
  String get helpGroupsTagsBullet3 =>
      'ഒരു ഗ്രൂപ്പിന് സ്വന്തം റിംഗ്‌ടോൺ ആകാം. ഫോണിലെ റിംഗ്‌ടോണുകളിൽ നിന്നോ ഫോൾഡറുകളിലെ ഒരു ഓഡിയോ ഫയലിൽ നിന്നോ തിരഞ്ഞെടുക്കുക.';

  @override
  String get helpGroupsTagsBullet4 =>
      'സ്വന്തം റിംഗ്‌ടോൺ ഇല്ലാത്ത അംഗങ്ങൾക്കാണ് ഗ്രൂപ്പ് റിംഗ്‌ടോൺ. വിലാസവിവരത്തിലെ റിംഗ്‌ടോണിനാണ് എപ്പോഴും മുൻഗണന.';

  @override
  String get helpGroupsTagsTitle3 => 'അടയാളങ്ങൾ';

  @override
  String get helpGroupsTagsBullet5 =>
      'തിരുത്തുമ്പോൾ ഒരു വിലാസവിവരത്തിൽ ചേർക്കുന്ന ചെറിയ വാക്കാണ് അടയാളം — \"പ്ലംബർ\", \"സ്കൂൾ\", \"ട്രെക്ക് സംഘം\". നിശ്ചിത പട്ടികയില്ല; യോജിക്കുന്നത് ടൈപ്പ് ചെയ്യുക.';

  @override
  String get helpGroupsTagsBullet6 =>
      'ആപ്പിന്റെ താഴെയുള്ള അടയാളങ്ങൾ ടാബ് ഉപയോഗത്തിലുള്ള എല്ലാ അടയാളങ്ങളും ഒരു മേഘമായി കാണിക്കുന്നു. കൂടുതൽ വിലാസവിവരങ്ങളിലുള്ള അടയാളം വലുതായി കാണും.';

  @override
  String get helpGroupsTagsBullet7 =>
      'ഒരു അടയാളം തൊട്ടാൽ അത് വഹിക്കുന്ന എല്ലാവരെയും കാണാം. അവിടെ നിന്ന് ആരെയും വിളിക്കാം, സന്ദേശം അയയ്ക്കാം, തുറക്കാം.';

  @override
  String get helpGroupsTagsBullet8 =>
      'നിശ്ശബ്ദ സമയത്തിനുള്ള ഒഴിവു പട്ടികയായും അടയാളങ്ങൾ പ്രവർത്തിക്കുന്നു, അതിനാൽ ഒരു അടയാളമുള്ള എല്ലാവർക്കും റിംഗ് ചെയ്യാൻ അനുവദിക്കാം.';

  @override
  String get helpGroupsTagsTitle4 => 'ഒരേസമയം പല വിലാസവിവരങ്ങളിൽ പ്രവർത്തിക്കൽ';

  @override
  String get helpGroupsTagsBullet9 =>
      'തിരഞ്ഞെടുക്കാൻ തുടങ്ങാൻ പട്ടികയിലെ ഒരു വിലാസവിവരം അമർത്തിപ്പിടിക്കുക. കൂടുതൽ ചേർക്കാൻ മറ്റുള്ളവ തൊടുക.';

  @override
  String get helpGroupsTagsBullet10 =>
      'അപ്പോൾ മുകളിലെ ബാറിൽ \"എല്ലാം തിരഞ്ഞെടുക്കുക\", \"തിരഞ്ഞെടുത്തവ ഇല്ലാതാക്കുക\" എന്നിവ വരും, ഒറ്റയടിക്ക് പല വിലാസവിവരങ്ങളും നീക്കാം.';

  @override
  String get helpGroupsTagsBullet11 =>
      'ഒന്നും മാറ്റാതെ തിരഞ്ഞെടുപ്പ് രീതിയിൽ നിന്ന് പുറത്തുവരാൻ മുകളിലെ ബാറിലെ ക്രോസ് തൊടുക.';

  @override
  String get helpGroupsTagsFooter =>
      'നുറുങ്ങ്: കൂട്ടം സ്ഥിരമാണെങ്കിലും അതിന് ഒരു റിംഗ്‌ടോൺ വേണമെങ്കിലും ഗ്രൂപ്പ് ഉപയോഗിക്കുക. പിന്നീട് അവരെ വീണ്ടും കണ്ടെത്താൻ മാത്രമാണെങ്കിൽ അടയാളം ഉപയോഗിക്കുക.';

  @override
  String get helpAppLockTitle1 => 'ആപ്പ് പൂട്ടും PIN-ഉം';

  @override
  String get helpAppLockIntro =>
      'ആപ്പ് തുറക്കുമ്പോൾ മുഴുവൻ ആപ്പിനും മുന്നിൽ ആപ്പ് പൂട്ട് ഒരു സ്ക്രീൻ വയ്ക്കുന്നു. എങ്ങനെ തുറക്കണമെന്ന് ക്രമീകരണങ്ങൾ → സുരക്ഷ → ആപ്പ് പൂട്ട് എന്നതിൽ തിരഞ്ഞെടുക്കാം. മൂന്ന് വഴികളുണ്ട്.';

  @override
  String get helpAppLockTitle2 => 'മൂന്ന് രീതികൾ';

  @override
  String get helpAppLockBullet1 =>
      'ഓഫ് — ആപ്പ് ഉടനെ തുറക്കും. രഹസ്യ വിലാസവിവരങ്ങൾ അപ്പോഴും വേറെ തുറക്കൽ ചോദിക്കും.';

  @override
  String get helpAppLockBullet2 =>
      'ഉപകരണ പൂട്ട് — ഫോണിന്റെ സ്വന്തം വിരലടയാളം, മുഖം, അല്ലെങ്കിൽ സ്ക്രീൻ പൂട്ട് PIN ഉപയോഗിക്കുന്നു. Android ക്രമീകരണങ്ങളിൽ സ്ക്രീൻ പൂട്ട് സജ്ജമാക്കുന്നതുവരെ ഇത് ലഭ്യമല്ല.';

  @override
  String get helpAppLockBullet3 =>
      'ആപ്പ് PIN — ഈ ആപ്പിന് മാത്രമായി വേറൊരു PIN, ആപ്പിനുള്ളിലെ കീപാഡിൽ ടൈപ്പ് ചെയ്യുന്നത്. നിങ്ങളുടെ ഫോൺ PIN മറ്റുള്ളവർക്ക് അറിയാമെങ്കിൽ ഉപകാരപ്പെടും.';

  @override
  String get helpAppLockTitle3 => 'ആപ്പ് PIN സജ്ജമാക്കൽ';

  @override
  String get helpAppLockBullet4 =>
      '4 മുതൽ 6 അക്കമുള്ള ഒരു PIN തിരഞ്ഞെടുത്ത് സ്ഥിരീകരിക്കുക.';

  @override
  String get helpAppLockBullet5 =>
      'തുടർന്ന് ഒറ്റത്തവണ വീണ്ടെടുക്കൽ കോഡ് കാണിക്കും. അത് എഴുതിവയ്ക്കുക അല്ലെങ്കിൽ സുരക്ഷിതമായ ഇടത്ത് പകർത്തുക — ഒരിക്കൽ മാത്രമേ കാണിക്കൂ, പിന്നീട് ഒരിക്കലുമില്ല.';

  @override
  String get helpAppLockBullet6 =>
      'നിങ്ങൾ ടൈപ്പ് ചെയ്തതുപോലെ PIN സൂക്ഷിക്കുന്നില്ല, ആർക്കും അത് ആപ്പിൽ നിന്ന് തിരികെ വായിക്കാനാവില്ല.';

  @override
  String get helpAppLockTitle4 => 'ആപ്പ് PIN മറന്നാൽ';

  @override
  String get helpAppLockBullet7 =>
      'ലോക്ക് സ്ക്രീനിൽ \"PIN മറന്നോ?\" തൊട്ട് വീണ്ടെടുക്കൽ കോഡ് നൽകുക.';

  @override
  String get helpAppLockBullet8 =>
      'ശരിയായ കോഡ് ആപ്പ് പൂട്ട് ഓഫാക്കി അകത്തേക്ക് കടത്തിവിടും. പൂട്ട് ഇനിയും വേണമെങ്കിൽ പിന്നീട് പുതിയ PIN സജ്ജമാക്കുക.';

  @override
  String get helpAppLockBullet9 =>
      'വീണ്ടെടുക്കൽ കോഡ് ഇല്ലാതെ പൂട്ട് കടക്കാൻ ഒരു വഴിയുമില്ല. അത് മനഃപൂർവമാണ് — നിങ്ങൾക്കുള്ള പിൻവാതിൽ ആർക്കുമുള്ള പിൻവാതിലാകും.';

  @override
  String get helpAppLockTitle5 => 'വീണ്ടും ചോദിക്കുന്നത് എപ്പോൾ';

  @override
  String get helpAppLockBullet10 =>
      'ആപ്പ് വിട്ടുപോയ ശേഷം തിരികെ വരുമ്പോഴാണ് ലോക്ക് സ്ക്രീൻ വീണ്ടും വരുന്നത്, ആപ്പിനുള്ളിലെ ഓരോ സ്ക്രീനിലുമല്ല.';

  @override
  String get helpAppLockBullet11 =>
      'പിന്നോട്ട് ആംഗ്യം കൊണ്ട് അത് മാറ്റാനാവില്ല. ശരിയായ തുറക്കലോ വീണ്ടെടുക്കൽ കോഡോ മാത്രമേ കടത്തിവിടൂ.';

  @override
  String get helpAppLockFooter =>
      'ആപ്പ് പൂട്ട് വാതിൽ കാക്കുന്നു. രഹസ്യ വിലാസവിവരങ്ങൾക്കും കരുതൽശേഖരത്തിനും സമന്വയത്തിനും അതിനു പുറമേ സ്വന്തം തുറക്കലുണ്ട് — ബയോമെട്രിക് പൂട്ട് ഗൈഡ് കാണുക.';

  @override
  String get helpContactToolsTitle1 => 'വിലാസവിവര ഉപകരണങ്ങൾ';

  @override
  String get helpContactToolsIntro =>
      'ശ്രദ്ധിക്കാതെ പോകാവുന്ന മൂന്ന് ചെറിയ ഉപകരണങ്ങൾ: താനേ ഇല്ലാതാകുന്ന വിലാസവിവരങ്ങൾ, ഒരാളെ ബന്ധപ്പെടാവുന്ന സന്ദേശ ആപ്പുകൾ, ഡയലർ വേഗത്തിൽ ആളുകളെ കണ്ടെത്താൻ സഹായിക്കുന്ന തിരയൽ സൂചിക.';

  @override
  String get helpContactToolsTitle2 => 'ക്ഷണിക (താൽക്കാലിക) വിലാസവിവരങ്ങൾ';

  @override
  String get helpContactToolsBullet1 =>
      'ഒരു വിലാസവിവരം ചേർക്കുമ്പോഴോ തിരുത്തുമ്പോഴോ \"ക്ഷണിക വിലാസവിവരം\" ഓണാക്കുക. പിന്നീട് അത് സ്വയം നീങ്ങിപ്പോകും.';

  @override
  String get helpContactToolsBullet2 =>
      'എത്ര കാലം നിലനിൽക്കണമെന്ന് തിരഞ്ഞെടുക്കുക: 2 മണിക്കൂർ, 24 മണിക്കൂർ, 7 ദിവസം, അല്ലെങ്കിൽ \"1 വിളിക്ക് ശേഷം സ്വയം ഇല്ലാതാക്കുക\".';

  @override
  String get helpContactToolsBullet3 =>
      'ഡെലിവറിക്കാരൻ, ടാക്സി, ഒറ്റത്തവണ വിൽപ്പനക്കാരൻ എന്നിവർക്ക് നല്ലത് — ആവശ്യമുള്ളപ്പോൾ നമ്പർ ഉണ്ട്, പിന്നീട് പോയി.';

  @override
  String get helpContactToolsBullet4 =>
      'വിലാസവിവരം തുറന്നാൽ നീക്കം ചെയ്യുന്നതുവരെയുള്ള സമയം എണ്ണുന്ന ഒരു ബാനർ കാണാം. അവിടെ നിന്ന് 24 മണിക്കൂർ കൂടി ചേർക്കാം, അല്ലെങ്കിൽ എന്നേക്കുമായി സൂക്ഷിക്കാൻ തൊടാം.';

  @override
  String get helpContactToolsBullet5 =>
      'ആപ്പ് ഏകദേശം മിനിറ്റിൽ ഒരിക്കൽ പരിശോധിക്കുന്നു, അതിനാൽ സമയം കഴിഞ്ഞ് അൽപ്പം കഴിഞ്ഞാണ് വിലാസവിവരം പോകുന്നത്, കൃത്യം സെക്കൻഡിലല്ല.';

  @override
  String get helpContactToolsTitle3 => 'ബന്ധിപ്പിച്ച ആപ്പുകൾ';

  @override
  String get helpContactToolsBullet6 =>
      'WhatsApp, Telegram, Arattai പോലുള്ള ഒരു സന്ദേശ ആപ്പ് നിങ്ങളുടെ ഫോണിലെ ഒരു വിലാസവിവരവുമായി സമന്വയിച്ചിട്ടുണ്ടെങ്കിൽ, ആ വിലാസവിവരത്തിൽ ആ ആപ്പുകളുടെ ഒരു നിര കാണാം.';

  @override
  String get helpContactToolsBullet7 =>
      'ആ ആപ്പിൽ നേരിട്ട് ചാറ്റോ വിളിയോ തുറക്കാൻ ഒന്നിൽ തൊടുക. ഈ ആപ്പ് ഒന്നും അയയ്ക്കുന്നില്ല — മറ്റേ ആപ്പ് തുറക്കുക മാത്രം ചെയ്യുന്നു.';

  @override
  String get helpContactToolsBullet8 =>
      'ഈ നിര ഫോണിന്റെ സ്വന്തം വിലാസപ്പുസ്തകത്തിൽ നിന്നാണ് വായിക്കുന്നത്, അതിനാൽ ഉപകരണ വിലാസവിവരവുമായി ബന്ധിപ്പിച്ചവയ്ക്ക് മാത്രം, വിലാസവിവര അനുമതി ഉള്ളപ്പോൾ മാത്രം കാണും.';

  @override
  String get helpContactToolsTitle4 =>
      'വിലാസവിവരങ്ങളുടെ എണ്ണവും തിരയൽ സൂചികയും';

  @override
  String get helpContactToolsBullet9 =>
      'ക്രമീകരണങ്ങൾ → വിലാസവിവരങ്ങൾ → വിലാസവിവരങ്ങളുടെ എണ്ണവും തിരയൽ സൂചികയും എന്നതിൽ ഫോണിലും ആപ്പിലും എത്ര വിലാസവിവരങ്ങളുണ്ടെന്ന് കാണാം — സമന്വയം നടന്നോ എന്ന് അറിയാനുള്ള എളുപ്പവഴി.';

  @override
  String get helpContactToolsBullet10 =>
      'T9 കീപാഡ് തിരയൽ, ലിപ്യന്തരണ തിരയൽ, പേര് തിരയൽ എന്നിവയെ വേഗത്തിലാക്കുന്നത് തിരയൽ സൂചികയാണ്.';

  @override
  String get helpContactToolsBullet11 =>
      'സ്ക്രീൻ ഒന്നുകിൽ \"സൂചിക ശരിയാണ് — എല്ലാ വിലാസവിവരങ്ങളും കണ്ടെത്താം\" എന്നോ എത്ര വിലാസവിവരങ്ങൾക്ക് പഴകിയ തിരയൽ കീകൾ ഉണ്ടെന്നോ പറയും.';

  @override
  String get helpContactToolsBullet12 =>
      'ചിലത് പഴകിയതാണെങ്കിൽ പുനർനിർമ്മിക്കുക ബട്ടൺ വരും. അത് തൊട്ടാൽ മുഴുവൻ വിലാസപ്പുസ്തകത്തിനും കീകൾ വീണ്ടും ഉണ്ടാക്കും.';

  @override
  String get helpContactToolsBullet13 =>
      'സൂക്ഷിച്ചിട്ടുണ്ടെന്ന് അറിയാവുന്ന ഒരു വിലാസവിവരം തിരയലിൽ കിട്ടാതായാലോ പഴയ കരുതൽശേഖരം പുനഃസ്ഥാപിച്ച ശേഷമോ ഇത് പുനർനിർമ്മിക്കുക.';

  @override
  String get helpContactToolsFooter =>
      'നുറുങ്ങ്: സമയം കഴിയുമ്പോൾ ക്ഷണിക വിലാസവിവരം ശരിക്കും ഇല്ലാതാക്കും. നമ്പർ പിന്നീട് വേണ്ടിവന്നേക്കാമെങ്കിൽ, അത് പോകുംമുമ്പ് ബാനറിലെ \"എന്നേക്കുമായി സൂക്ഷിക്കുക\" തൊടുക.';

  @override
  String get helpCallerIntelligenceTitle1 =>
      'വിളിയുടെ പശ്ചാത്തലവും കുറിപ്പുകളും';

  @override
  String get helpCallerIntelligenceIntro =>
      'ഒരാളെ വിളിക്കുംമുമ്പും അവർ വിളിക്കുമ്പോഴും വിളി കഴിഞ്ഞും അവരെക്കുറിച്ച് അൽപ്പം പറയാൻ ആപ്പ് നിങ്ങളുടെ സ്വന്തം വിളി ചരിത്രം വായിക്കുന്നു. ഇതെല്ലാം നിങ്ങളുടെ കൈയിലുള്ള വിവരങ്ങളിൽ നിന്ന് ഈ ഫോണിൽ തന്നെ കണക്കാക്കുന്നു.';

  @override
  String get helpCallerIntelligenceTitle2 => 'വിളിക്കുംമുമ്പ്';

  @override
  String get helpCallerIntelligenceBullet1 =>
      'ഒരു വിലാസവിവരം തുറന്നാൽ ചെറിയ സംഗ്രഹം കാണാം: അവസാനം എപ്പോൾ സംസാരിച്ചു, ആ വിളി എത്ര നേരം നീണ്ടു, അതിനെക്കുറിച്ച് നിങ്ങൾ എന്ത് കുറിച്ചു.';

  @override
  String get helpCallerIntelligenceBullet2 =>
      'വിലാസവിവരത്തിൽ ഒരു നഗരമുള്ള വിലാസമുണ്ടെങ്കിൽ, സംഗ്രഹത്തിൽ അവിടത്തെ പ്രാദേശിക സമയവും കാണിക്കും — മറ്റൊരു രാജ്യത്തുള്ള ഒരാളെ വിളിക്കുംമുമ്പ് ഉപകാരപ്പെടും.';

  @override
  String get helpCallerIntelligenceBullet3 =>
      'ആവശ്യത്തിന് ചരിത്രമുണ്ടെങ്കിൽ, ഈ വ്യക്തി സാധാരണ എടുക്കുന്ന സമയം നിർദ്ദേശിക്കും.';

  @override
  String get helpCallerIntelligenceTitle3 => '\"ഇപ്പോൾ എടുക്കാൻ സാധ്യത\"';

  @override
  String get helpCallerIntelligenceBullet4 =>
      'ഡയലർ കീപാഡിന് മുകളിൽ വിലാസവിവരങ്ങളുടെ ഒരു ചെറിയ നിര കാണിക്കുന്നു. അതിൽ എന്ത് വേണമെന്ന് ക്രമീകരണങ്ങൾ → ഡയലറിലെ മുൻനിര വിലാസവിവരങ്ങൾ എന്നതിൽ തിരഞ്ഞെടുക്കാം: ഏറ്റവും പുതിയവ, കുടുംബവും സുഹൃത്തുക്കളും, അല്ലെങ്കിൽ ഇപ്പോൾ എടുക്കാൻ സാധ്യത.';

  @override
  String get helpCallerIntelligenceBullet5 =>
      '\"ഇപ്പോൾ എടുക്കാൻ സാധ്യത\" ഈ സമയത്ത് സാധാരണ എടുക്കുന്നവരെ ആദ്യം വയ്ക്കുന്നു. ദിവസത്തിലെ ഈ സമയത്തുള്ള വിളികൾ എത്ര തവണ എടുത്തു എന്ന് നിങ്ങളുടെ സ്വന്തം സമീപകാല രേഖയിൽ നിന്ന് കണക്കാക്കുന്നു.';

  @override
  String get helpCallerIntelligenceBullet6 =>
      'ഇത് നിരയുടെ ക്രമം മാത്രമേ മാറ്റുന്നുള്ളൂ. ആപ്പ് ഇവിടെ സ്വയം വിളിക്കുന്നില്ല — ഓരോ വിളിയും നിങ്ങൾ തൊടുന്നതാണ്.';

  @override
  String get helpCallerIntelligenceTitle4 => 'ഫോൺ റിംഗ് ചെയ്യുമ്പോൾ';

  @override
  String get helpCallerIntelligenceBullet7 =>
      'സൂക്ഷിച്ച വിലാസവിവരമാണെങ്കിൽ, വിളി സ്ക്രീനിൽ അവരുമായുള്ള ബന്ധം, അവസാനം സംസാരിച്ചിട്ട് എത്ര നാളായി, വരാനിരിക്കുന്ന ജന്മദിനമോ വാർഷികമോ എന്നിവ കാണിക്കാം.';

  @override
  String get helpCallerIntelligenceBullet8 =>
      'ആ വ്യക്തിക്കായി നിങ്ങൾ വച്ച ബാക്കിയുള്ള ഓർമ്മപ്പെടുത്തലും കാണിക്കും, എന്തിനാണ് സംസാരിക്കാൻ ഉദ്ദേശിച്ചതെന്ന് ഓർമ്മ വരാൻ.';

  @override
  String get helpCallerIntelligenceTitle5 => 'വിളിക്ക് ശേഷം';

  @override
  String get helpCallerIntelligenceBullet9 =>
      'വിളി കഴിയുമ്പോൾ \"എങ്ങനെയുണ്ടായിരുന്നു?\" എന്ന ഷീറ്റ് വരാം. വിളി എങ്ങനെ പോയി എന്ന് കുറിക്കുക, സംസാരിച്ചത് എഴുതുക, തുടർ ഓർമ്മപ്പെടുത്തൽ വയ്ക്കുക.';

  @override
  String get helpCallerIntelligenceBullet10 =>
      'കുറിപ്പ് ടൈപ്പ് ചെയ്യുന്നതിനു പകരം പറഞ്ഞുകൊടുക്കാം — മൈക്രോഫോൺ തൊട്ട് സംസാരിക്കുക. സംസാരം ഫോണിൽ തന്നെ എഴുത്താക്കി മാറ്റുന്നു.';

  @override
  String get helpCallerIntelligenceBullet11 =>
      'നിങ്ങൾ സൂക്ഷിക്കുന്നതെല്ലാം ആ വിലാസവിവരത്തിന്റെ സമയരേഖയിൽ ചേരുന്നു, അടുത്ത വിളിക്ക് മുമ്പുള്ള സംഗ്രഹം വായിക്കുന്നത് അതാണ്.';

  @override
  String get helpCallerIntelligenceBullet12 =>
      'ചോദിക്കേണ്ടെങ്കിൽ, ക്രമീകരണങ്ങൾ → SIM-ഉം ഫോൺ വിളിയും → വിളിക്ക് ശേഷമുള്ള ഓപ്ഷനുകൾ എന്നതിൽ ഷീറ്റ് ഓഫാക്കുക.';

  @override
  String get helpCallerIntelligenceFooter =>
      'സ്വകാര്യത: ഇതൊന്നും ഫോൺ വിട്ടുപോകുന്നില്ല. പിന്നിൽ ഒരു തിരയൽ സേവനവുമില്ല — ആപ്പ് അതിന്റെ എൻക്രിപ്റ്റ് ചെയ്ത ഡാറ്റാബേസിൽ നിന്ന് നിങ്ങളുടെ സ്വന്തം വിലാസവിവരങ്ങളും വിളി രേഖയും കുറിപ്പുകളും മാത്രം വായിക്കുന്നു.';

  @override
  String get helpBiometricsText => 'ബയോമെട്രിക് പൂട്ട്';

  @override
  String get helpBiometricsIntro =>
      'നിങ്ങളുടെ ഏറ്റവും സ്വകാര്യമായ വിവരങ്ങൾ കാണിക്കുംമുമ്പോ നീക്കുംമുമ്പോ SreerajP Contacts Sphere വിരലടയാളമോ മുഖമോ ചോദിക്കാം. ഇത് ഫോണിന്റെ സ്വന്തം പൂട്ട് ഉപയോഗിക്കുന്നു — ആപ്പ് നിങ്ങളുടെ വിരലടയാളമോ മുഖമോ ഒരിക്കലും കാണുകയോ സൂക്ഷിക്കുകയോ ചെയ്യുന്നില്ല.';

  @override
  String get helpBiometricsTitle1 => 'എവിടെയൊക്കെ ചോദിക്കും';

  @override
  String get helpBiometricsBullet1 =>
      'രഹസ്യ വിലാസവിവരങ്ങൾ കാണുമ്പോൾ. തുറക്കുന്നതുവരെ ഇവ സാധാരണ വിലാസവിവര പട്ടികയിൽ നിന്ന് മറഞ്ഞിരിക്കും.';

  @override
  String get helpBiometricsBullet2 =>
      'രഹസ്യ വിലാസവിവരങ്ങൾ കയറ്റുമതി ചെയ്യുമ്പോൾ, നിങ്ങളുടെ സമ്മതമില്ലാതെ ഒരു സ്വകാര്യ വിലാസവിവരം ആപ്പിന് പുറത്തേക്ക് അയയ്ക്കാതിരിക്കാൻ.';

  @override
  String get helpBiometricsBullet3 =>
      '\"മറ്റൊരു ഉപകരണവുമായി സമന്വയം\" തുറക്കുമ്പോൾ, കാരണം സമന്വയത്തിൽ രഹസ്യ വിലാസവിവരങ്ങൾ ഉൾപ്പെടാം.';

  @override
  String get helpBiometricsBullet4 =>
      '\"കരുതൽശേഖരം, പുനഃസ്ഥാപനം\" തുറക്കുമ്പോൾ, കാരണം കരുതൽശേഖരത്തിലും അവ ഉൾപ്പെടാം.';

  @override
  String get helpBiometricsBullet5 =>
      'മാറ്റങ്ങളുടെ രേഖ തുറക്കുമ്പോൾ, അതിൽ വിലാസവിവരങ്ങളുടെ മുമ്പും ശേഷവുമുള്ള പൂർണ്ണ രേഖയുണ്ട്.';

  @override
  String get helpBiometricsBullet6 =>
      'ആരെങ്കിലും ബ്ലൂടൂത്ത് വഴി അയയ്ക്കുന്ന വിലാസവിവരം സ്വീകരിക്കുമ്പോൾ.';

  @override
  String get helpBiometricsBullet7 =>
      'ക്രമീകരണങ്ങൾ → സുരക്ഷ എന്നതിൽ ആപ്പ് പൂട്ട് \"ഉപകരണ പൂട്ട്\" ആക്കിയിട്ടുണ്ടെങ്കിൽ, ആപ്പ് തുറക്കുമ്പോൾ തന്നെ.';

  @override
  String get helpBiometricsTitle2 => '\"നിങ്ങൾ\" ആയി കണക്കാക്കുന്നത് എന്ത്';

  @override
  String get helpBiometricsBullet8 =>
      'ഫോണിൽ നിങ്ങൾ സജ്ജമാക്കിയ ഏത് വിരലടയാളവും മുഖവും സ്വീകരിക്കും.';

  @override
  String get helpBiometricsBullet9 =>
      'വിരലടയാളമോ മുഖമോ സജ്ജമാക്കിയിട്ടില്ലെങ്കിൽ, ഫോൺ നിങ്ങളുടെ സ്ക്രീൻ പൂട്ട് PIN, പാറ്റേൺ, അല്ലെങ്കിൽ പാസ്‌വേഡ് ഉപയോഗിക്കും.';

  @override
  String get helpBiometricsBullet10 =>
      'ആപ്പ് പൂട്ടിന് പകരം ഫോണിന്റെ പൂട്ടിൽ നിന്ന് വേറിട്ട ഒരു ആപ്പ് PIN ഉപയോഗിക്കാം. അത് ആപ്പ് തന്നെ പരിശോധിക്കുന്നു — \"ആപ്പ് പൂട്ടും PIN-ഉം\" ഗൈഡ് കാണുക.';

  @override
  String get helpBiometricsTitle3 => 'നിങ്ങളുടെ സ്വകാര്യത';

  @override
  String get helpBiometricsBullet11 =>
      'പരിശോധന നടത്തുന്നത് Android ആണ്, SreerajP Contacts Sphere അല്ല. തുറക്കൽ വിജയിച്ചോ പരാജയപ്പെട്ടോ എന്ന് മാത്രമേ ആപ്പ് അറിയൂ.';

  @override
  String get helpBiometricsBullet12 =>
      'ഇത് ഓഫ്‌ലൈനായി പ്രവർത്തിക്കുന്നു. നിങ്ങളുടെ വിരലടയാളത്തെയോ മുഖത്തെയോ കുറിച്ച് ഒന്നും ഫോൺ വിട്ടുപോകുന്നില്ല.';

  @override
  String get helpBiometricsFooter =>
      'നുറുങ്ങ്: Android ക്രമീകരണങ്ങളിൽ ഒരു സ്ക്രീൻ പൂട്ട് (വിരലടയാളം, മുഖം, അല്ലെങ്കിൽ PIN) സജ്ജമാക്കുക. പൂട്ടേ ഇല്ലെങ്കിൽ പരിശോധന നടക്കില്ല, അതിനാൽ സമന്വയവും കരുതൽശേഖരവും മുന്നറിയിപ്പ് നൽകി തുടരണോ എന്ന് നിങ്ങളോട് ചോദിക്കും.';

  @override
  String get helpBackupText => 'കരുതൽശേഖരം, പുനഃസ്ഥാപനം';

  @override
  String get helpBackupIntro =>
      'കരുതൽശേഖരം ആപ്പിലുള്ളതെല്ലാം നിങ്ങൾ സൂക്ഷിക്കുന്ന ഒരു ഫയലിലാക്കുന്നു. പുതിയ ഫോണിലേക്ക് മാറാനോ റീസെറ്റിന് ശേഷം തിരികെ കിട്ടാനോ ഇത് ഉപയോഗിക്കാം — പുതിയ ആപ്പ് മറ്റൊരു ഉറവിടത്തിൽ നിന്ന് സ്ഥാപിച്ചതാണെങ്കിൽ പോലും.';

  @override
  String get helpBackupTitle1 => 'കരുതൽശേഖരത്തിൽ എന്തുണ്ട്';

  @override
  String get helpBackupBullet1 =>
      'എല്ലാ വിലാസവിവരങ്ങളും അവയുടെ വിശദാംശങ്ങളും, വിളി ചരിത്രം, ഗ്രൂപ്പുകൾ, ബന്ധങ്ങൾ, തടഞ്ഞ / സ്പാം നമ്പറുകൾ.';

  @override
  String get helpBackupBullet2 =>
      'വിലാസവിവര ഫോട്ടോകളും കോളിംഗ് കാർഡ് ചിത്രങ്ങളും ഫയലിനുള്ളിൽ ഉൾപ്പെടുന്നു.';

  @override
  String get helpBackupBullet3 =>
      'തീം, ആക്സന്റ് നിറം പോലുള്ള നിങ്ങളുടെ ആപ്പ് ക്രമീകരണങ്ങൾ.';

  @override
  String get helpBackupBullet4 =>
      'അടിയന്തര വിലാസവിവരങ്ങളും \"ലോക്ക് സ്ക്രീനിൽ കാണിക്കുക\" സ്വിച്ചുകളും ഉൾപ്പെടെ നിങ്ങളുടെ അടിയന്തര വിവര കാർഡ്.';

  @override
  String get helpBackupBullet5 =>
      'സ്വന്തം റിംഗ്‌ടോണുകൾ ഉൾപ്പെടുന്നില്ല — അവ ഈ ഫോണിലെ ഫയലുകളെയാണ് സൂചിപ്പിക്കുന്നത്, മറ്റെവിടെയും അവ ഉണ്ടാകില്ല.';

  @override
  String get helpBackupTitle2 => 'നിങ്ങളുടെ പാസ്‌വേഡാണ് താക്കോൽ';

  @override
  String get helpBackupBullet6 =>
      'നിങ്ങൾ തിരഞ്ഞെടുക്കുന്ന പാസ്‌വേഡ് കൊണ്ട് കരുതൽശേഖര ഫയൽ പൂട്ടുന്നു. ആപ്പ് അത് എവിടെയും സൂക്ഷിക്കുന്നില്ല.';

  @override
  String get helpBackupBullet7 =>
      'പുനഃസ്ഥാപിക്കാൻ ഇതേ പാസ്‌വേഡ് വേണം — ഈ ഫോണിലായാലും മറ്റേതിലായാലും. അത് സുരക്ഷിതമായി സൂക്ഷിക്കുക.';

  @override
  String get helpBackupBullet8 =>
      'പാസ്‌വേഡ് നഷ്ടപ്പെട്ടാൽ ഫയൽ തുറക്കാനാവില്ല. വീണ്ടെടുക്കാൻ ഒരു വഴിയുമില്ല — അതാണ് നിങ്ങളുടെ വിവരങ്ങൾ സ്വകാര്യമായി സൂക്ഷിക്കുന്നത്.';

  @override
  String get helpBackupTitle3 => 'പുനഃസ്ഥാപനം എല്ലാം മാറ്റിസ്ഥാപിക്കുന്നു';

  @override
  String get helpBackupBullet9 =>
      'പുനഃസ്ഥാപനം ഇപ്പോൾ ആപ്പിലുള്ളത് ഇല്ലാതാക്കി കരുതൽശേഖരത്തിന്റെ കൃത്യമായ പകർപ്പായി വീണ്ടും നിർമ്മിക്കുന്നു.';

  @override
  String get helpBackupBullet10 =>
      'ഇത് ലയനമല്ല. വിവരങ്ങൾ നഷ്ടപ്പെടാതെ രണ്ട് ഫോണുകൾ ഒന്നിപ്പിക്കണമെങ്കിൽ പകരം \"മറ്റൊരു ഉപകരണവുമായി സമന്വയം\" ഉപയോഗിക്കുക.';

  @override
  String get helpBackupBullet11 =>
      'അതേ ആപ്പ് പതിപ്പിൽ ഉണ്ടാക്കിയ കരുതൽശേഖരം പുനഃസ്ഥാപിക്കുക. വളരെ വ്യത്യസ്തമായ പതിപ്പിലേത് നിരസിച്ചേക്കാം.';

  @override
  String get helpBackupFooter =>
      'നുറുങ്ങ്: കരുതൽശേഖരം ഉണ്ടാക്കിയ ശേഷം ആപ്പ് പങ്കിടൽ ഷീറ്റ് തുറക്കും, ഫയൽ Files-ലോ Drive-ലോ സൂക്ഷിക്കാം, അല്ലെങ്കിൽ നിങ്ങൾക്കുതന്നെ അയയ്ക്കാം. ഈ ഫോണല്ലാത്ത മറ്റൊരിടത്ത് സൂക്ഷിക്കുക.';

  @override
  String get helpT9DialingText => 'T9 ഡയലിംഗും മലയാളവും';

  @override
  String get helpT9DialingIntro =>
      'SreerajP Contacts Sphere-ൽ പല ലിപികൾ അറിയുന്ന ഒരു T9 ഡയൽപാഡുണ്ട്. ഇംഗ്ലീഷ് അല്ലെങ്കിൽ പ്രാദേശിക ലിപി (മലയാളം, ദേവനാഗരി മുതലായവ) കീ അമർത്തലുകൾ കൊണ്ട് വിലാസവിവരങ്ങൾ എളുപ്പത്തിൽ തിരയാം.';

  @override
  String get helpT9DialingTitle1 => 'മലയാളം സ്വരങ്ങളുടെ സ്ഥാനം (അ മുതൽ അഃ വരെ)';

  @override
  String get helpT9DialingBullet1 =>
      'കീ 2 (ക-ങ): സ്വരങ്ങൾ അ, ആ + ചിഹ്നങ്ങൾ ാ, ി, ീ';

  @override
  String get helpT9DialingBullet2 =>
      'കീ 3 (ച-ഞ): സ്വരങ്ങൾ ഉ, ഊ, ഋ + ചിഹ്നങ്ങൾ ു, ൂ, ൃ';

  @override
  String get helpT9DialingBullet3 =>
      'കീ 4 (ട-ണ): സ്വരങ്ങൾ എ, ഏ, ഐ + ചിഹ്നങ്ങൾ െ, േ, ൈ';

  @override
  String get helpT9DialingBullet4 =>
      'കീ 5 (ത-ന): സ്വരങ്ങൾ ഒ, ഓ, ഔ + ചിഹ്നങ്ങൾ ൊ, ോ, ൌ, ൗ';

  @override
  String get helpT9DialingBullet5 =>
      'കീ 9 (ള-റ): അനുസ്വാരവും വിസർഗവും (ം, ഃ) + ചില്ലക്ഷരങ്ങൾ (ൺ, ൻ, ർ, ൽ, ൾ, ൿ)';

  @override
  String get helpT9DialingTitle2 =>
      'സ്വരങ്ങൾ കീകളിൽ അച്ചടിക്കാത്തത് എന്തുകൊണ്ട്';

  @override
  String get helpT9DialingBullet6 =>
      'ഡയൽപാഡ് വൃത്തിയായും വായിക്കാൻ എളുപ്പമായും ഇരിക്കാൻ കീകളിൽ വ്യഞ്ജന ഗണങ്ങൾ (ഉദാ. ക-ങ, ച-ഞ) മാത്രം കാണിക്കുന്നു.';

  @override
  String get helpT9DialingBullet7 =>
      'ബട്ടണിൽ അച്ചടിച്ചിട്ടില്ലെങ്കിലും എല്ലാ സ്വരങ്ങളും (അ-ഔ), ചിഹ്നങ്ങളും, ചില്ലക്ഷരങ്ങളും T9 തിരയലിൽ പൂർണ്ണമായി ഉൾപ്പെടുത്തി പ്രവർത്തിക്കുന്നു.';

  @override
  String get helpT9DialingTitle3 => 'മംഗ്ലീഷും ലിപ്യന്തരണ തിരയലും';

  @override
  String get helpT9DialingBullet8 =>
      'ഇംഗ്ലീഷ് T9 കീ അമർത്തലുകൾ മലയാളം പേരുകളുമായി സ്വയം ഒത്തുനോക്കും. ഉദാഹരണത്തിന്, 2-6-4-5 (A-N-I-L) അമർത്തിയാൽ \"Anil\"-ഉം \"അനിൽ\"-ഉം കിട്ടും.';

  @override
  String get helpT9DialingBullet9 =>
      'കീകളിൽ കാണിക്കുന്ന ലിപി മാറ്റാൻ പ്രധാന ക്രമീകരണ പേജിലെ \"ഡയൽപാഡ് ലിപി\" കാർഡ് ഉപയോഗിക്കുക.';

  @override
  String get helpT9DialingFooter =>
      'നുറുങ്ങ്: \"ഡയൽപാഡ് ലിപി\" കാർഡിൽ സ്വയം, മലയാളം, ദേവനാഗരി, സിറിലിക്, അറബിക്, ഗ്രീക്ക്, അല്ലെങ്കിൽ ഒന്നുമില്ല എന്നിവയുണ്ട്. സ്വയം ആപ്പിന്റെ ഭാഷ പിന്തുടരുന്നു. ഏത് തിരഞ്ഞെടുത്താലും തിരയൽ എല്ലാ ലിപികളുമായും ഒത്തുനോക്കും — കീകളിൽ അച്ചടിക്കുന്നത് മാത്രമേ ഈ ക്രമീകരണം മാറ്റൂ.';

  @override
  String get helpCloudSyncText => 'ക്ലൗഡ് സമന്വയവും കരുതൽശേഖരവും';

  @override
  String get helpCloudSyncIntro =>
      'SreerajP Contacts Sphere Google, Microsoft, CardDAV/WebDAV സെർവറുകളുമായി ബന്ധിപ്പിക്കുന്നു. ഒരു സേവനം മാത്രമോ അവ വേർതിരിച്ചോ ഉപയോഗിക്കാം — തത്സമയ വിലാസവിവരങ്ങൾ ഒന്നുമായി സമന്വയിപ്പിച്ച്, എൻക്രിപ്റ്റ് ചെയ്ത ഡാറ്റാബേസിന്റെ കരുതൽശേഖരം മറ്റൊന്നിൽ സൂക്ഷിക്കാം.';

  @override
  String get helpCloudSyncTitle1 =>
      'വിലാസവിവര സമന്വയവും ക്ലൗഡ് കരുതൽശേഖരവും തമ്മിൽ';

  @override
  String get helpCloudSyncBullet1 =>
      'ഓൺലൈൻ വിലാസവിവര സമന്വയം (തത്സമയ ഇരുവശം): ഓരോ വിലാസവിവര കാർഡും (പേരുകൾ, ഫോൺ നമ്പറുകൾ, ഇമെയിലുകൾ) Google People API, Microsoft Graph Contacts, അല്ലെങ്കിൽ CardDAV വിലാസപ്പുസ്തകങ്ങളുമായി നേരിട്ട് സമന്വയിപ്പിക്കുന്നു. സമന്വയിപ്പിച്ചവ നിങ്ങളുടെ ഓൺലൈൻ വിലാസപ്പുസ്തകത്തിൽ കാണാം.';

  @override
  String get helpCloudSyncBullet2 =>
      'എൻക്രിപ്റ്റ് ചെയ്ത ക്ലൗഡ് കരുതൽശേഖരം: നിങ്ങളുടെ മുഴുവൻ ഡാറ്റാബേസും (എല്ലാ വിലാസവിവരങ്ങളും, വിളി ചരിത്രം, വിളി കുറിപ്പുകൾ, അടയാളങ്ങൾ, ക്രമീകരണങ്ങൾ, അടിയന്തര വിവരങ്ങൾ) അടങ്ങിയ, പാസ്‌വേഡ് കൊണ്ട് എൻക്രിപ്റ്റ് ചെയ്ത .csbak ഫയൽ ക്ലൗഡ് ഫയൽ സംഭരണത്തിലേക്ക് (Google Drive AppData, Microsoft OneDrive, അല്ലെങ്കിൽ WebDAV) കയറ്റുമതി ചെയ്യുന്നു.';

  @override
  String get helpCloudSyncTitle2 => 'ക്ലൗഡ് സേവനങ്ങൾ ഇടകലർത്തൽ';

  @override
  String get helpCloudSyncBullet3 =>
      'തത്സമയ വിലാസവിവര സമന്വയത്തിന് Google ഉപയോഗിച്ച്, എൻക്രിപ്റ്റ് ചെയ്ത ക്ലൗഡ് കരുതൽശേഖരം Microsoft OneDrive-ലോ സ്വന്തം WebDAV സെർവറിലോ സൂക്ഷിക്കാം.';

  @override
  String get helpCloudSyncBullet4 =>
      'ക്രമീകരണങ്ങൾ → ഓൺലൈൻ സേവന സമന്വയം എന്നതിൽ നിങ്ങളുടെ Google അക്കൗണ്ടിന് \"വിലാസവിവര സമന്വയം: ഓൺ\", \"ക്ലൗഡ് കരുതൽശേഖരം: ഓഫ്\" എന്നിങ്ങനെ സജ്ജമാക്കുക.';

  @override
  String get helpCloudSyncBullet5 =>
      'Microsoft അല്ലെങ്കിൽ WebDAV അക്കൗണ്ട് വേറെ ചേർത്ത്, ക്രമീകരണങ്ങൾ → എൻക്രിപ്റ്റ് ചെയ്ത ക്ലൗഡ് കരുതൽശേഖരം എന്നതിൽ കരുതൽശേഖരം അപ്‌ലോഡ് ചെയ്യുമ്പോൾ അത് തിരഞ്ഞെടുക്കുക.';

  @override
  String get helpCloudSyncTitle3 => 'സ്വകാര്യതയും സുരക്ഷയും';

  @override
  String get helpCloudSyncBullet6 =>
      'രഹസ്യ അറയിലെ വിലാസവിവരങ്ങൾ: SreerajP Contacts Sphere-ൽ രഹസ്യമായി സൂക്ഷിച്ചവ ആപ്പിൽ മാത്രമാണ്, ഓൺലൈൻ വിലാസവിവര സേവനങ്ങളിലേക്ക് (Google Contacts, Outlook, CardDAV) ഒരിക്കലും അപ്‌ലോഡ് ചെയ്യുകയോ സമന്വയിപ്പിക്കുകയോ ഇല്ല.';

  @override
  String get helpCloudSyncBullet7 =>
      'എൻക്രിപ്റ്റ് ചെയ്ത ഉള്ളടക്കം: ക്ലൗഡ് കരുതൽശേഖര ഫയലുകൾ (.csbak) അപ്‌ലോഡ് ചെയ്യുംമുമ്പ് നിങ്ങളുടെ സ്വകാര്യ രഹസ്യവാക്യം കൊണ്ട് PBKDF2, AES-GCM ഉപയോഗിച്ച് ഫോണിൽ തന്നെ എൻക്രിപ്റ്റ് ചെയ്യുന്നു. ക്ലൗഡ് സേവനത്തിന് നിങ്ങളുടെ കരുതൽശേഖരം വായിക്കാനാവില്ല.';

  @override
  String get helpCloudSyncFooter =>
      'നുറുങ്ങ്: സജ്ജമാക്കിയ എല്ലാ അക്കൗണ്ടുകളും ക്രമീകരണങ്ങൾ → ഓൺലൈൻ സേവന സമന്വയം എന്നതിൽ നിയന്ത്രിക്കാം. ഓരോ അക്കൗണ്ടിനും തത്സമയ സമന്വയത്തിനും ക്ലൗഡ് കരുതൽശേഖരത്തിനും വെവ്വേറെ സ്വിച്ചുകളുണ്ട്.';

  @override
  String get helpPersonalizationTitle1 => 'രൂപം, ശബ്ദം, പ്രദേശം';

  @override
  String get helpPersonalizationIntro =>
      'ആപ്പിന്റെ രൂപം, ശബ്ദം, ഫോൺ നമ്പറുകൾ വായിക്കുന്ന രീതി എന്നിവയിൽ മിക്കതും മാറ്റാം. ഓരോ ക്രമീകരണവും എവിടെയാണെന്ന് ഇതാ.';

  @override
  String get helpPersonalizationTitle2 => 'തീമും നിറവും';

  @override
  String get helpPersonalizationBullet1 =>
      'ക്രമീകരണങ്ങൾ → രൂപം → തീം രീതി: ലൈറ്റ്, ഡാർക്ക്, അല്ലെങ്കിൽ സിസ്റ്റം. സിസ്റ്റം ഫോണിന്റെ സ്വന്തം ഡാർക്ക് മോഡ് ക്രമീകരണം പിന്തുടരുന്നു.';

  @override
  String get helpPersonalizationBullet2 =>
      'ക്രമീകരണങ്ങൾ → രൂപം → ആക്സന്റ് നിറം: മുൻനിശ്ചിത നിറം തിരഞ്ഞെടുക്കുക അല്ലെങ്കിൽ സ്വന്തം നിറം ഉണ്ടാക്കുക. തിരഞ്ഞെടുക്കുമ്പോൾ ദൃശ്യം പുതുക്കും.';

  @override
  String get helpPersonalizationTitle3 => 'അക്ഷരരൂപവും വലുപ്പവും';

  @override
  String get helpPersonalizationBullet3 =>
      'ക്രമീകരണങ്ങൾ → രൂപം → അക്ഷരരൂപവും വലുപ്പവും എന്നതിൽ അക്ഷരരൂപവും അക്ഷരങ്ങളുടെ വലുപ്പവും സജ്ജമാക്കാം.';

  @override
  String get helpPersonalizationBullet4 =>
      'മലയാളം എഴുതാനാകുന്ന മൂന്ന് അക്ഷരരൂപങ്ങൾ ഉള്ളിൽ തന്നെയുണ്ട് — Manjari, Anek Malayalam, Noto Sans Malayalam. ഓരോന്നും മലയാളവും ഇംഗ്ലീഷും കാണിക്കും, അതിനാൽ ഏത് ലിപിയിലെ പേരുകളും വായിക്കാം.';

  @override
  String get helpPersonalizationBullet5 =>
      'അക്ഷരരൂപങ്ങൾ ആപ്പിനുള്ളിൽ തന്നെ വരുന്നു. ഒന്നും ഡൗൺലോഡ് ചെയ്യുന്നില്ല, ഇന്റർനെറ്റില്ലാതെയും പ്രവർത്തിക്കും.';

  @override
  String get helpPersonalizationTitle4 =>
      'വിലാസവിവര പട്ടിക എങ്ങനെ ക്രമീകരിക്കാം';

  @override
  String get helpPersonalizationBullet6 =>
      'ക്രമീകരണങ്ങൾ → വിലാസവിവരങ്ങൾ → പ്രദർശനവും രൂപീകരണവും എന്നതിൽ ക്രമം (ആദ്യ പേരോ അവസാന പേരോ അനുസരിച്ച്) സജ്ജമാക്കാം.';

  @override
  String get helpPersonalizationBullet7 =>
      'ഫോൺ നമ്പറില്ലാത്ത വിലാസവിവരങ്ങൾ മറയ്ക്കാനും ഇതേ സ്ക്രീനിൽ കഴിയും, ഇമെയിൽ അക്കൗണ്ടിൽ നിന്ന് ഇറക്കുമതി ചെയ്ത പട്ടിക വൃത്തിയാക്കാൻ ഇത് സഹായിക്കും.';

  @override
  String get helpPersonalizationTitle5 => 'റിംഗ്‌ടോൺ, ശബ്ദം, കമ്പനം';

  @override
  String get helpPersonalizationBullet8 =>
      'ക്രമീകരണങ്ങൾ → റിംഗ്‌ടോൺ → ശബ്ദവും കമ്പനവും എന്നതിൽ റിംഗ്‌ടോൺ ശബ്ദവും വരുന്ന വിളികൾക്ക് കമ്പനം വേണോ എന്നും സജ്ജമാക്കാം.';

  @override
  String get helpPersonalizationBullet9 =>
      'ക്രമീകരണങ്ങൾ → റിംഗ്‌ടോൺ → ഓരോ SIM-നും റിംഗ്‌ടോൺ എന്നതിൽ SIM 1-നും SIM 2-നും വ്യത്യസ്ത ശബ്ദങ്ങൾ നൽകാം, ഏത് ലൈനാണ് റിംഗ് ചെയ്യുന്നതെന്ന് അറിയാം.';

  @override
  String get helpPersonalizationBullet10 =>
      'ഒരു ഗ്രൂപ്പിന് സ്വന്തം റിംഗ്‌ടോൺ ആകാം, ഏത് വിലാസവിവരത്തിനും തിരുത്തുമ്പോൾ ഒന്ന് നൽകാം.';

  @override
  String get helpPersonalizationBullet11 =>
      'പലതും ബാധകമാകുമ്പോൾ ഏറ്റവും കൃത്യമായതിനാണ് മുൻഗണന: ആദ്യം വിലാസവിവരത്തിന്റെ സ്വന്തം ശബ്ദം, പിന്നെ ഗ്രൂപ്പിന്റേത്, പിന്നെ SIM-ന്റേത്.';

  @override
  String get helpPersonalizationBullet12 =>
      'റിംഗ്‌ടോണുകൾ കരുതൽശേഖരത്തിലോ മറ്റൊരു ഫോണുമായുള്ള സമന്വയത്തിലോ ഉൾപ്പെടുന്നില്ല, കാരണം അവ ഈ ഫോണിലെ ഒരു ശബ്ദ ഫയലിനെയാണ് സൂചിപ്പിക്കുന്നത്.';

  @override
  String get helpPersonalizationTitle6 => 'സ്ഥിര രാജ്യം';

  @override
  String get helpPersonalizationBullet13 =>
      'ക്രമീകരണങ്ങൾ → സ്ഥിര രാജ്യം എന്നത് കോഡില്ലാത്ത സാധാരണ നമ്പറുകൾ ഏത് രാജ്യത്തേതാണെന്ന് ആപ്പിനോട് പറയുന്നു.';

  @override
  String get helpPersonalizationBullet14 =>
      '+91 98765 43210-ൽ നിന്നുള്ള വിളി നിങ്ങളുടെ വിലാസവിവരങ്ങളിൽ സൂക്ഷിച്ച 98765 43210 തന്നെയാണെന്ന് ആപ്പ് തിരിച്ചറിയുന്നത് ഇതുകൊണ്ടാണ്.';

  @override
  String get helpPersonalizationBullet15 =>
      'തടഞ്ഞ നമ്പറുകളും ഇതേ രീതിയിൽ ഒത്തുനോക്കുന്നു, അതിനാൽ പ്രാദേശിക രൂപത്തിൽ തടഞ്ഞ നമ്പർ അന്താരാഷ്ട്ര രൂപത്തിലും തടയപ്പെടും.';

  @override
  String get helpPersonalizationBullet16 =>
      'സൂക്ഷിച്ച വിലാസവിവരം അജ്ഞാത വിളിക്കാരനായി കാണിക്കുന്നതിന്റെ സാധാരണ കാരണം ഇത് തെറ്റായി സജ്ജമാക്കിയതാണ്.';

  @override
  String get helpPersonalizationFooter =>
      'നുറുങ്ങ്: തീം, ആക്സന്റ് നിറം, അക്ഷരരൂപങ്ങൾ, സ്ഥിര രാജ്യം എന്നിവ സമന്വയത്തിൽ മറ്റൊരു ഫോണിലേക്ക് പോകും. റിംഗ്‌ടോണുകളും SIM തിരഞ്ഞെടുപ്പുകളും ഈ ഫോണിന്റേതായതിനാൽ ഇവിടെ തന്നെ നിൽക്കും.';

  @override
  String get helpCallerIdSpamTitle1 => 'കോളർ ID-യും സ്പാം അരിപ്പയും';

  @override
  String get helpCallerIdSpamIntro =>
      'നിങ്ങളുടെ വിലാസവിവരങ്ങളിലില്ലാത്ത ഒരു നമ്പർ വിളിക്കുമ്പോൾ, ആപ്പ് അതിനെക്കുറിച്ച് ഉപകാരപ്രദമായ എന്തെങ്കിലും പറയാൻ ശ്രമിക്കുന്നു, സംശയമുള്ള സ്പാം വിളി ഉറക്കെ അല്ലാതെ നിശ്ശബ്ദമായി റിംഗ് ചെയ്യിക്കാനും കഴിയും. രണ്ടും നിങ്ങൾ നിയന്ത്രിക്കുന്ന സ്വിച്ചുകളാണ്, രണ്ടും പൂർണ്ണമായി ഈ ഫോണിൽ പ്രവർത്തിക്കുന്നു.';

  @override
  String get helpCallerIdSpamTitle2 => 'വിളിക്കുന്നയാളെ തിരിച്ചറിയൽ';

  @override
  String get helpCallerIdSpamBullet1 =>
      'ക്രമീകരണങ്ങൾ → SIM-ഉം ഫോൺ വിളിയും → തിരിച്ചറിയൽ → \"വിളിക്കുന്നയാളെ തിരിച്ചറിയൽ\" എന്നതിൽ ഓണാക്കുക.';

  @override
  String get helpCallerIdSpamBullet2 =>
      'അജ്ഞാത വിളിക്കാരന് ഫോണിൽ തന്നെ കണ്ടെത്താവുന്നവയിൽ നിന്ന് ഒരു പേര് നൽകുന്നു: ടെലിമാർക്കറ്റിംഗ്, സേവന നമ്പർ ശ്രേണികൾ, നിങ്ങൾ തന്നെ സ്പാം ആയി അടയാളപ്പെടുത്തിയ നമ്പറുകൾ, നെറ്റ്‌വർക്ക് അയയ്ക്കുന്നുണ്ടെങ്കിൽ അതിന്റെ സ്ഥിരീകരിച്ച വിളിക്കാരൻ അടയാളം.';

  @override
  String get helpCallerIdSpamBullet3 =>
      'വിളി സ്ക്രീനിൽ ബാഡ്ജ് കാണാം — സംശയമുള്ള സ്പാമിന് ചുവപ്പ്, ടെലിമാർക്കറ്റിംഗ് അല്ലെങ്കിൽ സേവന നമ്പറിന് ഇളം നിറം.';

  @override
  String get helpCallerIdSpamBullet4 =>
      'ഒരു നമ്പറും ഇന്റർനെറ്റിൽ തിരയുന്നില്ല. പിന്നിൽ ഒരു കോളർ ID ഡാറ്റാബേസുമില്ല, ഒന്നും അപ്‌ലോഡ് ചെയ്യുന്നില്ല.';

  @override
  String get helpCallerIdSpamTitle3 => 'സംശയമുള്ള സ്പാം അരിക്കുക';

  @override
  String get helpCallerIdSpamBullet5 =>
      'ഇതേ സ്ക്രീനിലെ രണ്ടാമത്തെ സ്വിച്ച്, \"സംശയമുള്ള സ്പാം അരിക്കുക\", അടയാളപ്പെടുത്തിയ വിളിക്കാരെ ഉറക്കെ അല്ലാതെ നിശ്ശബ്ദമായി റിംഗ് ചെയ്യിക്കുന്നു.';

  @override
  String get helpCallerIdSpamBullet6 =>
      'വിളി അപ്പോഴും വരും, സമീപകാല രേഖയിലും എത്തും. നിങ്ങളെ ശല്യപ്പെടുത്തുന്നില്ല എന്ന് മാത്രം.';

  @override
  String get helpCallerIdSpamBullet7 =>
      'ആരാണ് വിളിച്ചതെന്ന് കാണണം, പക്ഷേ ശല്യം വേണ്ട എന്നുള്ളപ്പോൾ ഇത് ഉപയോഗിക്കുക. വിളിയേ വേണ്ടെങ്കിൽ തടയൽ ഉപയോഗിക്കുക.';

  @override
  String get helpCallerIdSpamTitle4 => 'അജ്ഞാതരെ തടയുക';

  @override
  String get helpCallerIdSpamBullet8 =>
      'ക്രമീകരണങ്ങൾ → വിലാസവിവരങ്ങൾ → തടഞ്ഞ നമ്പറുകൾ എന്നതിൽ നമ്പറില്ലാതെയോ മറച്ച നമ്പറോടെയോ വരുന്ന വിളികൾക്കായി \"അജ്ഞാതരെ തടയുക\" സ്വിച്ചുണ്ട്.';

  @override
  String get helpCallerIdSpamBullet9 =>
      'അത് ഓണാണെങ്കിൽ ആ വിളികൾ ഫോൺ റിംഗ് ചെയ്യുംമുമ്പ് നിരസിക്കും, എന്നിട്ടും അവ നടന്നു എന്ന് കാണാൻ തടഞ്ഞവയായി സമീപകാല രേഖയിൽ എഴുതും.';

  @override
  String get helpCallerIdSpamBullet10 =>
      'നിങ്ങൾ സൂക്ഷിക്കാത്ത ഒരു നമ്പറിനെ ഇത് ബാധിക്കില്ല — വിളിക്കുന്നയാളുടെ നമ്പറേ ഇല്ലാത്ത വിളികളെ മാത്രം.';

  @override
  String get helpCallerIdSpamTitle5 => 'ഒരു നമ്പർ സ്പാം ആയി അടയാളപ്പെടുത്തൽ';

  @override
  String get helpCallerIdSpamBullet11 =>
      'സമീപകാല രേഖയിലെ ഒരു വിളി അമർത്തിപ്പിടിച്ച് \"സ്പാം ആയി അടയാളപ്പെടുത്തുക\" തിരഞ്ഞെടുക്കുക. പിന്നീട് അതേ ഇടത്ത് \"സ്പാം അല്ല\" എന്ന് കാണും, അടയാളം നീക്കാം.';

  @override
  String get helpCallerIdSpamBullet12 =>
      'സ്പാം അടയാളം തടയലിൽ നിന്ന് വേറിട്ടതാണ്. നമ്പറിന് അപ്പോഴും വിളിക്കാം — ഇപ്പോൾ അതിന് പേരുണ്ട്, ആ സ്വിച്ച് ഓണാണെങ്കിൽ സ്പാം അരിപ്പ അതിനെ നിശ്ശബ്ദമാക്കും.';

  @override
  String get helpCallerIdSpamBullet13 =>
      'നിങ്ങളുടെ സ്വന്തം അടയാളങ്ങൾ തിരിച്ചറിയൽ പേരിലേക്ക് ചേരുന്നു, അടുത്ത തവണ ആ നമ്പർ വിളിക്കുമ്പോൾ തിരിച്ചറിയും.';

  @override
  String get helpCallerIdSpamFooter =>
      'നുറുങ്ങ്: തിരിച്ചറിയലിനും സ്പാം അരിക്കലിനും ആപ്പ് നിങ്ങളുടെ സ്ഥിര ഫോൺ ആപ്പ് ആയിരിക്കണം, കാരണം റിംഗ് ചെയ്യുംമുമ്പ് വിളി പരിശോധിക്കാൻ Android സ്ഥിര ഡയലറിനെ മാത്രമേ അനുവദിക്കൂ.';

  @override
  String get helpImportExportTitle1 => 'ഫയൽ ഇറക്കുമതിയും കയറ്റുമതിയും';

  @override
  String get helpImportExportIntro =>
      'വിലാസവിവരങ്ങൾ സാധാരണ ഫയലുകളായി ആപ്പിലേക്കും പുറത്തേക്കും നീക്കാം — സ്പ്രെഡ്‌ഷീറ്റിൽ തുറക്കാവുന്ന CSV, അല്ലെങ്കിൽ ഏത് ഫോണിന്റെയും കമ്പ്യൂട്ടറിന്റെയും വിലാസപ്പുസ്തകം മനസ്സിലാക്കുന്ന vCard (.vcf).';

  @override
  String get helpImportExportTitle2 => 'എവിടെ കണ്ടെത്താം';

  @override
  String get helpImportExportBullet1 =>
      'വിലാസവിവരങ്ങൾ ടാബ് തുറന്ന്, മുകളിലെ ബാറിലെ മൂന്ന് കുത്ത് മെനു തൊട്ട്, \"ഇറക്കുമതി / കയറ്റുമതി\" തിരഞ്ഞെടുക്കുക.';

  @override
  String get helpImportExportBullet2 =>
      'നാല് വഴികൾ കാണാം: CSV ഇറക്കുമതി, CSV കയറ്റുമതി, vCard (.vcf) ഇറക്കുമതി, vCard (.vcf) കയറ്റുമതി.';

  @override
  String get helpImportExportTitle3 => 'ഇറക്കുമതി';

  @override
  String get helpImportExportBullet3 =>
      'സിസ്റ്റം ഫയൽ പിക്കർ വഴി നിങ്ങൾ തന്നെ ഫയൽ തിരഞ്ഞെടുക്കുന്നു. ആപ്പ് സ്വയം നിങ്ങളുടെ സംഭരണം തിരയുന്നില്ല.';

  @override
  String get helpImportExportBullet4 =>
      'ഇറക്കുമതി ചെയ്ത വിലാസവിവരങ്ങൾ ആപ്പിലേക്ക് ചേർക്കുന്നു. ഇറക്കുമതി കഴിയുമ്പോൾ എത്രയെണ്ണം വന്നു എന്ന് പറയും.';

  @override
  String get helpImportExportBullet5 =>
      'ഫയലിൽ നിങ്ങൾക്ക് നേരത്തേയുള്ളവർ ഉണ്ടെങ്കിൽ, പിന്നീട് വിലാസവിവരങ്ങൾ → മെനു → \"ഇരട്ടിപ്പുകൾ കണ്ടെത്തുക\" ഉപയോഗിച്ച് വൃത്തിയാക്കുക.';

  @override
  String get helpImportExportTitle4 => 'കയറ്റുമതി';

  @override
  String get helpImportExportBullet6 =>
      'കയറ്റുമതി ഒരു ഫയൽ എഴുതി സിസ്റ്റം പങ്കിടൽ ഷീറ്റ് തുറക്കുന്നു, എവിടേക്ക് പോകണമെന്ന് നിങ്ങൾ തീരുമാനിക്കുന്നു.';

  @override
  String get helpImportExportBullet7 =>
      'കയറ്റുമതി ഫയൽ സാധാരണമാണ്, പാസ്‌വേഡ് സംരക്ഷണമില്ല. അത് നിങ്ങളുടെ വിലാസപ്പുസ്തകത്തിന്റെ പകർപ്പായി കണക്കാക്കി, ആവശ്യം കഴിഞ്ഞാൽ ഇല്ലാതാക്കുക.';

  @override
  String get helpImportExportBullet8 =>
      'ക്രമീകരണങ്ങൾ → വിലാസവിവരങ്ങൾ → രഹസ്യ വിലാസവിവരങ്ങളും കയറ്റുമതിയും എന്നതിൽ \"കയറ്റുമതിയിൽ രഹസ്യ വിലാസവിവരങ്ങൾ ഉൾപ്പെടുത്തുക\" ഓണാക്കിയില്ലെങ്കിൽ സാധാരണ കയറ്റുമതിയിൽ രഹസ്യ വിലാസവിവരങ്ങൾ ഒഴിവാക്കും.';

  @override
  String get helpImportExportBullet9 =>
      'ഇതേ സ്ക്രീനിൽ \"രഹസ്യ വിലാസവിവരങ്ങൾ കയറ്റുമതി ചെയ്യുക\" ഉണ്ട്, രഹസ്യമായവ മാത്രമുള്ള ഒരു വേറിട്ട ഫയൽ സൂക്ഷിക്കുന്നു. ആദ്യം വിരലടയാളമോ മുഖമോ PIN-ഓ ചോദിക്കും.';

  @override
  String get helpImportExportBullet10 =>
      'എല്ലാറ്റിന്റെയും — വിളി ചരിത്രം, ഫോട്ടോകൾ, ക്രമീകരണങ്ങൾ എല്ലാം — പാസ്‌വേഡ് കൊണ്ട് പൂട്ടിയ പൂർണ്ണ പകർപ്പിന് പകരം ക്രമീകരണങ്ങൾ → കരുതൽശേഖരം, പുനഃസ്ഥാപനം ഉപയോഗിക്കുക.';

  @override
  String get helpImportExportTitle5 =>
      'AirQR: ഒരു QR കോഡിൽ ഒതുങ്ങാത്തത് അയയ്ക്കൽ';

  @override
  String get helpImportExportBullet11 =>
      'ഒരു QR കോഡിൽ ഫോട്ടോയോ നീണ്ട വിലാസവിവര കാർഡോ ഒതുങ്ങില്ല. AirQR വിവരങ്ങൾ പല ഫ്രെയിമുകളായി വിഭജിച്ച് ചലിക്കുന്ന QR കോഡായി കാണിക്കുന്നു.';

  @override
  String get helpImportExportBullet12 =>
      'ഒരു വിലാസവിവരം തുറന്ന് \"QR കോഡായി പങ്കിടുക\" തിരഞ്ഞെടുത്ത്, ആ ഡയലോഗിലെ എയർ-ഗ്യാപ് സ്ട്രീം ബട്ടൺ തൊട്ട് ചലനം തുടങ്ങുക.';

  @override
  String get helpImportExportBullet13 =>
      'മറ്റേ ഫോണിൽ വിലാസവിവരങ്ങൾ → മെനു → \"QR കോഡ് സ്കാൻ ചെയ്യുക\" തുറന്ന് ക്യാമറ ചലനത്തിന് നേരെ പിടിക്കുക. ഫ്രെയിമുകൾ വരുമ്പോൾ പുരോഗതി കാണിക്കും, എല്ലാം വന്നാൽ വിലാസവിവരം സൂക്ഷിക്കും.';

  @override
  String get helpImportExportBullet14 =>
      'ബ്ലൂടൂത്ത്, Wi-Fi, ഇന്റർനെറ്റ് വഴി ഒന്നും അയയ്ക്കുന്നില്ല — ക്യാമറ സ്ക്രീനിലേക്ക് നോക്കുന്നത് മാത്രമാണ് വഴി. പൂർത്തിയാകുന്നതുവരെ രണ്ട് ഫോണുകളും അനങ്ങാതെ പിടിക്കുക.';

  @override
  String get helpImportExportFooter =>
      'നുറുങ്ങ്: മറ്റൊരു ഫോണിലേക്ക് മാറാൻ vCard (.vcf) ആണ് സുരക്ഷിതം, കാരണം അത് ഒന്നിലധികം നമ്പറുകളും ഇമെയിലുകളും ഫോട്ടോകളും സൂക്ഷിക്കുന്നു. പട്ടിക സ്പ്രെഡ്‌ഷീറ്റിൽ തുറക്കണമെങ്കിൽ CSV ആണ് നല്ലത്.';

  @override
  String get helpPrivacySecurityText => 'സ്വകാര്യത, സുരക്ഷ, രഹസ്യ അറ';

  @override
  String get helpPrivacySecurityIntro =>
      'വിട്ടുവീഴ്ചയില്ലാത്ത സ്വകാര്യത, എൻക്രിപ്റ്റ് ചെയ്ത പ്രാദേശിക സംഭരണം, സൂക്ഷ്മമായ സുരക്ഷാ നിയന്ത്രണങ്ങൾ എന്നിവ ഉറപ്പാക്കാൻ അടിമുതൽ നിർമ്മിച്ചതാണ് SreerajP Contacts Sphere.';

  @override
  String get helpPrivacySecurityTitle1 => 'രഹസ്യ വിലാസവിവര അറ';

  @override
  String get helpPrivacySecurityBullet1 =>
      'എന്താണ് രഹസ്യ വിലാസവിവരം? \"രഹസ്യം\" എന്ന് അടയാളപ്പെടുത്തിയ ഏത് വിലാസവിവരവും പ്രധാന പട്ടികയിൽ നിന്നും T9 ഡയലർ തിരയലിൽ നിന്നും സാധാരണ കയറ്റുമതി ഫയലുകളിൽ നിന്നും പൂർണ്ണമായി മറഞ്ഞിരിക്കും.';

  @override
  String get helpPrivacySecurityBullet2 =>
      'അവ കാണാൻ: വിലാസവിവരങ്ങൾ ടാബിന്റെ മുകളിലെ ബാറിലെ പൂട്ട് ചിഹ്നം തൊട്ട് വിരലടയാളം, മുഖം, അല്ലെങ്കിൽ ഉപകരണ PIN കൊണ്ട് തുറക്കുക. അപ്പോൾ പട്ടികയിൽ മറ്റുള്ളവയ്ക്കൊപ്പം രഹസ്യ വിലാസവിവരങ്ങളും കാണാം.';

  @override
  String get helpPrivacySecurityBullet3 =>
      'മറയ്ക്കാൻ പൂട്ട് വീണ്ടും തൊടുക. വിലാസവിവര പട്ടിക വിടുമ്പോഴും അവ മറയും, അതിനാൽ നിങ്ങൾ പോയ ശേഷം ഒരിക്കലും തുറന്നുകിടക്കില്ല.';

  @override
  String get helpPrivacySecurityTitle2 => 'ബയോമെട്രിക്, ആപ്പ് PIN സംരക്ഷണം';

  @override
  String get helpPrivacySecurityBullet4 =>
      'ഉപകരണത്തിന്റെ ബയോമെട്രിക് സെൻസറുകൾ (വിരലടയാളം / മുഖം) ഉപയോഗിച്ച് മുഴുവൻ ആപ്പോ സ്വകാര്യ ഭാഗങ്ങളോ സുരക്ഷിതമാക്കാം.';

  @override
  String get helpPrivacySecurityBullet5 =>
      'ഫോണിൽ ബയോമെട്രിക് സംവിധാനമില്ലെങ്കിലോ ഫോൺ PIN-ൽ നിന്ന് വേറിട്ട കോഡ് വേണമെങ്കിലോ, ക്രമീകരണങ്ങൾ → സുരക്ഷ → ആപ്പ് പൂട്ട് എന്നതിൽ ആപ്പ് PIN സജ്ജമാക്കുക. \"ആപ്പ് പൂട്ടും PIN-ഉം\" ഗൈഡ് കാണുക.';

  @override
  String get helpPrivacySecurityTitle3 => 'സ്ക്രീൻഷോട്ട് സംരക്ഷണം';

  @override
  String get helpPrivacySecurityBullet6 =>
      'സ്വകാര്യ വിവരങ്ങളുള്ള സ്ക്രീനിലായിരിക്കുമ്പോൾ സ്ക്രീൻഷോട്ട് സംരക്ഷണം സ്ക്രീൻഷോട്ടുകളും സ്ക്രീൻ റെക്കോർഡിംഗും സമീപകാല ആപ്പുകളിൽ Android കാണിക്കുന്ന ദൃശ്യവും തടയുന്നു.';

  @override
  String get helpPrivacySecurityBullet7 =>
      'ക്രമീകരണങ്ങൾ → സുരക്ഷ → സ്ക്രീൻഷോട്ട് സംരക്ഷണം എന്നതിൽ ഓണോ ഓഫോ ആക്കാം.';

  @override
  String get helpPrivacySecurityTitle4 => 'സുരക്ഷാ മാറ്റങ്ങളുടെ രേഖ';

  @override
  String get helpPrivacySecurityBullet8 =>
      'ഒരു വിലാസവിവരത്തിലെ ഓരോ മാറ്റവും — സൃഷ്ടിച്ചതോ തിരുത്തിയതോ ഇല്ലാതാക്കിയതോ — മുമ്പും ശേഷവും എങ്ങനെയായിരുന്നു എന്നതോടെ മാറ്റങ്ങളുടെ രേഖ രേഖപ്പെടുത്തുന്നു.';

  @override
  String get helpPrivacySecurityBullet9 =>
      'എന്താണ് മാറിയതെന്ന് കൃത്യമായി കാണാൻ ഒരു എൻട്രി തുറക്കുക, മാറ്റം തെറ്റായിരുന്നെങ്കിൽ പഴയപടിയാക്കുക.';

  @override
  String get helpPrivacySecurityBullet10 =>
      'എൻട്രികൾ ക്രിപ്റ്റോഗ്രാഫിക് ഹാഷ് കൊണ്ട് കണ്ണിചേർത്തിരിക്കുന്നു, അതിനാൽ ഒരു എൻട്രി അറിയാതെ മാറ്റാനോ നീക്കാനോ കഴിയില്ല.';

  @override
  String get helpPrivacySecurityBullet11 =>
      'ക്രമീകരണങ്ങൾ → സുരക്ഷ → മാറ്റങ്ങളുടെ രേഖ; ആദ്യം തുറക്കൽ ചോദിക്കും. രേഖയുടെ ഒപ്പിട്ട പകർപ്പ് കയറ്റുമതി ചെയ്യാനും കഴിയും.';

  @override
  String get helpPrivacySecurityFooter =>
      'സുരക്ഷാ തത്വം: എല്ലാം ഈ ഫോണിൽ, ഫോണിന്റെ ഹാർഡ്‌വെയർ കീസ്റ്റോറിലുള്ള താക്കോൽ കൊണ്ട് എൻക്രിപ്റ്റ് ചെയ്ത ഡാറ്റാബേസിൽ സൂക്ഷിക്കുന്നു. ട്രാക്കിംഗില്ല, പരസ്യമില്ല, ഞങ്ങളുടേതായ ഒരു സെർവറുമില്ല.';

  @override
  String get helpContactSharingText => 'പങ്കിടലും കാർഡ് സ്കാനിംഗും';

  @override
  String get helpContactSharingIntro =>
      'ആധുനിക QR കോഡുകൾ, ഉപകരണത്തിലെ ബിസിനസ് കാർഡ് OCR ക്യാമറ സ്കാനിംഗ്, ഓഫ്‌ലൈൻ ബ്ലൂടൂത്ത് LE എന്നിവ ഉപയോഗിച്ച് വിലാസവിവരങ്ങൾ വേഗത്തിൽ കൈമാറുക.';

  @override
  String get helpContactSharingTitle1 => 'QR കോഡ് പങ്കിടലും സ്കാനറും';

  @override
  String get helpContactSharingBullet1 =>
      'QR കോഡ് കാണിക്കാൻ: ഒരു വിലാസവിവരം തുറന്ന് പങ്കിടുക തൊട്ട് \"QR കോഡായി പങ്കിടുക\" തിരഞ്ഞെടുക്കുക. മറ്റൊരാൾക്ക് സ്കാൻ ചെയ്യാൻ സാധാരണ vCard QR സ്ക്രീനിൽ വരും.';

  @override
  String get helpContactSharingBullet2 =>
      'QR കോഡ് സ്കാൻ ചെയ്യാൻ: വിലാസവിവരങ്ങൾ ടാബ് തുറന്ന് മൂന്ന് കുത്ത് മെനു തൊട്ട് \"QR കോഡ് സ്കാൻ ചെയ്യുക\" തിരഞ്ഞെടുത്ത് ക്യാമറ തുറക്കുക.';

  @override
  String get helpContactSharingBullet3 =>
      'സ്കാൻ ചെയ്തത് ആദ്യം നിങ്ങളെ കാണിക്കും. നോക്കിയ ശേഷം മാത്രമേ പുതിയ വിലാസവിവരമായി സൂക്ഷിക്കൂ.';

  @override
  String get helpContactSharingTitle2 =>
      'ബിസിനസ് കാർഡ് സ്കാനർ (ഉപകരണത്തിലെ AI)';

  @override
  String get helpContactSharingBullet4 =>
      'ഫോൺ ക്യാമറ കൊണ്ട് ഏത് കടലാസ് ബിസിനസ് കാർഡിന്റെയും ഫോട്ടോ എടുക്കുക.';

  @override
  String get helpContactSharingBullet5 =>
      'ContactSphere-ന്റെ അക്ഷര തിരിച്ചറിയൽ (OCR) ചിത്രം നിമിഷങ്ങൾക്കകം വായിച്ച് പേരുകൾ, ഫോൺ നമ്പറുകൾ, ഇമെയിലുകൾ, വിലാസങ്ങൾ, സ്ഥാപനത്തിലെ പദവികൾ എന്നിവ എടുക്കുന്നു.';

  @override
  String get helpContactSharingBullet6 =>
      'വിലാസപ്പുസ്തകത്തിൽ സൂക്ഷിക്കുംമുമ്പ് ഏത് വിവരവും പരിശോധിക്കാം, തിരുത്താം, ഒഴിവാക്കാം.';

  @override
  String get helpContactSharingBullet7 =>
      '100% ഉപകരണത്തിലെ സ്വകാര്യത: കാർഡിന്റെ ഫോട്ടോ നിങ്ങളുടെ ഫോണിൽ തന്നെ പ്രോസസ്സ് ചെയ്യുന്നു, ഒരു ക്ലൗഡ് സെർവറിലേക്കും അപ്‌ലോഡ് ചെയ്യുന്നില്ല.';

  @override
  String get helpContactSharingTitle3 => 'ഓഫ്‌ലൈൻ ബ്ലൂടൂത്ത് LE പങ്കിടൽ';

  @override
  String get helpContactSharingBullet8 =>
      'ഇന്റർനെറ്റോ ജോടിയാക്കൽ കോഡോ ഇല്ലാതെ ContactSphere ഉള്ള അടുത്തുള്ള Android ഉപകരണങ്ങളുമായി നേരിട്ട് വിലാസവിവരങ്ങൾ പങ്കിടുക.';

  @override
  String get helpContactSharingBullet9 =>
      'അയയ്ക്കുന്നയാൾ ഒരു വിലാസവിവരം തുറന്ന് പങ്കിടുക തൊട്ട് \"ബ്ലൂടൂത്ത് വഴി പങ്കിടുക\" തിരഞ്ഞെടുക്കുന്നു. സ്വീകരിക്കുന്നയാൾ വിലാസവിവരങ്ങൾ ടാബ് തുറന്ന് മൂന്ന് കുത്ത് മെനു തൊട്ട് \"ബ്ലൂടൂത്ത് കൈമാറ്റം\" തിരഞ്ഞെടുക്കുന്നു.';

  @override
  String get helpContactSharingBullet10 =>
      'സ്വീകരിക്കുന്ന ഫോൺ നിങ്ങൾ സ്ഥിരീകരിക്കേണ്ട ഒരു പരിശോധന കാണിക്കുന്നു, അതിനാൽ നിങ്ങളുടെ സമ്മതമില്ലാതെ ഒരു വിലാസവിവരം ഫോണിലേക്ക് തള്ളിക്കയറ്റാനാവില്ല.';

  @override
  String get helpContactSharingBullet11 =>
      'ഉപകരണങ്ങൾ പരസ്പരം സ്വയം കണ്ടെത്തി കുറഞ്ഞ ഊർജ്ജ റേഡിയോ വഴി വിലാസവിവരം സുരക്ഷിതമായി കൈമാറുന്നു.';

  @override
  String get helpContactSharingFooter =>
      'നുറുങ്ങ്: ഇവിടത്തെ എല്ലാ പങ്കിടൽ രീതികളും Android, iOS, കമ്പ്യൂട്ടർ വിലാസപ്പുസ്തകങ്ങൾ എല്ലാം മനസ്സിലാക്കുന്ന സാധാരണ vCard രൂപം ഉപയോഗിക്കുന്നു. മുഴുവൻ വിലാസപ്പുസ്തകവും ഫയലായി അയയ്ക്കാൻ ഇറക്കുമതി/കയറ്റുമതി ഗൈഡ് കാണുക.';

  @override
  String get helpDuplicateMergeText => 'ഇരട്ട വിലാസവിവരങ്ങളും ലയനവും';

  @override
  String get helpDuplicateMergeIntro =>
      'ContactSphere-ന്റെ ബുദ്ധിപരമായ ഇരട്ടിപ്പ് കണ്ടെത്തലും സുരക്ഷിതമായ ഒറ്റ-തൊടൽ ലയനവും ഉപയോഗിച്ച് വിലാസപ്പുസ്തകം വൃത്തിയായി സൂക്ഷിക്കുക.';

  @override
  String get helpDuplicateMergeTitle1 => 'ഇരട്ടിപ്പുകൾ എങ്ങനെ കണ്ടെത്തുന്നു';

  @override
  String get helpDuplicateMergeBullet1 =>
      'ഒരേ ഫോൺ നമ്പർ: രണ്ട് വിലാസവിവരങ്ങൾക്ക് ഒരേ അക്കങ്ങൾ, അല്ലെങ്കിൽ പൂർണ്ണ അന്താരാഷ്ട്ര രൂപത്തിലാക്കുമ്പോൾ ഒരേ നമ്പർ.';

  @override
  String get helpDuplicateMergeBullet2 =>
      'ഒരേ പേര്: രണ്ട് വിലാസവിവരങ്ങൾക്ക് ഒരേ പൂർണ്ണ പേര്, അല്ലെങ്കിൽ ലിപ്യന്തരണം ചെയ്യുമ്പോൾ ഒരേ പേര് — അതിനാൽ \"Anil\"-ഉം \"അനിൽ\"-ഉം ഒരാളായി കാണും.';

  @override
  String get helpDuplicateMergeBullet3 =>
      'ഒത്തുപോകൽ ഒരു കൂട്ടത്തിലാകെ പടരുന്നു: A B-യുമായും B C-യുമായും ഒത്തുപോയാൽ മൂന്നും ഒരു കൂട്ടമായി ഒന്നിച്ച് കാണിക്കും.';

  @override
  String get helpDuplicateMergeBullet4 =>
      'ഇമെയിൽ വിലാസങ്ങൾ മനഃപൂർവം ഉപയോഗിക്കുന്നില്ല, ഒരുപോലെ കേൾക്കുന്ന പേര് കോഡുകളും. രണ്ടും ബന്ധമില്ലാത്തവരെ തെറ്റായി ലയിപ്പിച്ചിരുന്നു.';

  @override
  String get helpDuplicateMergeTitle2 => 'ബുദ്ധിപരമായ ലയന രീതി';

  @override
  String get helpDuplicateMergeBullet5 =>
      'വിലാസവിവരങ്ങൾ ടാബ് തുറന്ന് മൂന്ന് കുത്ത് മെനു തൊട്ട് \"ഇരട്ടിപ്പുകൾ കണ്ടെത്തുക\" തിരഞ്ഞെടുക്കുക.';

  @override
  String get helpDuplicateMergeBullet6 =>
      'ഓരോ കൂട്ടവും ഒരു കാർഡായി കാണിക്കും. സൂക്ഷിക്കുന്ന വിലാസവിവരം മുകളിൽ; മറ്റുള്ളവ അതിലേക്ക് ലയിപ്പിക്കാൻ അടയാളമിട്ടിരിക്കും.';

  @override
  String get helpDuplicateMergeBullet7 =>
      'കൂട്ടത്തിൽ പെടാത്തവരുടെ അടയാളം നീക്കുക, അല്ലെങ്കിൽ മറ്റൊന്ന് സൂക്ഷിക്കാൻ ആ വരി തൊടുക.';

  @override
  String get helpDuplicateMergeBullet8 =>
      'കൂട്ടത്തിലെ എല്ലാ വ്യത്യസ്ത ഫോൺ നമ്പറുകളും ഇമെയിലുകളും വിലാസങ്ങളും ജന്മദിനങ്ങളും കുറിപ്പുകളും സൂക്ഷിക്കുന്ന വിലാസവിവരത്തിലേക്ക് മാറ്റുന്നു. ഒന്നും കളയുന്നില്ല.';

  @override
  String get helpDuplicateMergeBullet9 =>
      'ഒരു കൂട്ടം അതിന്റെ സ്വന്തം ലയിപ്പിക്കുക ബട്ടൺ കൊണ്ട് ലയിപ്പിക്കുക, അല്ലെങ്കിൽ മുഴുവൻ പട്ടികയും ഒറ്റയടിക്ക് ചെയ്യാൻ താഴെയുള്ള \"എല്ലാ കൂട്ടങ്ങളും ലയിപ്പിക്കുക\" ഉപയോഗിക്കുക.';

  @override
  String get helpDuplicateMergeTitle3 => 'സുരക്ഷയും തിരിച്ചെടുക്കലും';

  @override
  String get helpDuplicateMergeBullet10 =>
      'എല്ലാം ഒറ്റയടിക്ക് ലയിപ്പിക്കുംമുമ്പ് ക്രമീകരണങ്ങൾ → കരുതൽശേഖരം, പുനഃസ്ഥാപനം എന്നതിൽ കരുതൽശേഖരം എടുക്കുക. ഇരട്ടിപ്പുകൾ സ്ക്രീനിൽ നിന്ന് ലയനം പഴയപടിയാക്കാനാവില്ല.';

  @override
  String get helpDuplicateMergeBullet11 =>
      'ലയനം തെറ്റിയെങ്കിൽ, സൂക്ഷിച്ച വിലാസവിവരം തുറന്ന് തിരുത്തുക — അധിക നമ്പറുകളും വിവരങ്ങളും എല്ലാം അപ്പോഴും അവിടെയുണ്ട്, അവ ഒരു പുതിയ വിലാസവിവരത്തിലേക്ക് തിരികെ മാറ്റാം.';

  @override
  String get helpDuplicateMergeFooter =>
      'നുറുങ്ങ്: ഫോൺബുക്ക് സമന്വയത്തിനോ ഫയൽ ഇറക്കുമതിക്കോ ശേഷം \"ഇരട്ടിപ്പുകൾ കണ്ടെത്തുക\" പ്രവർത്തിപ്പിക്കുക — സാധാരണ ഇരട്ടിപ്പുകൾ വരുന്നത് അപ്പോഴാണ്.';

  @override
  String get helpContactSyncText => 'വിലാസവിവര സമന്വയം';

  @override
  String get helpContactSyncIntro =>
      'സമന്വയം ആപ്പിനെയും ഫോണിനെയും ഒരുപോലെ നിലനിർത്തുന്നു. ഓരോ ദിശയും നിങ്ങൾ തന്നെ നിയന്ത്രിക്കുന്നു — ഇവിടെ ഒന്നും സ്വയം പ്രവർത്തിക്കുന്നില്ല. ക്രമീകരണങ്ങൾ → വിലാസവിവരങ്ങൾ → ഉപകരണ, ക്ലൗഡ് സമന്വയം എന്നതിൽ നിന്ന് തുറക്കുക.';

  @override
  String get helpContactSyncTitle1 => 'രണ്ട് സാധാരണ പ്രവർത്തനങ്ങൾ';

  @override
  String get helpContactSyncBullet1 =>
      'ഉപകരണ വിലാസവിവരങ്ങൾ ആപ്പിലേക്ക് ചേർക്കുക: ഫോണിന്റെ വിലാസപ്പുസ്തകം ആപ്പിലേക്ക് പകർത്തുന്നു. ചേർക്കുകയോ പുതുക്കുകയോ മാത്രം — ഒരിക്കലും ഇല്ലാതാക്കുന്നില്ല.';

  @override
  String get helpContactSyncBullet2 =>
      'ആപ്പ് വിലാസവിവരങ്ങൾ ഉപകരണത്തിലേക്ക് ചേർക്കുക: ആപ്പിലെ വിലാസവിവരങ്ങൾ ഫോണിലേക്ക് പകർത്തുന്നു. ചേർക്കുകയോ പുതുക്കുകയോ മാത്രം — ഒരിക്കലും ഇല്ലാതാക്കുന്നില്ല. നിങ്ങളുടെ \"ഞാൻ\" വിലാസവിവരവും രഹസ്യ വിലാസവിവരങ്ങളും ഫോണിലേക്ക് ഒരിക്കലും അയയ്ക്കില്ല.';

  @override
  String get helpContactSyncTitle2 => 'മായ്ക്കലോടെയുള്ള സമന്വയം';

  @override
  String get helpContactSyncBullet3 =>
      'രണ്ട് \"(മായ്ക്കലോടെ)\" പ്രവർത്തനങ്ങൾ ലക്ഷ്യത്തെ ഉറവിടത്തിന്റെ കൃത്യമായ പകർപ്പാക്കുന്നു. ചേർക്കുന്നതിനും പുതുക്കുന്നതിനുമൊപ്പം അധികമുള്ളവ ഇല്ലാതാക്കുന്നു — അതിനാൽ ശ്രദ്ധയോടെ ഉപയോഗിക്കുക. ഓരോന്നും ആദ്യം സ്ഥിരീകരണം ചോദിക്കും.';

  @override
  String get helpContactSyncBullet4 =>
      'ഉപകരണ വിലാസവിവരങ്ങൾ ആപ്പിലേക്ക് (മായ്ക്കലോടെ): ഇറക്കുമതിക്ക് ശേഷം, ഫോണിൽ നിന്ന് വന്നതും ഇപ്പോൾ ഫോണിലില്ലാത്തതുമായ ആപ്പ് വിലാസവിവരങ്ങൾ ഇല്ലാതാക്കുന്നു. നിങ്ങളുടെ \"ഞാൻ\" വിലാസവിവരമോ രഹസ്യ വിലാസവിവരങ്ങളോ ആപ്പിൽ മാത്രം ഉണ്ടാക്കിയവയോ ഒരിക്കലും ഇല്ലാതാക്കില്ല.';

  @override
  String get helpContactSyncBullet5 =>
      'ആപ്പ് വിലാസവിവരങ്ങൾ ഉപകരണത്തിലേക്ക് (മായ്ക്കലോടെ): പകർത്തിയ ശേഷം, ആപ്പിലില്ലാത്ത ഉപകരണ വിലാസവിവരങ്ങൾ ഇല്ലാതാക്കുന്നു. നിങ്ങളുടെ \"ഞാൻ\" വിലാസവിവരവുമായോ ഒരു രഹസ്യ വിലാസവിവരവുമായോ ഒത്തുപോകുന്ന ഉപകരണ വിലാസവിവരങ്ങൾ ഒരിക്കലും ഇല്ലാതാക്കില്ല, അവ ഫോണിലേക്ക് പകർത്താറില്ലെങ്കിലും.';

  @override
  String get helpContactSyncTitle3 => 'വിളി രേഖ';

  @override
  String get helpContactSyncBullet6 =>
      'ഫോണിന്റെ വിളി രേഖ സ്വയം സമീപകാല രേഖയിലേക്ക് സമന്വയിക്കുന്നു — ആപ്പ് തുടങ്ങുമ്പോൾ, സമീപകാലം തുറക്കുമ്പോൾ, വിളി കഴിയുമ്പോൾ. മറ്റൊരു ഡയലറിൽ നിന്നോ ആപ്പ് അടച്ചിരിക്കുമ്പോഴോ ചെയ്ത വിളികൾ ഇങ്ങനെ വരും. നിങ്ങൾ ഒന്നും ചെയ്യേണ്ടതില്ല.';

  @override
  String get helpContactSyncBullet7 =>
      'ഉപകരണ വിളി രേഖ ആപ്പിലേക്ക് ചേർക്കുക: സ്വയം സമന്വയം എത്തുന്നതിനേക്കാൾ പഴയ വിളി ചരിത്രം ഒറ്റയടിക്ക് കൊണ്ടുവരുന്നു. ആപ്പിൽ നേരത്തേയുള്ള വിളികൾ ഒഴിവാക്കുന്നു, അതിനാൽ വീണ്ടും പ്രവർത്തിപ്പിക്കുന്നത് സുരക്ഷിതമാണ്.';

  @override
  String get helpContactSyncBullet8 =>
      'ഉപകരണ വിളി രേഖ ആപ്പിലേക്ക് (മായ്ക്കലോടെ): സമീപകാല രേഖ മായ്ച്ച് ഫോണിന്റെ വിളി രേഖയിൽ നിന്ന് വീണ്ടും നിർമ്മിക്കുന്നു. ആപ്പിൽ സൂക്ഷിച്ച വിളി കുറിപ്പുകളും പ്രതികരണങ്ങളും നഷ്ടപ്പെടും.';

  @override
  String get helpContactSyncBullet9 =>
      'വിളി രേഖയ്ക്ക് \"ആപ്പിൽ നിന്ന് ഉപകരണത്തിലേക്ക്\" ഇല്ല: ഫോണിന്റെ വിളി രേഖ Android-ന്റേതാണ്, അത് സ്വയം വിളികൾ രേഖപ്പെടുത്തുന്നു.';

  @override
  String get helpContactSyncFooter =>
      'നുറുങ്ങ്: മായ്ക്കലോടെയുള്ള സമന്വയം പഴയപടിയാക്കാനാവില്ല. ഉറപ്പില്ലെങ്കിൽ ആദ്യം കരുതൽശേഖരം എടുക്കുക (ക്രമീകരണങ്ങൾ → കരുതൽശേഖരം, പുനഃസ്ഥാപനം).';

  @override
  String get helpCallScreeningText => 'വിളി പരിശോധനയും തടയലും';

  @override
  String get helpCallScreeningIntro =>
      'ഫോൺ റിംഗ് ചെയ്യുംമുമ്പ് ആപ്പിന് ഒരു വിളി തിരിച്ചയയ്ക്കാം. തടയൽ നിങ്ങൾ തന്നെ ഉണ്ടാക്കുന്ന പട്ടികയാണ്, വരുന്ന നമ്പറുമായി ഈ ഫോണിൽ തന്നെ ഒത്തുനോക്കുന്നു — മറ്റെവിടെയും ഒന്നും തിരയുന്നില്ല.';

  @override
  String get helpCallScreeningTitle1 => 'വിളി പരിശോധന എങ്ങനെ പ്രവർത്തിക്കുന്നു';

  @override
  String get helpCallScreeningBullet1 =>
      'ഒരു വിളി വരുമ്പോൾ, ഫോൺ റിംഗ് ചെയ്യുംമുമ്പ് Android നമ്പർ ആപ്പിന്റെ വിളി പരിശോധനാ സേവനത്തിന് നൽകുന്നു.';

  @override
  String get helpCallScreeningBullet2 =>
      'നമ്പർ നിങ്ങളുടെ തടഞ്ഞ പട്ടികയിലാണെങ്കിൽ വിളി ഉടനെ നിരസിക്കും — റിംഗില്ല, കമ്പനമില്ല, വിളി സ്ക്രീനില്ല.';

  @override
  String get helpCallScreeningBullet3 =>
      'നിങ്ങളുടെ സ്ഥിര രാജ്യം ഉപയോഗിച്ച് പൂർണ്ണ അന്താരാഷ്ട്ര രൂപത്തിലാക്കിയ ശേഷമാണ് നമ്പറുകൾ ഒത്തുനോക്കുന്നത്, അതിനാൽ 98765 43210 ആയി തടഞ്ഞ നമ്പർ +91 98765 43210-നെയും തടയും.';

  @override
  String get helpCallScreeningBullet4 =>
      'തടഞ്ഞ വിളിയും \"തടഞ്ഞു\" എന്ന അടയാളത്തോടെ സമീപകാല രേഖയിൽ എഴുതും, ആരാണ് ശ്രമിച്ചതെന്ന് കാണാം.';

  @override
  String get helpCallScreeningTitle2 => 'ഒരു നമ്പർ തടയൽ';

  @override
  String get helpCallScreeningBullet5 =>
      'സമീപകാലത്തിൽ നിന്ന്: വിളി അമർത്തിപ്പിടിച്ച് \"നമ്പർ തടയുക\" തിരഞ്ഞെടുക്കുക. പിന്നീട് അതേ ഇടത്ത് \"തടയൽ നീക്കുക\" എന്ന് കാണും.';

  @override
  String get helpCallScreeningBullet6 =>
      'വിളിക്കിടെ: വിളി സ്ക്രീനിലെ തടയുക തൊടുക. റിംഗ് ചെയ്യുമ്പോഴും സംസാരിക്കുമ്പോഴും ഇത് പ്രവർത്തിക്കും.';

  @override
  String get helpCallScreeningBullet7 =>
      'കൈകൊണ്ട്: ക്രമീകരണങ്ങൾ → വിലാസവിവരങ്ങൾ → തടഞ്ഞ നമ്പറുകൾ, തുടർന്ന് നമ്പർ സ്വയം ചേർക്കുക.';

  @override
  String get helpCallScreeningBullet8 =>
      'ഇപ്പോൾ വിളിയിലുള്ള ഒരു നമ്പർ തടഞ്ഞാൽ, എവിടെ നിന്ന് തടഞ്ഞാലും ആ വിളി ഉടനെ അവസാനിക്കും.';

  @override
  String get helpCallScreeningTitle3 => 'നമ്പറില്ലാത്ത വിളിക്കാർ';

  @override
  String get helpCallScreeningBullet9 =>
      'മറച്ചതോ തടഞ്ഞുവച്ചതോ ആയ നമ്പറോടെ വരുന്ന വിളികൾക്കായി ക്രമീകരണങ്ങൾ → വിലാസവിവരങ്ങൾ → തടഞ്ഞ നമ്പറുകൾ എന്നതിൽ \"അജ്ഞാതരെ തടയുക\" സ്വിച്ചുമുണ്ട്.';

  @override
  String get helpCallScreeningBullet10 =>
      'ആ വിളികൾ റിംഗ് ചെയ്യുംമുമ്പ് നിരസിക്കും, എന്നിട്ടും തടഞ്ഞവയായി സമീപകാല രേഖയിൽ രേഖപ്പെടുത്തും.';

  @override
  String get helpCallScreeningBullet11 =>
      'നിങ്ങൾ സൂക്ഷിക്കാത്ത സാധാരണ നമ്പറുകളെ ഇത് ബാധിക്കില്ല — നമ്പറേ ഇല്ലാത്ത വിളികളെ മാത്രം.';

  @override
  String get helpCallScreeningTitle4 => 'തടയുന്നതിനു പകരം നിശ്ശബ്ദമാക്കൽ';

  @override
  String get helpCallScreeningBullet12 =>
      'വിളി കാണണം, പക്ഷേ ശല്യം വേണ്ടെങ്കിൽ, ക്രമീകരണങ്ങൾ → SIM-ഉം ഫോൺ വിളിയും → തിരിച്ചറിയൽ എന്നതിലെ \"സംശയമുള്ള സ്പാം അരിക്കുക\" ഉപയോഗിക്കുക. അപ്പോൾ അടയാളപ്പെടുത്തിയ വിളിക്കാർ നിശ്ശബ്ദമായി റിംഗ് ചെയ്യും.';

  @override
  String get helpCallScreeningBullet13 =>
      'ഒരു വിളിക്കാരനെ എങ്ങനെ അടയാളപ്പെടുത്തുന്നു എന്നറിയാൻ \"കോളർ ID-യും സ്പാം അരിപ്പയും\" ഗൈഡ് കാണുക.';

  @override
  String get helpCallScreeningTitle5 => 'സ്ഥിര ഫോൺ ആപ്പ് ആയിരിക്കണം';

  @override
  String get helpCallScreeningBullet14 =>
      'റിംഗ് ചെയ്യുംമുമ്പ് വിളി പരിശോധിക്കാൻ Android സ്ഥിര ഫോൺ ആപ്പിനെ മാത്രമേ അനുവദിക്കൂ. ആ ചുമതലയില്ലെങ്കിൽ ആവശ്യത്തിന് നേരത്തേ തടയാനാവില്ല.';

  @override
  String get helpCallScreeningBullet15 =>
      'ആപ്പിന് ഇപ്പോൾ ആ ചുമതലയുണ്ടോ എന്ന് ക്രമീകരണങ്ങൾ → അനുമതികൾ കാണിക്കുന്നു, അത് ചോദിക്കാനും അനുവദിക്കുന്നു.';

  @override
  String get helpCallScreeningFooter =>
      'സ്വകാര്യതാ കുറിപ്പ്: പരിശോധന പൂർണ്ണമായി ഈ ഫോണിൽ, നിങ്ങളുടെ സ്വന്തം പട്ടികയുമായാണ്. ഒരു ഫോൺ നമ്പറും ഒരിക്കലും സെർവറിലേക്ക് അയയ്ക്കുന്നില്ല, പിന്നിൽ പങ്കിട്ട സ്പാം ഡാറ്റാബേസുമില്ല.';

  @override
  String get helpPermissionsTitle1 => 'അനുമതികൾ വിശദമായി';

  @override
  String get helpPermissionsIntro =>
      'ക്രമീകരണങ്ങൾ → അനുമതികൾ എന്നതിൽ ആപ്പിന് ലഭ്യമായതെല്ലാം ഓരോന്നിന്റെയും തത്സമയ നിലയോടെ കാണാം. ഓരോന്നും എന്തിനാണെന്നും വേണ്ടെന്ന് പറഞ്ഞാൽ എന്ത് പ്രവർത്തിക്കാതാകുമെന്നും ഈ പേജ് വിശദീകരിക്കുന്നു.';

  @override
  String get helpPermissionsTitle2 => 'രണ്ട് തരം അനുമതികൾ';

  @override
  String get helpPermissionsBullet1 =>
      'നേരിട്ട് — Android നിങ്ങളോട് ചോദിക്കുന്നു, വേണ്ടെന്ന് പറയാം, പിന്നീട് മനസ്സ് മാറ്റാം. അനുവദിച്ചു / നിരസിച്ചു എന്ന് അരികിൽ കാണുന്നവ ഇവയാണ്.';

  @override
  String get helpPermissionsBullet2 =>
      'സ്വയം — ആപ്പ് നിർമ്മിക്കുമ്പോൾ പ്രഖ്യാപിക്കുകയും സ്ഥാപിക്കുമ്പോൾ സിസ്റ്റം അനുവദിക്കുകയും ചെയ്യുന്നവ. ചോദ്യമില്ല, കാരണം അവയ്ക്ക് സ്വയം നിങ്ങളുടെ വ്യക്തിഗത വിവരങ്ങളിൽ എത്താനാവില്ല.';

  @override
  String get helpPermissionsTitle3 => 'ഫോൺ വിളിക്കായി';

  @override
  String get helpPermissionsBullet3 =>
      'സ്ഥിര ഫോൺ ആപ്പ് — ഇതിനെ സിസ്റ്റം ഡയലറാക്കുന്നു, സ്വന്തം വിളി സ്ക്രീനും പൂർണ്ണ സ്ക്രീൻ വിളി അറിയിപ്പുകളും കാണിക്കാനും റിംഗ് ചെയ്യുംമുമ്പ് വിളികൾ പരിശോധിക്കാനും. ഇതില്ലാതെ വിളിക്കാം, പക്ഷേ തടയലും പരിശോധനയും പ്രവർത്തിക്കില്ല.';

  @override
  String get helpPermissionsBullet4 =>
      'ഫോണും വിളി രേഖയും — വിളികൾ ചെയ്യാനും എടുക്കാനും നിയന്ത്രിക്കാനും, സമീപകാല രേഖയ്ക്കായി വിളിയുടെ യഥാർത്ഥ ദൈർഘ്യം വായിക്കാനും.';

  @override
  String get helpPermissionsBullet5 =>
      'വിളി സേവനവും റിംഗിംഗും — വിളി നിലനിർത്തുകയും ആപ്പിനെ റിംഗ് ചെയ്യാനും വരുന്ന വിളി സ്ക്രീൻ കാണിക്കാനും അനുവദിക്കുകയും ചെയ്യുന്നു.';

  @override
  String get helpPermissionsBullet6 =>
      'ചെവിക്കടുത്ത് സ്ക്രീൻ ഓഫ് — ഫോൺ ചെവിയോട് ചേർത്തിരിക്കുമ്പോൾ കവിൾ ബട്ടണുകൾ അമർത്താതിരിക്കാൻ സ്ക്രീൻ ഓഫാക്കുന്നു.';

  @override
  String get helpPermissionsTitle4 => 'വിലാസവിവരങ്ങൾക്കായി';

  @override
  String get helpPermissionsBullet7 =>
      'വിലാസവിവരങ്ങൾ — ഫോണിന്റെ വിലാസപ്പുസ്തകം വായിക്കാനും സമന്വയിപ്പിക്കാനും. ഇതില്ലാതെ ആപ്പ് സ്വന്തം വിലാസവിവരങ്ങൾ സൂക്ഷിക്കും, പക്ഷേ ഫോണിലേത് കാണാനോ പുതുക്കാനോ കഴിയില്ല.';

  @override
  String get helpPermissionsBullet8 =>
      'ഫോട്ടോകളും മീഡിയയും — ഗാലറിയിൽ നിന്ന് ഫോട്ടോ തിരഞ്ഞെടുക്കാൻ.';

  @override
  String get helpPermissionsBullet9 =>
      'ക്യാമറ — വിലാസവിവര ഫോട്ടോ എടുക്കാനും QR കോഡോ കടലാസ് ബിസിനസ് കാർഡോ സ്കാൻ ചെയ്യാനും.';

  @override
  String get helpPermissionsBullet10 =>
      'മൈക്രോഫോൺ — വിളി കുറിപ്പ് ടൈപ്പ് ചെയ്യുന്നതിനു പകരം പറഞ്ഞുകൊടുക്കാൻ.';

  @override
  String get helpPermissionsBullet11 =>
      'സ്ഥാനം — ഒരു വിലാസവിവരത്തിന് സ്ഥലം അടയാളപ്പെടുത്താൻ; പഴയ Android പതിപ്പുകളിൽ ബ്ലൂടൂത്ത് തിരയലിനും ഇത് വേണം.';

  @override
  String get helpPermissionsTitle5 =>
      'ഓർമ്മപ്പെടുത്തലുകൾക്കും അടിയന്തര കാർഡിനും';

  @override
  String get helpPermissionsBullet12 =>
      'അറിയിപ്പുകൾ — ജന്മദിനങ്ങൾ, തുടർനടപടികൾ, നഷ്ടമായ വിളികൾ എന്നിവയുടെ ഓർമ്മപ്പെടുത്തലുകൾ കാണിക്കാനും, അടിയന്തര വിവര കാർഡ് ലോക്ക് സ്ക്രീനിൽ വയ്ക്കാനും.';

  @override
  String get helpPermissionsBullet13 =>
      'അലാറങ്ങളും ഓർമ്മപ്പെടുത്തലുകളും — ആപ്പ് അടച്ചിരുന്നാലും നിങ്ങൾ നിശ്ചയിച്ച സമയത്ത് Smart Redial തിരികെ വിളിക്കാൻ.';

  @override
  String get helpPermissionsBullet14 =>
      'പുനരാരംഭത്തിനു ശേഷം തുടങ്ങുക — ഫോൺ പുനരാരംഭിച്ച ശേഷം അടിയന്തര വിവര കാർഡ് ലോക്ക് സ്ക്രീനിൽ തിരികെ വയ്ക്കുന്നു.';

  @override
  String get helpPermissionsTitle6 => 'പങ്കിടലിനും സമന്വയത്തിനും';

  @override
  String get helpPermissionsBullet15 =>
      'ബ്ലൂടൂത്ത് തിരയൽ, ബന്ധം, ദൃശ്യത — ബ്ലൂടൂത്ത് വഴി വിലാസവിവരം പങ്കിടുമ്പോൾ അടുത്തുള്ള ഫോൺ കണ്ടെത്താനും ബന്ധിപ്പിക്കാനും കണ്ടെത്താവുന്നതാകാനും.';

  @override
  String get helpPermissionsBullet16 =>
      'ഇന്റർനെറ്റും Wi-Fi-യും — ഉപകരണ സമന്വയ സമയത്ത് നിങ്ങളുടെ സ്വന്തം പ്രാദേശിക Wi-Fi വഴി മറ്റൊരു ഫോണിലേക്ക് വിവരങ്ങൾ പകർത്താൻ മാത്രം. ഓൺലൈൻ സമന്വയമോ ക്ലൗഡ് കരുതൽശേഖരമോ നിങ്ങൾ തന്നെ സജ്ജമാക്കിയില്ലെങ്കിൽ ഒരു ക്ലൗഡ് സെർവറുമായും ബന്ധപ്പെടുന്നില്ല.';

  @override
  String get helpPermissionsBullet17 =>
      'ബയോമെട്രിക്സ് — രഹസ്യ വിലാസവിവരങ്ങൾ തുറക്കാനും, അവ ഉൾപ്പെട്ടേക്കാവുന്ന വിവരങ്ങൾ കയറ്റുമതി ചെയ്യുകയോ സമന്വയിപ്പിക്കുകയോ ചെയ്യുംമുമ്പ് സ്ഥിരീകരിക്കാനും.';

  @override
  String get helpPermissionsTitle7 => 'വേണ്ടെന്ന് പറയലും മനസ്സ് മാറ്റലും';

  @override
  String get helpPermissionsBullet18 =>
      'ഓരോ അനുമതിയും ആവശ്യമുള്ള സവിശേഷത ആദ്യം ഉപയോഗിക്കുമ്പോൾ മാത്രമേ ചോദിക്കൂ. സ്ഥാപിക്കുമ്പോൾ ഒന്നും ചോദിക്കുന്നില്ല.';

  @override
  String get helpPermissionsBullet19 =>
      'ഒന്ന് നിരസിച്ചാൽ ആ സവിശേഷത മാത്രം പ്രവർത്തിക്കാതാകും. ആപ്പിന്റെ ബാക്കി പ്രവർത്തിച്ചുകൊണ്ടിരിക്കും.';

  @override
  String get helpPermissionsBullet20 =>
      'രണ്ടുതവണ നിരസിച്ച അനുമതി \"തടഞ്ഞു\" എന്ന് കാണിക്കും. Android വീണ്ടും ചോദിക്കില്ല — കൈകൊണ്ട് മാറ്റാൻ അനുമതികൾ സ്ക്രീനിന്റെ മുകളിലെ ബാറിലെ ക്രമീകരണ ബട്ടൺ ഉപയോഗിക്കുക.';

  @override
  String get helpPermissionsFooter =>
      'ആപ്പിൽ പരസ്യമോ വിശകലനമോ ആയ കോഡില്ല, ഞങ്ങളുടെ ഒരു സെർവറുമായും ബന്ധപ്പെടുന്നില്ല. ഫോൺ വിട്ടുപോകുന്നതെന്തും നിങ്ങൾ സമന്വയമോ പങ്കിടലോ ക്ലൗഡ് കരുതൽശേഖരമോ സജ്ജമാക്കിയതുകൊണ്ട് മാത്രമാണ്.';

  @override
  String get helpEmergencyInfoText => 'അടിയന്തര വിവരങ്ങൾ';

  @override
  String get helpEmergencyInfoIntro =>
      'നിങ്ങൾക്ക് സുഖമില്ലാതെ കാണുന്ന ഒരാളെ സഹായിക്കാവുന്ന ചില വിവരങ്ങൾ അടിയന്തര കാർഡിലുണ്ട് — രക്തഗ്രൂപ്പ്, അലർജികൾ, ആരെ വിളിക്കണം. PIN ഇല്ലാതെ ലോക്ക് സ്ക്രീനിൽ ഇത് വായിക്കാം.';

  @override
  String get helpEmergencyInfoTitle1 => '\"തുറക്കാതെ\" എന്നതിന്റെ അർത്ഥം';

  @override
  String get helpEmergencyInfoBullet1 =>
      'കാർഡ് ഓണായിരിക്കുമ്പോൾ \"അടിയന്തര വിവരങ്ങൾ\" എന്ന അറിയിപ്പ് ലോക്ക് സ്ക്രീനിലുണ്ടാകും. അത് തൊട്ടാൽ കാർഡ് ഉടനെ തുറക്കും — PIN, വിരലടയാളം, മുഖം ഒന്നും വേണ്ട.';

  @override
  String get helpEmergencyInfoBullet2 =>
      'ഫോൺ പൂട്ടിത്തന്നെയിരിക്കും. കാർഡ് മാത്രം തുറക്കും; ആപ്പിന്റെ ബാക്കിയും ഫോണിലെ മറ്റെല്ലാം അടഞ്ഞുതന്നെ.';

  @override
  String get helpEmergencyInfoBullet3 =>
      'ലോക്ക് സ്ക്രീനിലെ അടിയന്തര ബട്ടണിന് പിന്നിൽ Android-ന് സ്വന്തം \"അടിയന്തര വിവരങ്ങൾ\" പേജുണ്ട്. അത് ഫോൺ നിർമ്മാതാവിന്റേതാണ്, ഒരു ആപ്പിനും അതിൽ എഴുതാനാവില്ല — അതുകൊണ്ടാണ് SreerajP Contacts Sphere സ്വന്തം അറിയിപ്പ് ഉപയോഗിക്കുന്നത്.';

  @override
  String get helpEmergencyInfoTitle2 => 'ഓരോ വരിയും നിങ്ങൾ തിരഞ്ഞെടുക്കുന്നു';

  @override
  String get helpEmergencyInfoBullet4 =>
      'നിങ്ങൾ ഓണാക്കുന്നതുവരെ മുഴുവൻ സവിശേഷതയും ഓഫാണ്.';

  @override
  String get helpEmergencyInfoBullet5 =>
      'ഓരോ വിവരത്തിനും സ്വന്തം \"ലോക്ക് സ്ക്രീനിൽ കാണിക്കുക\" സ്വിച്ചുണ്ട്. ഓഫാക്കി വിടുന്ന വിവരം ഒരിക്കലും ആപ്പ് വിട്ടുപോകില്ല.';

  @override
  String get helpEmergencyInfoBullet6 =>
      'തിരുത്തൽ സ്ക്രീനിന്റെ താഴെയുള്ള ദൃശ്യം ഒരു അപരിചിതൻ കാണുന്നത് കൃത്യമായി കാണിക്കുന്നു.';

  @override
  String get helpEmergencyInfoBullet7 =>
      'കാർഡ് ഓഫാക്കിയാൽ അറിയിപ്പ് നീങ്ങും, ലോക്ക് സ്ക്രീൻ വായിച്ചിരുന്ന പകർപ്പ് മായും. നിങ്ങൾ ടൈപ്പ് ചെയ്തത് ആപ്പിനുള്ളിൽ സൂക്ഷിച്ചിരിക്കും.';

  @override
  String get helpEmergencyInfoTitle3 => 'സഹായത്തിനായി വിളിക്കൽ';

  @override
  String get helpEmergencyInfoBullet8 =>
      'നിങ്ങൾ ചേർക്കുന്ന ഓരോ വ്യക്തിക്കും കാർഡിൽ വിളിക്കുക ബട്ടൺ കിട്ടും. അത് തൊട്ടാൽ ലോക്ക് സ്ക്രീനിൽ നിന്ന് ഉടനെ അവരെ വിളിക്കും.';

  @override
  String get helpEmergencyInfoBullet9 =>
      'വിലാസവിവരങ്ങളിൽ നിന്ന് തിരഞ്ഞെടുത്തവരെ ഒരു പേരും ഒരു നമ്പറുമായി കാർഡിലേക്ക് പകർത്തുന്നു. ആ വിലാസവിവരം പിന്നീട് തിരുത്തിയാൽ കാർഡ് മാറില്ല — ഈ സ്ക്രീൻ തുറന്ന് വീണ്ടും സൂക്ഷിക്കുക.';

  @override
  String get helpEmergencyInfoTitle4 =>
      'ലോക്ക് സ്ക്രീനിൽ കാർഡ് കാണുന്നില്ലെങ്കിൽ';

  @override
  String get helpEmergencyInfoBullet10 =>
      'ലോക്ക് സ്ക്രീൻ ഏത് അറിയിപ്പുകൾ കാണിക്കണമെന്ന് നിങ്ങളുടെ ഫോൺ തീരുമാനിക്കുന്നു. ക്രമീകരണങ്ങൾ → അറിയിപ്പുകൾ → ലോക്ക് സ്ക്രീനിലെ അറിയിപ്പുകൾ തുറന്ന് \"സംഭാഷണങ്ങൾ, സ്ഥിരം, നിശ്ശബ്ദം എന്നിവ കാണിക്കുക\" തിരഞ്ഞെടുക്കുക.';

  @override
  String get helpEmergencyInfoBullet11 =>
      'അത് \"നിശ്ശബ്ദ അറിയിപ്പുകൾ മറയ്ക്കുക\" അല്ലെങ്കിൽ \"ഒരു അറിയിപ്പും കാണിക്കരുത്\" ആണെങ്കിൽ കാർഡ് അവിടെ വരില്ല. ഒരു ആപ്പിനും ആ തിരഞ്ഞെടുപ്പ് മറികടക്കാനാവില്ല.';

  @override
  String get helpEmergencyInfoBullet12 =>
      'SreerajP Contacts Sphere-ന്റെ അറിയിപ്പുകൾ ഓണാണെന്നും \"അടിയന്തര വിവരങ്ങൾ\" അറിയിപ്പ് നിശ്ശബ്ദമാക്കിയിട്ടില്ലെന്നും ഉറപ്പാക്കുക. ഇവയിലൊന്ന് സംഭവിച്ചാൽ തിരുത്തൽ സ്ക്രീൻ മുന്നറിയിപ്പ് നൽകും, അവിടത്തെ ബട്ടൺ ശരിയായ ക്രമീകരണ പേജ് തുറക്കും.';

  @override
  String get helpEmergencyInfoBullet13 =>
      'കാർഡ് മനഃപൂർവം എപ്പോഴും അറിയിപ്പ് പട്ടികയിലുണ്ടാകും — ഒറ്റ തൊടൽ ദൂരത്ത് ഇരിക്കാനാണിത്, അബദ്ധത്തിൽ തട്ടിമാറ്റാനാവില്ല.';

  @override
  String get helpEmergencyInfoTitle5 => 'ഇത് എങ്ങനെ സൂക്ഷിക്കുന്നു';

  @override
  String get helpEmergencyInfoBullet14 =>
      'നിങ്ങളുടെ പൂർണ്ണ രേഖ മറ്റ് വിലാസവിവരങ്ങൾ പോലെ ആപ്പിന്റെ എൻക്രിപ്റ്റ് ചെയ്ത ഡാറ്റാബേസിൽ തന്നെ.';

  @override
  String get helpEmergencyInfoBullet15 =>
      'നിങ്ങൾ ഓണാക്കിയ വരികൾ മാത്രം, ഫോൺ പൂട്ടിയിരിക്കുമ്പോൾ ലോക്ക് സ്ക്രീൻ കാർഡിന് വായിക്കാവുന്ന ഒരു ചെറിയ സാധാരണ ഫയലിലേക്ക് പകർത്തുന്നു. ആ പകർപ്പ് എൻക്രിപ്റ്റ് ചെയ്യാനാവില്ല — പൂട്ടിയ ഫോണിന് ഒരു അപരിചിതനുവേണ്ടി അത് തുറക്കാൻ വഴിയില്ല.';

  @override
  String get helpEmergencyInfoBullet16 =>
      'ആ പകർപ്പ് ആപ്പിന്റെ സ്വകാര്യ സംഭരണത്തിനുള്ളിലാണ്. മറ്റ് ആപ്പുകൾക്ക് വായിക്കാനാവില്ല, ഫോൺ കരുതൽശേഖരത്തിൽ ഉൾപ്പെടുന്നുമില്ല.';

  @override
  String get helpEmergencyInfoBullet17 =>
      'കാർഡ് പാസ്‌വേഡ് സംരക്ഷിതമായ SreerajP Contacts Sphere കരുതൽശേഖരത്തിനുള്ളിൽ സൂക്ഷിക്കുന്നു, അതിനാൽ പുതിയ ഫോണിൽ പുനഃസ്ഥാപിക്കുമ്പോൾ തിരികെ വരും.';

  @override
  String get helpEmergencyInfoBullet18 =>
      'മറ്റൊരു ഫോണിലേക്കുള്ള പൂർണ്ണ സമന്വയത്തിലും, പങ്കിടാനുള്ളവ തിരഞ്ഞെടുക്കുമ്പോൾ \"അടിയന്തര വിവര കാർഡ്\" അടയാളമിട്ടാലും ഇത് പോകും. മറ്റേ ഫോണിന് സ്വന്തം കാർഡില്ലെങ്കിൽ മാത്രമേ അത് സ്വീകരിക്കൂ — നിങ്ങളുടെ കാർഡ് മറ്റൊരാളുടേതിന് പകരമാകില്ല.';

  @override
  String get helpEmergencyInfoFooter =>
      'നുറുങ്ങ്: ചുരുക്കി വയ്ക്കുക. രക്തഗ്രൂപ്പ്, ഗുരുതരമായ അലർജികൾ, വിളിക്കേണ്ട ഒന്നോ രണ്ടോ പേർ — നീണ്ട ആരോഗ്യ ചരിത്രത്തേക്കാൾ സഹായിക്കുന്നയാൾക്ക് ഇവയാണ് ഏറെ വിലപ്പെട്ടത്.';

  @override
  String get descCatImmediateFamily =>
      'നിങ്ങളോടൊപ്പം താമസിക്കുന്നവരോ ഒപ്പം വളർന്നവരോ.';

  @override
  String get descCatExtendedFamily =>
      'അടുത്ത കുടുംബത്തിന് പുറത്തുള്ള രക്തബന്ധുക്കൾ.';

  @override
  String get descCatFamilyByMarriage =>
      'വിവാഹം വഴിയുള്ള ബന്ധുക്കളും രണ്ടാനച്ഛൻ/അമ്മ വഴിയുള്ളവരും.';

  @override
  String get descCatProfessional =>
      'ഒപ്പം ജോലി ചെയ്യുന്നവരോ ഇടപാടുകൾ നടത്തുന്നവരോ.';

  @override
  String get descCatEducational =>
      'സ്കൂൾ, കോളേജ്, പരിശീലനം എന്നിവയിൽ നിന്നുള്ളവർ.';

  @override
  String get descCatSocial => 'സുഹൃത്തുക്കൾ, അയൽക്കാർ, മറ്റ് ബന്ധങ്ങൾ.';

  @override
  String get descCatService => 'നിങ്ങൾ സേവനം ഉപയോഗിക്കുന്നവർ.';

  @override
  String helpRelationshipCategoriesExample(
    String description,
    String examples,
  ) {
    return '$description ഉദാ. $examples.';
  }

  @override
  String get helpCallManagementText =>
      'ഫോൺ വിളിയും വിളിക്കിടയിലെ നിയന്ത്രണങ്ങളും';

  @override
  String get helpCallManagementIntro =>
      'ഒന്നിലധികം പേരുമായുള്ള നിയന്ത്രണങ്ങൾ, ഇരട്ട SIM നിയന്ത്രണം, സ്വയം വീണ്ടും വിളിക്കാനുള്ള സഹായം, വിളിക്കുന്നയാളുടെ പേര് പറയൽ എന്നിവയോടെ SreerajP Contacts Sphere ബുദ്ധിപരമായ വിളി അനുഭവം നൽകുന്നു.';

  @override
  String get helpCallManagementTitle1 =>
      'വിളിക്കിടയിലെ നിയന്ത്രണങ്ങളും കോൺഫറൻസ് വിളിയും';

  @override
  String get helpCallManagementBullet1 =>
      'നിശ്ശബ്ദം, സ്പീക്കർ: മൈക്രോഫോൺ നിശ്ശബ്ദമാക്കാൻ നിശ്ശബ്ദം തൊടുക, കൈ ഉപയോഗിക്കാതെ ഉറക്കെ കേൾക്കാൻ സ്പീക്കർ തൊടുക.';

  @override
  String get helpCallManagementBullet2 =>
      'ഹോൾഡ്, കീപാഡ്: സജീവ വിളികൾ ഹോൾഡിൽ വയ്ക്കുക, അല്ലെങ്കിൽ IVR മെനു അക്കങ്ങൾ നൽകാൻ ഡയൽപാഡ് തുറക്കുക (ഇംഗ്ലീഷിന് 1 അമർത്തുന്നതുപോലെ).';

  @override
  String get helpCallManagementBullet3 =>
      'വിളി ചേർക്കൽ, വിളി മാറ്റൽ: ആദ്യ വിളി ഹോൾഡിൽ വച്ച് രണ്ടാമതൊരാളെ ചേർക്കുക. സജീവ വിളിക്കാർക്കിടയിൽ മാറാൻ മാറ്റുക തൊടുക.';

  @override
  String get helpCallManagementBullet4 =>
      'കോൺഫറൻസ് ലയനം: രണ്ട് വിളികളും ഒരു കോൺഫറൻസ് വിളിയാക്കാൻ ലയിപ്പിക്കുക തൊടുക. നിങ്ങളുടെ നെറ്റ്‌വർക്ക് കോൺഫറൻസ് വിളി പിന്തുണയ്ക്കുമ്പോൾ മാത്രമേ ലയിപ്പിക്കുക കാണൂ. വിളിയിൽ ആരൊക്കെയുണ്ടെന്ന് കാണാനും ഒരാളെ ഒഴിവാക്കാനും ഒരാളുമായി സ്വകാര്യമായി സംസാരിക്കാനും നിയന്ത്രിക്കുക തൊടുക.';

  @override
  String get helpCallManagementTitle2 => 'സ്പീഡ് ഡയൽ';

  @override
  String get helpCallManagementBullet5 =>
      'കീപാഡിലെ 1 മുതൽ 9 വരെയുള്ള ഓരോ കീയിലും ഒരാളെ വയ്ക്കാം. അവരെ വിളിക്കാൻ ഡയലറിലെ കീ അമർത്തിപ്പിടിക്കുക.';

  @override
  String get helpCallManagementBullet6 =>
      'നമ്പർ പെട്ടി ശൂന്യമാകുമ്പോൾ മാത്രമേ അമർത്തിപ്പിടിക്കൽ പ്രവർത്തിക്കൂ, അതിനാൽ ടൈപ്പ് ചെയ്യുമ്പോഴുള്ള നീണ്ട അമർത്തൽ ഒരിക്കലും വിളി തുടങ്ങില്ല.';

  @override
  String get helpCallManagementBullet7 =>
      'ഒരു കീ സജ്ജമാക്കാൻ: ഡയലറിലെ ഒഴിഞ്ഞ കീ അമർത്തിപ്പിടിച്ച് ഒരു വിലാസവിവരം തിരഞ്ഞെടുക്കുക, അല്ലെങ്കിൽ ക്രമീകരണങ്ങൾ → സ്പീഡ് ഡയൽ എന്നതിൽ പോകുക. വിലാസവിവരത്തിന് ഒന്നിലധികം നമ്പറുണ്ടെങ്കിൽ ഏത് സൂക്ഷിക്കണമെന്ന് ചോദിക്കും.';

  @override
  String get helpCallManagementBullet8 =>
      'ഒരാളെ വച്ചിട്ടുള്ള കീയിൽ അക്കത്തിനു മുകളിൽ ഒരു ചെറിയ നിറമുള്ള കുത്ത് കാണാം.';

  @override
  String get helpCallManagementBullet9 =>
      'രഹസ്യ വിലാസവിവരങ്ങൾ കീയിൽ വയ്ക്കാനാവില്ല, കീയിലെ വിലാസവിവരം ഇല്ലാതാക്കുകയോ രഹസ്യമാക്കുകയോ ചെയ്താൽ കീ സ്വയം ഒഴിയും.';

  @override
  String get helpCallManagementTitle3 => 'ഇരട്ട SIM വിളിയും മുൻഗണനകളും';

  @override
  String get helpCallManagementBullet10 =>
      'ഇരട്ട SIM ഫോണുകളിൽ ഡയലർ ഉടനടി തിരഞ്ഞെടുക്കാൻ SIM 1, SIM 2 വിളി ബട്ടണുകൾ നൽകുന്നു.';

  @override
  String get helpCallManagementBullet11 =>
      'ക്രമീകരണങ്ങൾ → SIM-ഉം ഫോൺ വിളിയും → SIM കാർഡുകളും അക്കൗണ്ടുകളും എന്നതിൽ പുറത്തേക്കുള്ള വിളികൾക്ക് സ്ഥിര SIM സജ്ജമാക്കാം, അല്ലെങ്കിൽ ഓരോ തവണയും ചോദിക്കാൻ \"ഓരോ വിളിക്കും മുമ്പ് ചോദിക്കുക\" ഓണാക്കാം.';

  @override
  String get helpCallManagementBullet12 =>
      'ഒരാൾക്ക് സ്വന്തം SIM ആകാം: വിലാസവിവരം തുറന്ന് തിരുത്തുക തൊട്ട് \"ഇഷ്ട SIM\" എന്നതിൽ തിരഞ്ഞെടുക്കുക. പിന്നീട് അവരെ വിളിക്കുന്നത് സ്ഥിര SIM-നു പകരം ആ SIM ഉപയോഗിച്ചാകും.';

  @override
  String get helpCallManagementBullet13 =>
      '\"ഓരോ വിളിക്കും മുമ്പ് ചോദിക്കുക\" ഓണാണെങ്കിൽ അപ്പോഴും ചോദിക്കും, പക്ഷേ ആ വിളി ഉപയോഗിക്കുമായിരുന്ന SIM നേരത്തേ അടയാളമിട്ടിരിക്കും, ഒറ്റ തൊടൽ മതി.';

  @override
  String get helpCallManagementBullet14 =>
      'ആ SIM പിന്നീട് ഫോണിൽ നിന്ന് നീക്കിയാൽ, വിളികൾ നിശ്ശബ്ദമായി സ്ഥിര SIM-ലേക്ക് മാറും.';

  @override
  String get helpCallManagementBullet15 =>
      'ഇതേ സ്ക്രീൻ ഓരോ SIM-നും സ്വന്തം നിറം നൽകുന്നു, ഒരു വിളി ഏത് ലൈനിലാണെന്ന് ഒറ്റനോട്ടത്തിൽ അറിയാം.';

  @override
  String get helpCallManagementBullet16 =>
      'വരുന്നതും പോകുന്നതും നഷ്ടമായതുമായ ഓരോ വിളിക്കും ഏത് SIM ഉപയോഗിച്ചു എന്ന് സമീപകാല രേഖ കാണിക്കുന്നു.';

  @override
  String get helpCallManagementTitle4 =>
      'സ്മാർട്ട് റീഡയലും \"എന്നെ ബന്ധപ്പെടൂ\" SMS-ഉം';

  @override
  String get helpCallManagementBullet17 =>
      'പുറത്തേക്കുള്ള വിളി തിരക്കിലാകുകയോ എടുക്കാതിരിക്കുകയോ ചെയ്താൽ, അൽപ്പസമയം കഴിഞ്ഞ് നമ്പർ വീണ്ടും വിളിക്കാമെന്ന് ആപ്പ് നിർദ്ദേശിക്കും.';

  @override
  String get helpCallManagementBullet18 =>
      'പകരം, ബന്ധപ്പെടാൻ ശ്രമിച്ചു എന്ന് പറയാൻ ഒറ്റ തൊടലിൽ മുൻനിശ്ചിത \"എന്നെ ബന്ധപ്പെടൂ\" സന്ദേശം അയയ്ക്കാം.';

  @override
  String get helpCallManagementBullet19 =>
      'ക്രമീകരണങ്ങൾ → SIM-ഉം ഫോൺ വിളിയും → സ്മാർട്ട് റീഡയലും \"എന്നെ ബന്ധപ്പെടൂ\"-ഉം എന്നതിൽ സ്ഥിര കാത്തിരിപ്പ് സമയവും മുൻനിശ്ചിത സന്ദേശവും സജ്ജമാക്കാം, കാത്തിരിക്കുന്ന റീഡയലുകളുടെ പട്ടികയും കാണാം.';

  @override
  String get helpCallManagementBullet20 =>
      'നിശ്ചയിച്ച റീഡയൽ മാത്രമാണ് ആപ്പ് സ്വയം വിളിക്കുന്ന ഒരേയൊരിടം, അതും നിങ്ങൾ തന്നെ സമയം നിശ്ചയിച്ചതുകൊണ്ട് മാത്രം. കാത്തിരിക്കുന്ന റീഡയൽ അതേ പട്ടികയിൽ നിന്ന് റദ്ദാക്കാം.';

  @override
  String get helpCallManagementTitle5 => 'വിളിക്കുന്നയാളുടെ പേര് പറയൽ';

  @override
  String get helpCallManagementBullet21 =>
      'ക്രമീകരണങ്ങൾ → SIM-ഉം ഫോൺ വിളിയും → വിളിക്കുന്നയാളുടെ പേര് പറയൽ എന്നതിൽ ഓണാക്കുക. അപ്പോൾ ആപ്പ് റിംഗ്‌ടോണിനൊപ്പം വിളിക്കുന്നയാളുടെ പേര് പറയും — \"അമ്മ വിളിക്കുന്നു\".';

  @override
  String get helpCallManagementBullet22 =>
      'മലയാളം പേര് മലയാളത്തിൽ പറയും. യഥാർത്ഥ വിളി വരുംമുമ്പ് ഒരു പേര് എങ്ങനെ കേൾക്കുമെന്നറിയാൻ ആ സ്ക്രീനിലെ പരീക്ഷണ ബട്ടൺ ഉപയോഗിക്കുക.';

  @override
  String get helpCallManagementBullet23 =>
      'ഫോൺ റിംഗ് ചെയ്യുമ്പോഴും രാത്രി പേര് പറയാതിരിക്കാൻ നിശ്ശബ്ദ സമയ ഒഴിവ് ഓണാക്കി അതിന്റെ സമയപരിധി സജ്ജമാക്കുക.';

  @override
  String get helpCallManagementTitle6 => 'വേഗത്തിലുള്ള SMS നിരസിക്കൽ മറുപടികൾ';

  @override
  String get helpCallManagementBullet24 =>
      'ഇപ്പോൾ എടുക്കാനാവില്ലേ? വിളി നിരസിച്ച് മുൻനിശ്ചിത സന്ദേശം അയയ്ക്കാൻ വരുന്ന വിളി സ്ക്രീനിലെ മറുപടി തൊടുക.';

  @override
  String get helpCallManagementBullet25 =>
      'ക്രമീകരണങ്ങൾ → SIM-ഉം ഫോൺ വിളിയും → ദ്രുത മറുപടികൾ എന്നതിൽ സ്വന്തം സന്ദേശങ്ങൾ എഴുതുക.';

  @override
  String get helpCallManagementFooter =>
      'നുറുങ്ങ്: ഇതിനെ സ്ഥിര ഫോൺ ആപ്പ് ആക്കുക — ഇപ്പോൾ ആണോ എന്ന് ക്രമീകരണങ്ങൾ → അനുമതികൾ കാണിക്കും. ആ ചുമതലയില്ലെങ്കിൽ Android വിളിക്കിടയിലെ നിയന്ത്രണങ്ങളോ പൂർണ്ണ സ്ക്രീൻ വിളി അറിയിപ്പോ നൽകില്ല.';

  @override
  String get helpRelationshipCategoriesText1 => 'ബന്ധ വിഭാഗങ്ങൾ';

  @override
  String get helpRelationshipCategoriesIntro =>
      'നിങ്ങൾ സൂക്ഷിക്കുന്ന ഓരോ ബന്ധത്തിനും രണ്ട് ഭാഗങ്ങളുണ്ട്: ഒരു വിഭാഗവും ഒരു പേരും. വിഭാഗം ഏഴ് നിശ്ചിത കൂട്ടങ്ങളിലൊന്നാണ്. പേര് നിങ്ങൾ വിളിക്കാൻ ആഗ്രഹിക്കുന്നതെന്തും — \"അച്ഛൻ\", \"കസിൻ ചേട്ടൻ\", \"മാനേജർ\".';

  @override
  String get helpRelationshipCategoriesTitle1 => 'വിഭാഗങ്ങൾ എന്തിന്';

  @override
  String get helpRelationshipCategoriesBullet1 =>
      'മുമ്പ് വലയം ഓരോ വ്യത്യസ്ത പേരിനും ഓരോ ബിന്ദു വരച്ചിരുന്നു. ഇരുപതോ അതിലധികമോ ബന്ധങ്ങളായപ്പോൾ അത് ഒരു ആൾക്കൂട്ടമായി.';

  @override
  String get helpRelationshipCategoriesBullet2 =>
      'ഇപ്പോൾ വലയം പരമാവധി ഏഴ് ബിന്ദുക്കൾ വരയ്ക്കുന്നു — ഓരോ വിഭാഗത്തിനും ഒന്ന്. ബിന്ദുവിനുള്ളിലെ സംഖ്യ അതിൽ എത്ര വിലാസവിവരങ്ങളുണ്ടെന്നാണ്.';

  @override
  String get helpRelationshipCategoriesBullet3 =>
      'ഒരു ബിന്ദു തൊട്ടാൽ അതിനുള്ളിലെ എല്ലാവരെയും അവരുടെ സ്വന്തം പേരോടെ കാണാം. ഒന്നും മറയ്ക്കുന്നില്ല; കൂടുതൽ വൃത്തിയാണെന്ന് മാത്രം.';

  @override
  String get helpRelationshipCategoriesTitle2 => 'ഒരു ബന്ധം ചേർക്കൽ';

  @override
  String get helpRelationshipCategoriesBullet4 =>
      'ബന്ധിപ്പിക്കേണ്ട വിലാസവിവരം തിരഞ്ഞെടുക്കുക.';

  @override
  String get helpRelationshipCategoriesBullet5 =>
      'ഏഴ് വിഭാഗങ്ങളിലൊന്ന് തിരഞ്ഞെടുക്കുക.';

  @override
  String get helpRelationshipCategoriesBullet6 =>
      'പേര് ടൈപ്പ് ചെയ്യുക, അല്ലെങ്കിൽ നിർദ്ദേശിച്ച ചിപ്പുകളിലൊന്ന് തൊടുക. ചിപ്പുകൾ കുറുക്കുവഴികൾ മാത്രം — ഇഷ്ടമുള്ള ഏത് വാക്കും സ്വീകരിക്കും.';

  @override
  String get helpRelationshipCategoriesTitle3 => 'ഏഴ് വിഭാഗങ്ങൾ';

  @override
  String get helpRelationshipCategoriesTitle4 => 'ഇരുവശവും ഒരേ വിഭാഗം';

  @override
  String get helpRelationshipCategoriesBullet7 =>
      'ഒരു ബന്ധം രണ്ട് വിലാസവിവരങ്ങളിലും സൂക്ഷിക്കുന്നു. ഒരാളെ അച്ഛനായി സൂക്ഷിച്ചാൽ, അവരുടെ ഭാഗത്ത് നിങ്ങൾ മകനോ മകളോ ആയി കാണും.';

  @override
  String get helpRelationshipCategoriesBullet8 =>
      'മറുവശത്തും അതേ വിഭാഗം തുടരും, അതിനാൽ ഈ ജോടി രണ്ട് വലയങ്ങളിലും ഒരേ കൂട്ടത്തിലായിരിക്കും.';

  @override
  String get helpRelationshipCategoriesTitle5 => 'മുമ്പ് സൂക്ഷിച്ച ബന്ധങ്ങൾ';

  @override
  String get helpRelationshipCategoriesBullet9 =>
      'പഴയ ബന്ധങ്ങൾക്ക് വിഭാഗമില്ലായിരുന്നു. ഈ പുതുക്കലിനു ശേഷമുള്ള ആദ്യ തുടക്കത്തിൽ ഓരോന്നും അതിന്റെ പേര് അനുസരിച്ച് ക്രമീകരിക്കും — \"Father\" അടുത്ത കുടുംബത്തിലേക്ക്, \"Colleague\" തൊഴിൽപരത്തിലേക്ക്, അങ്ങനെ.';

  @override
  String get helpRelationshipCategoriesBullet10 =>
      'ആപ്പ് തിരിച്ചറിയാത്ത പേര് സാമൂഹികത്തിലേക്ക് പോകും. ഒന്നും ഇല്ലാതാക്കുന്നില്ല, ഏത് ബന്ധവും തൊട്ട് \"മാറ്റുക\" തിരഞ്ഞെടുത്ത് മറ്റൊരു വിഭാഗത്തിലേക്ക് നീക്കാം.';

  @override
  String get helpRelationshipCategoriesTitle6 =>
      'നിശ്ശബ്ദ സമയം ഈ വിഭാഗങ്ങൾ ഉപയോഗിക്കുന്നു';

  @override
  String get helpRelationshipCategoriesBullet11 =>
      'ക്രമീകരണങ്ങൾ → SIM-ഉം ഫോൺ വിളിയും → ബന്ധ-തല നിശ്ശബ്ദ സമയം നിങ്ങൾ നിശ്ചയിക്കുന്ന സമയത്തിനിടയിൽ വിളികൾ നിശ്ശബ്ദമാക്കുന്നു.';

  @override
  String get helpRelationshipCategoriesBullet12 =>
      'ഇത് അനുവദിക്കൽ പട്ടികയാണ്, തടയൽ പട്ടികയല്ല. നിങ്ങൾ ചേർക്കുന്നവർ ഒഴികെ എല്ലാവരും നിശ്ശബ്ദമാകും — നക്ഷത്രമിട്ട വിലാസവിവരങ്ങൾ, അടുത്ത കുടുംബം പോലുള്ള മുഴുവൻ വിഭാഗങ്ങൾ, ഒരു അടയാളം, അല്ലെങ്കിൽ പേരെടുത്ത വ്യക്തികൾ.';

  @override
  String get helpRelationshipCategoriesBullet13 =>
      'അതുകൊണ്ടാണ് വിഭാഗം പ്രധാനം: \"അടുത്ത കുടുംബം\" അനുവദിച്ചാൽ ഓരോരുത്തർക്കും നൽകിയ പേര് എന്തായാലും ആ കൂട്ടത്തിലെ എല്ലാവരും റിംഗ് ചെയ്യും.';

  @override
  String get helpRelationshipCategoriesFooter =>
      'നുറുങ്ങ്: ഒരാൾ എവിടെ പെടുമെന്ന് ഉറപ്പില്ലെങ്കിൽ, പിന്നീട് നിങ്ങൾ തിരയാൻ സാധ്യതയുള്ള വിഭാഗം തിരഞ്ഞെടുക്കുക. വിശദാംശം പേര് വഹിക്കും.';

  @override
  String get helpP2pSyncText => 'മറ്റൊരു ഉപകരണവുമായി സമന്വയം';

  @override
  String get helpP2pSyncIntro =>
      'ഒരേ Wi-Fi ശൃംഖല വഴി നിങ്ങളുടെ വിലാസവിവരങ്ങളും (മറ്റും) ഒരു ഫോണിൽ നിന്ന് മറ്റൊന്നിലേക്ക് പകർത്തുക. ഇന്റർനെറ്റോ ക്ലൗഡോ അക്കൗണ്ടോ ആവശ്യമില്ല — രണ്ട് ഫോണുകളും നേരിട്ട് സംസാരിക്കുന്നു. രണ്ടിലും ഈ ആപ്പ് പ്രവർത്തിക്കണം.';

  @override
  String get helpP2pSyncTitle1 => 'തുടങ്ങുംമുമ്പ്';

  @override
  String get helpP2pSyncBullet1 => 'രണ്ട് ഫോണുകളും ഒരേ Wi-Fi ശൃംഖലയിലാക്കുക.';

  @override
  String get helpP2pSyncBullet2 =>
      'രണ്ടിലും ഈ ആപ്പിന്റെ ഒരേ പതിപ്പാണെന്ന് ഉറപ്പാക്കുക. പതിപ്പുകൾ ഒത്തുപോകുന്നില്ലെങ്കിൽ സമന്വയം നിർത്തി രണ്ടും പുതുക്കാൻ ആവശ്യപ്പെടും.';

  @override
  String get helpP2pSyncBullet3 =>
      'രണ്ട് ഫോണിലും ക്രമീകരണങ്ങൾ → മറ്റൊരു ഉപകരണവുമായി സമന്വയം തുറക്കുക. സമന്വയത്തിൽ രഹസ്യ വിലാസവിവരങ്ങൾ ഉൾപ്പെടാം എന്നതിനാൽ ആദ്യം വിരലടയാളമോ മുഖമോ PIN-ഓ ചോദിക്കും.';

  @override
  String get helpP2pSyncBullet4 =>
      'അയയ്ക്കുന്ന ഫോണിൽ \"മറ്റൊരു ഉപകരണത്തിലേക്ക് അയയ്ക്കുക\" തൊടുക. സ്വീകരിക്കുന്ന ഫോണിൽ \"മറ്റൊരു ഉപകരണത്തിൽ നിന്ന് സ്വീകരിക്കുക\" തൊടുക.';

  @override
  String get helpP2pSyncTitle2 => 'രണ്ട് ഫോണുകളും എങ്ങനെ ബന്ധിക്കുന്നു';

  @override
  String get helpP2pSyncBullet5 =>
      'അയയ്ക്കുന്ന ഫോൺ ഒരു ജോടിയാക്കൽ കോഡും QR കോഡും കാണിക്കുന്നു.';

  @override
  String get helpP2pSyncBullet6 =>
      'സ്വീകരിക്കുന്ന ഫോൺ ആ QR കോഡ് സ്കാൻ ചെയ്യുന്നു, അല്ലെങ്കിൽ നിങ്ങൾ ജോടിയാക്കൽ കോഡ് കൈകൊണ്ട് ടൈപ്പ് ചെയ്യുന്നു.';

  @override
  String get helpP2pSyncBullet7 =>
      'ജോടിയാക്കൽ കോഡ് സ്ക്രീനിൽ മാത്രമേ കാണിക്കൂ — ഒരിക്കലും ശൃംഖലയിലൂടെ അയയ്ക്കുന്നില്ല. മുഴുവൻ കൈമാറ്റവും ആ കോഡ് ഉപയോഗിച്ച് എൻക്രിപ്റ്റ് ചെയ്യുന്നു, അതിനാൽ തെറ്റായ കോഡ് ഉപയോഗിച്ചാൽ ബന്ധം പരാജയപ്പെടും.';

  @override
  String get helpP2pSyncTitle3 => 'പൂർണ്ണ സമന്വയവും തിരഞ്ഞെടുത്ത സമന്വയവും';

  @override
  String get helpP2pSyncBullet8 =>
      'പൂർണ്ണ സമന്വയം താഴെയുള്ളതെല്ലാം ഒറ്റയടിക്ക് അയയ്ക്കുന്നു. അയയ്ക്കുന്നയാളുടെ ആപ്പ് ക്രമീകരണങ്ങൾ സ്വീകരിക്കുന്നയാളുടേതിന് പകരമാകും, അയയ്ക്കുന്നയാളുടെ സ്വന്തം പ്രൊഫൈൽ (\"സ്വയം\") കാർഡ് സ്വീകരിക്കുന്നയാളിൽ സാധാരണ വിലാസവിവരമായി ചേർക്കും (അത് സ്വീകരിക്കുന്നയാളുടെ സ്വന്തം പ്രൊഫൈലിന് ഒരിക്കലും പകരമാകില്ല).';

  @override
  String get helpP2pSyncBullet9 =>
      'തിരഞ്ഞെടുത്ത സമന്വയം നിങ്ങൾ തിരഞ്ഞെടുക്കുന്ന വിവര ഗണങ്ങൾ മാത്രം അയയ്ക്കുന്നു. വിലാസവിവരങ്ങൾ എപ്പോഴും ഉൾപ്പെടും. ക്രമീകരണങ്ങൾ ഒഴിഞ്ഞവ മാത്രം നിറയ്ക്കും (സ്വീകരിക്കുന്നയാൾ സജ്ജമാക്കിയത് ഒരിക്കലും മാറ്റിയെഴുതില്ല), അയയ്ക്കുന്നയാളുടെ \"സ്വയം\" കാർഡ് അയയ്ക്കില്ല.';

  @override
  String get helpP2pSyncTitle4 => 'എന്തൊക്കെ സമന്വയിക്കുന്നു';

  @override
  String get helpP2pSyncBullet10 =>
      'വിലാസവിവരങ്ങളും അവയുടെ വിശദാംശങ്ങളും: ഫോൺ നമ്പറുകൾ, ഇമെയിലുകൾ, വിലാസങ്ങൾ, ഔദ്യോഗിക വിവരങ്ങൾ, സോഷ്യൽ ലിങ്കുകൾ, അടയാളങ്ങൾ.';

  @override
  String get helpP2pSyncBullet11 =>
      'വിലാസവിവര ഫോട്ടോകളും കോളിംഗ് കാർഡ് ഫോട്ടോകളും.';

  @override
  String get helpP2pSyncBullet12 =>
      'വിളി ചരിത്രം: വിളി രേഖകൾ, ഇടപെടലുകൾ, ഓർമ്മപ്പെടുത്തലുകൾ.';

  @override
  String get helpP2pSyncBullet13 => 'ഗ്രൂപ്പുകളും അവയിലെ അംഗങ്ങളും.';

  @override
  String get helpP2pSyncBullet14 => 'വിലാസവിവരങ്ങൾ തമ്മിലുള്ള ബന്ധങ്ങൾ.';

  @override
  String get helpP2pSyncBullet15 => 'തടഞ്ഞ നമ്പറുകൾ.';

  @override
  String get helpP2pSyncBullet16 =>
      'നിങ്ങളുടെ അടിയന്തര വിവര കാർഡ് — പൂർണ്ണ സമന്വയത്തിൽ, അല്ലെങ്കിൽ പങ്കിടാനുള്ളവ തിരഞ്ഞെടുക്കുമ്പോൾ അടയാളമിട്ടാൽ. സ്വീകരിക്കുന്ന ഫോണിന് സ്വന്തം കാർഡില്ലെങ്കിൽ മാത്രമേ അത് സ്വീകരിക്കൂ, ആരുടെയും ആരോഗ്യ വിവരങ്ങൾ മാറ്റപ്പെടില്ല.';

  @override
  String get helpP2pSyncBullet17 =>
      'ഒരു പ്രത്യേക ഫോണുമായി ബന്ധമില്ലാത്ത ആപ്പ് ക്രമീകരണങ്ങൾ — തീം, ആക്സന്റ് നിറം, സ്ഥിര രാജ്യം, ദ്രുത മറുപടികൾ, വിളി കൈകാര്യ ഓപ്ഷനുകൾ എന്നിവ പോലെ.';

  @override
  String get helpP2pSyncTitle5 => 'ഒരിക്കലും സമന്വയിക്കാത്തവ';

  @override
  String get helpP2pSyncBullet18 =>
      'റിംഗ്‌ടോണുകൾ. റിംഗ്‌ടോൺ അയയ്ക്കുന്ന ഫോണിലെ ഒരു ഫയലിനെയാണ് സൂചിപ്പിക്കുന്നത്, അത് മറ്റേ ഫോണിൽ ഉണ്ടാകില്ല.';

  @override
  String get helpP2pSyncBullet19 =>
      'SIM-നുള്ള പ്രത്യേക ക്രമീകരണങ്ങൾ, സ്ഥിര SIM, ഓരോ SIM-ന്റെയും റിംഗ്‌ടോണുകളും നിറങ്ങളും പോലെ. ഇവ അയയ്ക്കുന്ന ഫോണിലെ ഭൗതിക SIM കാർഡുകളെയാണ് സൂചിപ്പിക്കുന്നത്.';

  @override
  String get helpP2pSyncTitle6 =>
      'സ്വീകരിക്കുന്ന ഫോണിൽ ഒന്നും ഇല്ലാതാക്കുന്നില്ല';

  @override
  String get helpP2pSyncBullet20 =>
      'സമന്വയം ചേർക്കുക മാത്രം ചെയ്യുന്നു. സ്വീകരിക്കുന്ന ഫോൺ അതിന്റെ എല്ലാ വിവരങ്ങളും നിലനിർത്തുന്നു — വരുന്ന വിലാസവിവരങ്ങൾ ഒന്നും മായ്ക്കുകയോ മാറ്റിയെഴുതുകയോ ഇല്ല.';

  @override
  String get helpP2pSyncBullet21 =>
      'നിങ്ങൾക്ക് നേരത്തേയുള്ള വിലാസവിവരം (ഒരേ പേരും കുറഞ്ഞത് ഒരു പൊതു ഫോൺ നമ്പറും) ഒഴിവാക്കും, ഇരട്ടിപ്പിക്കില്ല. പുതിയ വിലാസവിവരങ്ങൾ മാത്രം ചേർക്കും, അവയുടെ വിശദാംശങ്ങളും വിളി ചരിത്രവും ഒപ്പം വരും.';

  @override
  String get helpP2pSyncBullet22 =>
      'നിലവിലുള്ള വിലാസവിവരം ഒഴിവാക്കുന്നതിനാൽ അതിനുള്ള അയയ്ക്കുന്നയാളുടെ വിളി ചരിത്രം ലയിപ്പിക്കില്ല — പുതിയ വിലാസവിവരങ്ങൾ മാത്രമേ ചരിത്രം കൊണ്ടുവരൂ.';

  @override
  String get helpP2pSyncTitle7 => 'നിങ്ങളുടെ വിവരങ്ങൾ സ്വകാര്യമായി തുടരുന്നു';

  @override
  String get helpP2pSyncBullet23 =>
      'കൈമാറ്റം നിങ്ങളുടെ പ്രാദേശിക Wi-Fi-യിൽ രണ്ട് ഫോണുകൾ തമ്മിൽ നേരിട്ട് നടക്കുന്നു. ഇന്റർനെറ്റിലേക്കോ ഒരു സെർവറിലേക്കോ ഒന്നും അപ്‌ലോഡ് ചെയ്യുന്നില്ല.';

  @override
  String get helpP2pSyncBullet24 =>
      'വിവരങ്ങളിൽ രഹസ്യ വിലാസവിവരങ്ങൾ ഉൾപ്പെടാം എന്നതിനാൽ സമന്വയം തുറക്കുന്നത് ഉപകരണ പൂട്ട് കൊണ്ട് സംരക്ഷിച്ചിരിക്കുന്നു.';

  @override
  String get helpP2pSyncFooter =>
      'നുറുങ്ങ്: സമന്വയം തീരുന്നതുവരെ രണ്ട് ഫോണുകളും ഉണർന്നും ഒരേ Wi-Fi-യിലും വയ്ക്കുക.';

  @override
  String get helpFaqTroubleshootingText => 'പതിവ് ചോദ്യങ്ങളും പ്രശ്നപരിഹാരവും';

  @override
  String get helpFaqTroubleshootingIntro =>
      'അനുമതികൾ, സ്ഥിര ഡയലർ സജ്ജീകരണം, സ്വകാര്യത, സമന്വയ ഓപ്ഷനുകൾ, ContactSphere-ലെ പ്രശ്നപരിഹാര ഘട്ടങ്ങൾ എന്നിവയെക്കുറിച്ചുള്ള സാധാരണ ചോദ്യങ്ങൾക്ക് പെട്ടെന്നുള്ള ഉത്തരങ്ങൾ കണ്ടെത്തുക.';

  @override
  String get helpFaqTroubleshootingTitle1 => 'പൊതുവായവയും അനുമതികളും';

  @override
  String get helpFaqTroubleshootingQ1 =>
      'ContactSphere-ന് സ്ഥിര ഫോൺ ആപ്പ് അനുമതി എന്തിന് വേണം?';

  @override
  String get helpFaqTroubleshootingA1 =>
      'വരുന്ന വിളി അറിയിപ്പുകൾ കാണിക്കാനും കോൺഫറൻസ് ലയനം/വിളി മാറ്റൽ സാധ്യമാക്കാനും സ്പാം വിളികൾ സ്വയം പരിശോധിച്ച് തടയാനും ഒരു ആപ്പ് സ്ഥിര ഫോൺ ആപ്പായിരിക്കണമെന്ന് Android ആവശ്യപ്പെടുന്നു.';

  @override
  String get helpFaqTroubleshootingQ2 =>
      'എന്റെ വിലാസവിവരങ്ങൾ പുറത്തുള്ള സെർവറുകളിലേക്ക് അപ്‌ലോഡ് ചെയ്യുന്നുണ്ടോ?';

  @override
  String get helpFaqTroubleshootingA2 =>
      'ഇല്ല. ContactSphere ഓഫ്‌ലൈൻ-ആദ്യ രൂപകൽപ്പനയോടെ നിർമ്മിച്ചതാണ്. എല്ലാ വിലാസവിവരങ്ങളും വിളി രേഖകളും കുറിപ്പുകളും ഫോട്ടോകളും നിങ്ങളുടെ എൻക്രിപ്റ്റ് ചെയ്ത പ്രാദേശിക SQLite ഡാറ്റാബേസിലാണ്. നിങ്ങളുടെ സ്വകാര്യ Google Drive / WebDAV ക്ലൗഡ് കരുതൽശേഖരം നിങ്ങൾ വ്യക്തമായി സജ്ജമാക്കിയില്ലെങ്കിൽ ഒരു വിവരവും പുറത്തുള്ള സെർവറുകളിലേക്ക് അയയ്ക്കുന്നില്ല.';

  @override
  String get helpFaqTroubleshootingQ3 =>
      'ചില അനുമതികൾ നിർബന്ധമല്ലാത്തത് എന്തുകൊണ്ട്?';

  @override
  String get helpFaqTroubleshootingA3 =>
      'ബ്ലൂടൂത്ത് (അടുത്തുള്ളവരുമായി പങ്കിടാൻ), ക്യാമറ (QR, ബിസിനസ് കാർഡ് സ്കാനിംഗിന്), മൈക്രോഫോൺ (വിളി കുറിപ്പുകൾ പറഞ്ഞുകൊടുക്കാൻ) പോലുള്ള അനുമതികൾ ആ സവിശേഷത ആദ്യം ഉപയോഗിക്കുമ്പോൾ മാത്രമേ ചോദിക്കൂ. ഒന്ന് നിരസിച്ചാൽ ആ സവിശേഷത മാത്രം പ്രവർത്തിക്കാതാകും. പൂർണ്ണ പട്ടികയ്ക്ക് \"അനുമതികൾ വിശദമായി\" ഗൈഡ് കാണുക.';

  @override
  String get helpFaqTroubleshootingTitle2 => 'ഡയലറും ഫോൺ വിളിയും';

  @override
  String get helpFaqTroubleshootingQ4 =>
      'T9-ൽ മലയാളം അല്ലെങ്കിൽ ദേവനാഗരി പേരുകൾ എങ്ങനെ തിരയാം?';

  @override
  String get helpFaqTroubleshootingA4 =>
      'വ്യഞ്ജന ഗണത്തിന്റെ കീകൾ അമർത്തുക, അല്ലെങ്കിൽ പേര് ഇംഗ്ലീഷിൽ കേൾക്കുന്നതുപോലെ ടൈപ്പ് ചെയ്യുക (2-6-4-5 ടൈപ്പ് ചെയ്താൽ \"Anil\"-ഉം \"അനിൽ\"-ഉം കിട്ടും). കീപാഡ് കാണിക്കുന്ന ലിപി മാറ്റാൻ പ്രധാന ക്രമീകരണ പേജിലെ \"ഡയൽപാഡ് ലിപി\" കാർഡ് ഉപയോഗിക്കുക.';

  @override
  String get helpFaqTroubleshootingQ5 =>
      'ഏത് SIM-ൽ നിന്ന് വിളിക്കണമെന്ന് എങ്ങനെ തിരഞ്ഞെടുക്കാം?';

  @override
  String get helpFaqTroubleshootingA5 =>
      'ഇരട്ട SIM ഫോണുകളിൽ ഡയലർ SIM 1, SIM 2 എന്നിങ്ങനെ വേറിട്ട വിളി ബട്ടണുകൾ നൽകുന്നു. ഓരോ തവണയും തിരഞ്ഞെടുക്കേണ്ടെങ്കിൽ ക്രമീകരണങ്ങൾ → SIM-ഉം ഫോൺ വിളിയും → SIM കാർഡുകളും അക്കൗണ്ടുകളും എന്നതിൽ സ്ഥിര SIM സജ്ജമാക്കുക, അല്ലെങ്കിൽ അവിടെ \"ഓരോ വിളിക്കും മുമ്പ് ചോദിക്കുക\" ഓണാക്കുക.';

  @override
  String get helpFaqTroubleshootingQ6 =>
      'നിശ്ശബ്ദ സമയത്ത് ഒരു വിളി റിംഗ് ചെയ്യാത്തത് എന്തുകൊണ്ട്?';

  @override
  String get helpFaqTroubleshootingA6 =>
      'നിശ്ശബ്ദ സമയം നിങ്ങൾ അനുവദിക്കുന്നവരൊഴികെ എല്ലാം നിശ്ശബ്ദമാക്കുന്നു. ക്രമീകരണങ്ങൾ → SIM-ഉം ഫോൺ വിളിയും → ബന്ധ-തല നിശ്ശബ്ദ സമയം തുറന്ന് എത്തിച്ചേരേണ്ടവരെ ചേർക്കുക — നക്ഷത്രമിട്ട വിലാസവിവരങ്ങൾ, മുഴുവൻ ബന്ധ വിഭാഗങ്ങൾ, ഒരു അടയാളം, അല്ലെങ്കിൽ പേരെടുത്ത വ്യക്തികൾ. ആ പട്ടികയിലില്ലാത്തവർ നിശ്ശബ്ദ സമയം തീരുന്നതുവരെ നിശ്ശബ്ദമാകും.';

  @override
  String get helpFaqTroubleshootingTitle3 => 'സമന്വയം, ക്ലൗഡ്, കരുതൽശേഖരം';

  @override
  String get helpFaqTroubleshootingQ7 =>
      'പ്രാദേശിക Wi-Fi സമന്വയവും ക്ലൗഡ് സമന്വയവും തമ്മിലുള്ള വ്യത്യാസം എന്ത്?';

  @override
  String get helpFaqTroubleshootingA7 =>
      'പ്രാദേശിക Wi-Fi സമന്വയം ഇന്റർനെറ്റോ അക്കൗണ്ടോ ഇല്ലാതെ ഒരേ ശൃംഖലയിലുള്ള ഒരു ഫോണിൽ നിന്ന് മറ്റൊന്നിലേക്ക് നേരിട്ട് വിവരങ്ങൾ പകർത്തുന്നു. ഓൺലൈൻ സമന്വയവും ക്ലൗഡ് കരുതൽശേഖരവും നിങ്ങൾ തന്നെ ചേർക്കുന്ന അക്കൗണ്ടുകൾ ഉപയോഗിക്കുന്നു — Google, Microsoft, അല്ലെങ്കിൽ CardDAV/WebDAV സെർവർ — ഒന്ന് സജ്ജമാക്കുന്നതുവരെ അവ ഓഫാണ്.';

  @override
  String get helpFaqTroubleshootingQ8 =>
      'കരുതൽശേഖര പാസ്‌വേഡ് മറന്നാൽ എന്ത് സംഭവിക്കും?';

  @override
  String get helpFaqTroubleshootingA8 =>
      'കരുതൽശേഖര ഫയൽ നിങ്ങൾ തിരഞ്ഞെടുത്ത പാസ്‌വേഡ് കൊണ്ട് എൻക്രിപ്റ്റ് ചെയ്തതാണ്, ആപ്പ് അത് ഒരിക്കലും സൂക്ഷിക്കുന്നില്ല. ചോദിക്കാൻ ഒരു സെർവറുമില്ല, അതിനാൽ പാസ്‌വേഡ് നഷ്ടപ്പെട്ടാൽ ഫയൽ തുറക്കാനാവില്ല. ആവശ്യം വരുംമുമ്പ് അത് സുരക്ഷിതമായ ഇടത്ത് എഴുതിവയ്ക്കുക.';

  @override
  String get helpFaqTroubleshootingQ9 =>
      'ഫോൺ വിലാസവിവരങ്ങളുമായുള്ള സമന്വയം എന്തെങ്കിലും ഇല്ലാതാക്കുമോ?';

  @override
  String get helpFaqTroubleshootingA9 =>
      'സാധാരണ സമന്വയം പുതിയതും പുതുക്കിയതുമായ വിലാസവിവരങ്ങൾ സുരക്ഷിതമായി ലയിപ്പിക്കുന്നു. മായ്ക്കലോടെയുള്ള / ഒരുപോലെയാക്കൽ സമന്വയം ഏതെങ്കിലും വിലാസവിവരം മാറ്റിസ്ഥാപിക്കുകയോ നീക്കുകയോ ചെയ്യുംമുമ്പ് വ്യക്തമായി മുന്നറിയിപ്പ് നൽകും.';

  @override
  String get helpFaqTroubleshootingTitle4 =>
      'സ്വകാര്യതയും രഹസ്യ വിലാസവിവരങ്ങളും';

  @override
  String get helpFaqTroubleshootingQ10 =>
      'ബയോമെട്രിക് തുറക്കൽ പരാജയപ്പെട്ടാൽ പ്രവേശനം എങ്ങനെ വീണ്ടെടുക്കാം?';

  @override
  String get helpFaqTroubleshootingA10 =>
      'ഫോണിന്റെ സ്വന്തം തുറക്കൽ സ്ക്രീൻ നിങ്ങളുടെ സ്ക്രീൻ പൂട്ട് PIN, പാറ്റേൺ, അല്ലെങ്കിൽ പാസ്‌വേഡിലേക്ക് മാറും. പകരം ആപ്പ് PIN ഉപയോഗിക്കുകയും അത് മറക്കുകയും ചെയ്തെങ്കിൽ, ലോക്ക് സ്ക്രീനിൽ \"PIN മറന്നോ?\" തൊട്ട് സജ്ജമാക്കിയപ്പോൾ കിട്ടിയ വീണ്ടെടുക്കൽ കോഡ് നൽകുക.';

  @override
  String get helpFaqTroubleshootingQ11 =>
      'ആപ്പുകൾ മാറുമ്പോൾ സ്ക്രീൻ കറുത്തുപോകുന്നത് എന്തുകൊണ്ട്?';

  @override
  String get helpFaqTroubleshootingA11 =>
      'സ്ക്രീൻഷോട്ട് സംരക്ഷണം സ്വകാര്യ ദൃശ്യങ്ങൾ Android-ന്റെ സമീപകാല ആപ്പുകളുടെ ദൃശ്യത്തിലോ പശ്ചാത്തല റെക്കോർഡിംഗ് ഉപകരണങ്ങളാലോ പകർത്തപ്പെടാതെ സംരക്ഷിക്കുന്നു.';

  @override
  String get helpFaqTroubleshootingTitle5 => 'പ്രശ്നപരിഹാരവും പരിപാലനവും';

  @override
  String get helpFaqTroubleshootingQ12 =>
      'തിരയൽ മന്ദഗതിയിലാണ് അല്ലെങ്കിൽ പുതിയ വിലാസവിവരങ്ങൾ കിട്ടുന്നില്ല. എങ്ങനെ ശരിയാക്കാം?';

  @override
  String get helpFaqTroubleshootingA12 =>
      'ക്രമീകരണങ്ങൾ → വിലാസവിവരങ്ങൾ → വിലാസവിവരങ്ങളുടെ എണ്ണവും തിരയൽ സൂചികയും തുറക്കുക. ഏതെങ്കിലും വിലാസവിവരത്തിന് പഴകിയ തിരയൽ കീകളുണ്ടെങ്കിൽ പുനർനിർമ്മിക്കുക ബട്ടൺ വരും — അത് തൊട്ടാൽ ഏതാനും സെക്കൻഡിനുള്ളിൽ കീകൾ വീണ്ടും ഉണ്ടാക്കും.';

  @override
  String get helpFaqTroubleshootingQ13 =>
      'തടഞ്ഞ നമ്പർ അപ്പോഴും സമീപകാല രേഖയിൽ കാണുന്നു. അത് റിംഗ് ചെയ്യുന്നുണ്ടോ?';

  @override
  String get helpFaqTroubleshootingA13 =>
      'ഇല്ല. തടഞ്ഞ വിളി ഫോൺ റിംഗ് ചെയ്യുംമുമ്പ് നിരസിക്കും, പക്ഷേ ആരോ ശ്രമിച്ചു എന്ന് കാണാൻ \"തടഞ്ഞു\" എന്ന അടയാളത്തോടെ സമീപകാല രേഖയിൽ എഴുതും. വിളി കാണണം, ശല്യം മാത്രം വേണ്ട എന്നാണെങ്കിൽ തടയുന്നതിനു പകരം \"സംശയമുള്ള സ്പാം അരിക്കുക\" ഉപയോഗിക്കുക.';

  @override
  String get helpFaqTroubleshootingQ14 =>
      'ഒരു വിലാസവിവരം സ്വയം അപ്രത്യക്ഷമായി. എന്തുകൊണ്ട്?';

  @override
  String get helpFaqTroubleshootingA14 =>
      'അത് ഒരുപക്ഷേ ക്ഷണിക (താൽക്കാലിക) വിലാസവിവരമായി സൂക്ഷിച്ചതായിരിക്കും, അത് 2 മണിക്കൂർ, 24 മണിക്കൂർ, 7 ദിവസം, അല്ലെങ്കിൽ ഒരു വിളിക്ക് ശേഷം സ്വയം ഇല്ലാതാകും. അത്തരം വിലാസവിവരം തുറന്നാൽ \"എന്നേക്കുമായി സൂക്ഷിക്കുക\" ബട്ടണോടെ സമയമെണ്ണുന്ന ബാനർ കാണാം.';

  @override
  String get helpFaqTroubleshootingQ15 => 'ഗ്രൂപ്പുകളും അടയാളങ്ങളും എവിടെ?';

  @override
  String get helpFaqTroubleshootingA15 =>
      'ഗ്രൂപ്പുകൾ വിലാസവിവരങ്ങൾ ടാബിന്റെ മുകളിലെ ബാറിലെ ഗ്രൂപ്പ് ചിഹ്നത്തിന് പിന്നിലാണ്. അടയാളങ്ങൾക്ക് ആപ്പിന്റെ താഴെ സ്വന്തം ടാബുണ്ട്, കൂടുതൽ പേർ ഉപയോഗിക്കുന്ന അടയാളം വലുതായി കാണുന്ന ഒരു മേഘമായി.';

  @override
  String get helpFaqTroubleshootingQ16 =>
      'ഇരട്ട വിലാസവിവരങ്ങൾ എങ്ങനെ വൃത്തിയാക്കാം?';

  @override
  String get helpFaqTroubleshootingA16 =>
      'വിലാസവിവരങ്ങൾ ടാബ് തുറന്ന് മൂന്ന് കുത്ത് മെനു തൊട്ട് \"ഇരട്ടിപ്പുകൾ കണ്ടെത്തുക\" തിരഞ്ഞെടുക്കുക. ഫോൺ നമ്പറും പേരും (ലിപ്യന്തരണം ചെയ്ത പേരുകൾ ഉൾപ്പെടെ) അനുസരിച്ചാണ് ഒത്തുനോക്കുന്നത്. ഓരോ കൂട്ടവും പരിശോധിച്ച് ലയിപ്പിക്കുക, അല്ലെങ്കിൽ \"എല്ലാ കൂട്ടങ്ങളും ലയിപ്പിക്കുക\" ഉപയോഗിക്കുക.';

  @override
  String get helpFaqTroubleshootingFooter =>
      'ഇപ്പോഴും കുടുങ്ങിയോ? സഹായത്തിലെ അനുയോജ്യമായ ഗൈഡ് തുറക്കുക, അല്ലെങ്കിൽ ആ സവിശേഷതയ്ക്ക് ഒരു അനുമതി കുറവുണ്ടോ എന്ന് ക്രമീകരണങ്ങൾ → അനുമതികൾ എന്നതിൽ നോക്കുക.';

  @override
  String get aboutDetailAuthor => 'രചയിതാവ്';

  @override
  String get aboutDetailEmail => 'ഇമെയിൽ';

  @override
  String get aboutDetailLicense => 'അനുമതിപത്രം';

  @override
  String get aboutDetailAiUsed => 'ഉപയോഗിച്ച AI';

  @override
  String get aboutDetailIdeUsed => 'ഉപയോഗിച്ച IDE';

  @override
  String get labelVersion => 'പതിപ്പ്';

  @override
  String get labelBuildDate => 'നിർമ്മാണ തീയതി';

  @override
  String labelVersionBuild(String version, String build) {
    return '$version (ബിൽഡ് $build)';
  }

  @override
  String get tabDetails => 'വിവരങ്ങൾ';

  @override
  String get tabHistory => 'ചരിത്രം';

  @override
  String get tabAddContact => 'വിലാസവിവരം ചേർക്കുക';

  @override
  String get emptyNoCallsWithContact =>
      'ഈ വിലാസവിവരവുമായി ഇതുവരെ ഫോൺ വിളികളൊന്നുമില്ല.';

  @override
  String get emptyNoCallsWithNumber =>
      'ഈ നമ്പറുമായി ഇതുവരെ ഫോൺ വിളികളൊന്നുമില്ല.';

  @override
  String get tooltipCheckAgain => 'വീണ്ടും പരിശോധിക്കുക';

  @override
  String get tooltipCreateGroup => 'ഗ്രൂപ്പ് സൃഷ്ടിക്കുക';

  @override
  String get tooltipCentreSphere => 'ഇവിടെ കേന്ദ്രീകരിക്കുക';

  @override
  String get tooltipOpenProfile => 'പ്രൊഫൈൽ തുറക്കുക';

  @override
  String get tooltipCancelRedial => 'വീണ്ടും വിളി റദ്ദാക്കുക';

  @override
  String get tooltipScanAgain => 'വീണ്ടും തിരയുക';

  @override
  String get tooltipShowPassword => 'പാസ്‌വേഡ് കാണിക്കുക';

  @override
  String get tooltipHidePassword => 'പാസ്‌വേഡ് മറയ്ക്കുക';

  @override
  String get tooltipRemoveAccount => 'അക്കൗണ്ട് നീക്കുക';
}
