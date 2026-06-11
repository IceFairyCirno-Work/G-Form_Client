// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Form';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранять';

  @override
  String get delete => 'Удалить';

  @override
  String get discard => 'Отказаться';

  @override
  String get continueAction => 'Продолжать';

  @override
  String get done => 'Сделанный';

  @override
  String get remove => 'Удалять';

  @override
  String get add => 'Добавлять';

  @override
  String get settings => 'Настройки';

  @override
  String get close => 'Закрывать';

  @override
  String get untitled => 'Без названия';

  @override
  String get open => 'Открыть';

  @override
  String get change => 'Изменять';

  @override
  String get export => 'Экспорт';

  @override
  String get publish => 'Публиковать';

  @override
  String get unlink => 'Отсоединить';

  @override
  String get duplicate => 'Создать копию';

  @override
  String get rename => 'Переименовать';

  @override
  String get renameForm => 'Переименовать';

  @override
  String get enterNewName => 'Введите новое имя';

  @override
  String get documentName => 'Название документа';

  @override
  String get formRenamed => 'Переименовано';

  @override
  String get failedToRename => 'Не удалось переименовать';

  @override
  String get required => 'Необходимый';

  @override
  String get optional => 'Необязательный';

  @override
  String get other => 'Другой';

  @override
  String get description => 'Описание';

  @override
  String get question => 'Вопрос';

  @override
  String get columns => 'Столбцы';

  @override
  String get rows => 'Строки';

  @override
  String get image => 'Изображение';

  @override
  String get video => 'Видео';

  @override
  String get owner => 'Владелец';

  @override
  String get loginSubtitle => 'Создавайте формы и управляйте ими на ходу';

  @override
  String get signInWithGoogle => 'Войти через Google';

  @override
  String get signInFailed =>
      'Войти не удалось. Пожалуйста, попробуйте еще раз.';

  @override
  String get tabMyForms => 'Мои формы';

  @override
  String get tabTemplates => 'Галерея шаблонов';

  @override
  String get searchForms => 'Поиск по вашим формам';

  @override
  String get searchTemplates => 'Шаблоны поиска';

  @override
  String get recentForms => 'Недавние формы';

  @override
  String get noRecentForms => 'Нет недавних элементов';

  @override
  String noFormsMatching(String query) {
    return 'Нет форм, соответствующих \"$query\".';
  }

  @override
  String get tryDifferentSearch => 'Попробуйте другой поисковый запрос';

  @override
  String noTemplatesMatching(String query) {
    return 'Нет шаблонов, соответствующих \"$query\".';
  }

  @override
  String get tryDifferentSearchOrCategory =>
      'Попробуйте другой поисковый запрос или категорию';

  @override
  String get thisIsTheEnd => '-Это конец-';

  @override
  String get linkCopiedToClipboard => 'Ссылка скопирована в буфер обмена';

  @override
  String get deleteFormTitle => 'Переместить в корзину?';

  @override
  String get deleteFormContent => 'Форма будет перемещена в корзину.';

  @override
  String get formMovedToTrash => 'Перемещено в корзину';

  @override
  String get failedToDeleteForm => 'Не удалось удалить форму';

  @override
  String get duplicatingForm => 'Создание копии…';

  @override
  String get formDuplicated => 'Копия создана';

  @override
  String get failedToDuplicateForm => 'Не удалось создать копию';

  @override
  String get templateComingSoon => 'Шаблон скоро появится!';

  @override
  String get loadingTemplate => 'Загрузка шаблона...';

  @override
  String get failedToLoadTemplate =>
      'Не удалось загрузить шаблон. Пожалуйста, попробуйте еще раз.';

  @override
  String get soon => 'Скоро';

  @override
  String templateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count шаблонов',
      one: '1 шаблон',
    );
    return '$_temp0';
  }

  @override
  String get ownedByAnyone => 'Принадлежит кому-либо';

  @override
  String get ownedByMe => 'Принадлежит мне';

  @override
  String get notOwnedByMe => 'Не принадлежит мне';

  @override
  String get lastModified => 'Последнее изменение';

  @override
  String get lastOpened => 'Последнее открытие мной';

  @override
  String get titleAZ => 'Название';

  @override
  String get copyLink => 'Копировать ссылку';

  @override
  String get categoryAll => 'Все';

  @override
  String get categoryWork => 'Работа';

  @override
  String get categoryEducation => 'Образование';

  @override
  String get categoryCommunity => 'Сообщество';

  @override
  String get categoryHealth => 'Здоровье и благополучие';

  @override
  String get tplPrayerRequestSafety =>
      'Молитвенная просьба о безопасности и защите';

  @override
  String get tplPrayerRequestSafetyDesc =>
      'Отправляйте молитвенные просьбы о безопасности и защите';

  @override
  String get tplWorkshopEvaluation => 'Оценка семинара';

  @override
  String get tplWorkshopEvaluationDesc => 'Оцените эффективность семинара';

  @override
  String get tplSoccerTryoutEvaluation => 'Оценка футбольных проб';

  @override
  String get tplSoccerTryoutEvaluationDesc =>
      'Оценить результаты футбольных проб';

  @override
  String get tplOralPresentationEvaluation => 'Форма оценки устной презентации';

  @override
  String get tplOralPresentationEvaluationDesc =>
      'Оценить навыки устной презентации.';

  @override
  String get tplPeerFeedback => 'Форма обратной связи с коллегами';

  @override
  String get tplPeerFeedbackDesc => 'Предоставляйте обратную связь коллегам';

  @override
  String get tplPresentationFeedback => 'Обратная связь по презентации';

  @override
  String get tplPresentationFeedbackDesc => 'Оставляйте отзывы о презентациях';

  @override
  String get tplPatientFeedback => 'Форма обратной связи с пациентом';

  @override
  String get tplPatientFeedbackDesc => 'Собирайте отзывы пациентов об уходе';

  @override
  String get tplChildcareRegistration =>
      'Регистрационная форма по уходу за детьми';

  @override
  String get tplChildcareRegistrationDesc =>
      'Записать детей на услуги по уходу за детьми';

  @override
  String get tplMedicationOrder => 'Форма заказа лекарств';

  @override
  String get tplMedicationOrderDesc => 'Отправьте заказ на лекарства';

  @override
  String get tplTeamworkCollaborationEvaluation =>
      'Оценка командной работы и сотрудничества';

  @override
  String get tplTeamworkCollaborationEvaluationDesc =>
      'Оцените навыки совместной работы в команде';

  @override
  String get tplTrainingDevelopmentFeedback =>
      'Форма обратной связи по обучению и развитию';

  @override
  String get tplTrainingDevelopmentFeedbackDesc =>
      'Оставить отзыв о программах обучения';

  @override
  String get tplAnnualEmployeePerformanceReview =>
      'Ежегодный обзор эффективности работы сотрудников';

  @override
  String get tplAnnualEmployeePerformanceReviewDesc =>
      'Ежегодно анализируйте эффективность работы сотрудников';

  @override
  String get useThisTemplate => 'Используйте этот шаблон';

  @override
  String get failedToCopyTemplate =>
      'Не удалось скопировать шаблон. Пожалуйста, попробуйте еще раз.';

  @override
  String get untitledForm => 'Форма без названия';

  @override
  String sectionTitleOf(int n, int total) {
    return 'Раздел $n из $total';
  }

  @override
  String get sectionTitle => 'Название раздела';

  @override
  String get shortAnswerText => 'Краткий текст ответа';

  @override
  String get longAnswerText => 'Длинный текст ответа';

  @override
  String get imageTitleOptional => 'Название изображения (необязательно)';

  @override
  String get videoTitle => 'Название видео';

  @override
  String optionLabel(int n) {
    return 'Опция $n';
  }

  @override
  String get youTubeVideo => 'видео на YouTube';

  @override
  String get dateFormatWithYear => 'MM/DD/YYYY';

  @override
  String get dateFormatNoYear => 'MM/DD';

  @override
  String get timeFormatDuration => 'HH:MM:SS';

  @override
  String get timeFormatStandard => 'HH:MM';

  @override
  String get googleAccount => 'Аккаунт Google';

  @override
  String get signOut => 'выход';

  @override
  String get signOutTitle => 'Выход?';

  @override
  String get signOutContent =>
      'Вы уверены, что хотите выйти из своей учетной записи?';

  @override
  String get goPremium => 'Перейти Премиум';

  @override
  String get goPremiumDesc => 'Разблокируйте все функции и удалите рекламу';

  @override
  String get about => 'О';

  @override
  String get privacyPolicy => 'политика конфиденциальности';

  @override
  String get termsOfUse => 'Условия эксплуатации';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get language => 'Язык';

  @override
  String get languageSystemDefault => 'Система по умолчанию';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get tabEdit => 'Вопросы';

  @override
  String get tabPreview => 'Предварительный просмотр';

  @override
  String get tabResponses => 'Ответы';

  @override
  String get tabSettings => 'Настройки';

  @override
  String get qTypeMultipleChoice => 'Один из списка';

  @override
  String get qTypeCheckboxes => 'Несколько из списка';

  @override
  String get qTypeShortAnswer => 'Текст (строка)';

  @override
  String get qTypeParagraph => 'Текст (абзац)';

  @override
  String get qTypeDropdown => 'Падать';

  @override
  String get qTypeImage => 'Изображение';

  @override
  String get qTypeVideo => 'Видео';

  @override
  String get qTypeLinearScale => 'Линейный масштаб';

  @override
  String get qTypeMultipleChoiceGrid => 'Сетка (множественный выбор)';

  @override
  String get qTypeCheckboxGrid => 'Сетка флажков';

  @override
  String get qTypeDate => 'Дата';

  @override
  String get qTypeTime => 'Время';

  @override
  String get qTypeInfo => 'Информация';

  @override
  String get qTypeSection => 'Раздел';

  @override
  String get qTypeTitleDescription => 'название и описание';

  @override
  String get addQuestion => 'Добавить вопрос';

  @override
  String get addImage => 'Добавить изображение';

  @override
  String get addVideo => 'Добавить видео';

  @override
  String get addInfo => 'Добавить информацию';

  @override
  String get addSection => 'Добавить раздел';

  @override
  String get addYouTubeVideo => 'Добавить видео с YouTube';

  @override
  String get pasteYouTubeUrl => 'Вставьте ссылку YouTube';

  @override
  String get clickToUploadImage => 'Нажмите, чтобы загрузить изображение';

  @override
  String get pasteYouTubeVideoUrl => 'Вставить ссылку YouTube';

  @override
  String get saving => 'Сохранение...';

  @override
  String get formSaved => 'Форма сохранена! Ссылка скопирована в буфер обмена.';

  @override
  String formSavedWithWarnings(String warnings) {
    return 'Форма сохранена! Ссылка скопирована. $warnings';
  }

  @override
  String get failedToSaveForm => 'Не удалось сохранить форму.';

  @override
  String get failedToLoadForm => 'Не удалось загрузить форму.';

  @override
  String get saveToPreview => 'Сохранить для предварительного просмотра';

  @override
  String get saveForm => 'Сохранить форму';

  @override
  String get saveTheFormFirst =>
      'Сначала сохраните форму, чтобы получить ссылку';

  @override
  String get saveBeforePublishing =>
      'Пожалуйста, сохраните форму перед публикацией.';

  @override
  String get unsavedChanges => 'Несохраненные изменения';

  @override
  String get unsavedChangesBackDesc =>
      'У вас есть несохраненные изменения. Хотите сохраниться перед отъездом?';

  @override
  String get unsavedChangesPreviewDesc =>
      'Сохраните форму, чтобы увидеть последний предварительный просмотр ваших изменений.';

  @override
  String get dontSave => 'Не сохранять';

  @override
  String get untitledQuestion => 'Безымянный вопрос';

  @override
  String get formTitle => 'Название формы';

  @override
  String get formDescription => 'Описание формы';

  @override
  String get addOption => 'Добавить вариант';

  @override
  String columnN(int n) {
    return 'Столбец $n';
  }

  @override
  String rowN(int n) {
    return 'Строка $n';
  }

  @override
  String get addColumn => 'Добавить столбец';

  @override
  String get addRow => 'Добавить строку';

  @override
  String get minValue => 'Мин. значение';

  @override
  String get maxValue => 'Макс. значение';

  @override
  String get labelOptional => 'Подпись (неobяз.)';

  @override
  String get showDescription => 'Показать описание';

  @override
  String get includeYear => 'Включить год';

  @override
  String get duration => 'Продолжительность';

  @override
  String get tooltipDragToReorder =>
      'Перетащите, чтобы изменить порядок вопросов';

  @override
  String get tooltipCopyLink => 'Копировать ссылку';

  @override
  String get tooltipPublished => 'Опубликовано';

  @override
  String get tooltipPublish => 'Публиковать';

  @override
  String get tooltipSave => 'Сохранять';

  @override
  String get tooltipDuplicate => 'Создать копию';

  @override
  String get tooltipDelete => 'Удалить';

  @override
  String get tooltipMoreOptions => 'Больше возможностей';

  @override
  String get tooltipAddImageToQuestion => 'Добавить изображение к вопросу';

  @override
  String get tooltipExportXlsx => 'Экспортировать как .xlsx';

  @override
  String get tooltipExportCsv => 'Экспортировать в формате .csv';

  @override
  String get tooltipOpenLinkedSheet => 'Открыть связанный Google Sheet';

  @override
  String get tooltipLinkToSheet => 'Ссылка на Google Таблицу';

  @override
  String get tooltipRemoveEditor => 'Удалить редактор';

  @override
  String get noPreviewAvailable => 'Предварительный просмотр недоступен';

  @override
  String get noPreviewDesc =>
      'Сначала сохраните форму, чтобы в реальном времени увидеть, как она выглядит для респондентов.';

  @override
  String get saveYourFormFirst => 'Сначала сохраните форму';

  @override
  String get needSaveForResponses =>
      'Вам необходимо сохранить форму, прежде чем вы сможете просмотреть ответы.';

  @override
  String get noResponsesYet => 'Пока нет ответов';

  @override
  String get noResponsesDesc =>
      'Ответы появятся здесь, как только люди отправят вашу форму.';

  @override
  String get shareThisForm => 'Поделиться этой формой';

  @override
  String get responseSubSummary => 'Краткое содержание';

  @override
  String get responseSubQuestion => 'Вопрос';

  @override
  String get responseSubIndividual => 'Индивидуальный';

  @override
  String nResponses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ответов',
      one: '1 ответ',
    );
    return '$_temp0';
  }

  @override
  String get noAnswersYet => 'Ответов пока нет.';

  @override
  String get noGridData => 'Нет данных сетки.';

  @override
  String andNMore(int n) {
    return '... и еще $n';
  }

  @override
  String get noQuestionsFound => 'Вопросов не найдено.';

  @override
  String get questionLabel => 'Вопрос:';

  @override
  String questionN(int n) {
    return 'Вопрос $n';
  }

  @override
  String get noResponses => 'Никаких ответов.';

  @override
  String responseNOfTotal(int n, int total) {
    return '$n из $total';
  }

  @override
  String submittedTime(String time) {
    return 'Отправлено: $time';
  }

  @override
  String responseN(int n) {
    return 'Ответ $n';
  }

  @override
  String get noAnswer => 'Нет ответа';

  @override
  String get couldNotOpenYouTube => 'Не удалось открыть YouTube.';

  @override
  String exportAs(String format) {
    return 'Экспортировать как $format';
  }

  @override
  String get enterFileName => 'Введите имя файла для экспорта:';

  @override
  String get fileName => 'Имя файла';

  @override
  String exportFailed(String error) {
    return 'Не удалось экспортировать: $error';
  }

  @override
  String get responseId => 'Идентификатор ответа';

  @override
  String get createTime => 'Создать время';

  @override
  String get lastSubmittedTime => 'Время последней отправки';

  @override
  String get responsesSheet => 'Ответы';

  @override
  String get exportXlsx => 'XLSX';

  @override
  String get exportCsv => 'CSV';

  @override
  String get sheets => 'Sheets';

  @override
  String get linkedToSheet => 'Связано с листом';

  @override
  String get responsesAutoSaved =>
      'Ответы автоматически сохраняются в эту таблицу:';

  @override
  String get linkedSpreadsheet => 'Связанная таблица';

  @override
  String get tapToOpenInBrowser => 'Нажмите, чтобы открыть в браузере';

  @override
  String get openSheet => 'Открыть лист';

  @override
  String get linkToGoogleSheet => 'Ссылка на Google Таблицу';

  @override
  String get linkSheetDesc =>
      'Ответы формы будут автоматически сохранены в этой таблице. Будет создана новая вкладка листа со всеми ответами.';

  @override
  String get createAndLink => 'Создать и связать';

  @override
  String get spreadsheetName => 'Имя таблицы';

  @override
  String get unlinkSheetTitle => 'Отменить связь с листом?';

  @override
  String get unlinkSheetDesc =>
      'Новые ответы в форме больше не будут сохраняться в этой таблице. Существующие ответы на листе не будут удалены.';

  @override
  String get sheetUnlinked => 'Связь с листом успешно отменена.';

  @override
  String get failedToCreateSheet =>
      'Не удалось создать таблицу. Пожалуйста, попробуйте еще раз.';

  @override
  String formLinkedToSheet(String name) {
    return 'Форма, связанная с «$name», успешно!';
  }

  @override
  String failedToLink(String error) {
    return 'Не удалось установить связь: $error.';
  }

  @override
  String failedToUnlink(String error) {
    return 'Не удалось отменить связь: $error';
  }

  @override
  String errorWithMessage(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get publishRequired => 'Требуется публикация';

  @override
  String get publishRequiredDesc =>
      'Вам необходимо опубликовать эту форму, прежде чем она сможет принимать ответы. Хотите опубликовать это сейчас?';

  @override
  String get formPublished => 'Форма опубликована и принимается ответы!';

  @override
  String failedToPublish(String error) {
    return 'Не удалось опубликовать: $error.';
  }

  @override
  String get formUnpublished => 'Форма не опубликована';

  @override
  String get formIsPublished => 'Форма опубликована';

  @override
  String get copyFormLink => 'Скопировать ссылку на форму';

  @override
  String get unpublishForm => 'Отменить публикацию формы';

  @override
  String get unpublishFormDesc => 'Форма перестанет принимать ответы';

  @override
  String get settingsResponses => 'Ответы';

  @override
  String get settingsPresentation => 'Презентация';

  @override
  String get settingsEditors => 'Редакторы';

  @override
  String get acceptResponses => 'Принять ответы';

  @override
  String get acceptResponsesEnabled =>
      'Люди могут отправлять ответы в эту форму';

  @override
  String get acceptResponsesDisabled => 'Эта форма не принимает ответы';

  @override
  String get collectEmail => 'Соберите адреса электронной почты';

  @override
  String get collectEmailDesc =>
      'Выберите, как собирать электронные письма ответчиков';

  @override
  String get dontCollect => 'Не собирать';

  @override
  String get verified => 'Проверено';

  @override
  String get responderInput => 'Ввод ответчика';

  @override
  String get limitToOneResponse => 'Ограничить до 1 ответа';

  @override
  String get limitToOneResponseDesc =>
      'Требует от респондентов входа в систему';

  @override
  String get editAfterSubmit => 'Редактировать после отправки';

  @override
  String get editAfterSubmitDesc =>
      'Разрешить респондентам редактировать свой ответ после отправки';

  @override
  String get showProgressBar => 'Показать индикатор выполнения';

  @override
  String get showProgressBarDesc =>
      'Показывает индикатор выполнения внизу формы.';

  @override
  String get shuffleQuestionOrder => 'Перемешать порядок вопросов';

  @override
  String get shuffleQuestionOrderDesc =>
      'Вопросы будут появляться в разном порядке для каждого отвечающего.';

  @override
  String get confirmationMessage => 'Подтверждающее сообщение';

  @override
  String get confirmationMessageDesc =>
      'Сообщение, отображаемое после отправки формы';

  @override
  String get enterConfirmationMessage => 'Введите подтверждающее сообщение';

  @override
  String get defaultConfirmationMessage => 'Ваш ответ учтен.';

  @override
  String get addEditor => 'Добавить редактор';

  @override
  String get gmailAddress => 'адрес Gmail';

  @override
  String get gmailHint => 'name@gmail.com';

  @override
  String get enterGmail => 'Пожалуйста, введите адрес Gmail.';

  @override
  String get enterValidEmail =>
      'Пожалуйста, введите действительный адрес электронной почты.';

  @override
  String get removeEditorTitle => 'Удалить редактор?';

  @override
  String removeEditorDesc(String name) {
    return 'Удалить $name из этой формы? Они больше не смогут его редактировать.';
  }

  @override
  String get alreadyOwner => 'Вы уже являетесь владельцем этой формы.';

  @override
  String get alreadyOwnerOther =>
      'Этот пользователь уже является владельцем этой формы.';

  @override
  String get alreadyEditor =>
      'Этот пользователь уже является редактором этой формы.';

  @override
  String get failedToAddEditor => 'Не удалось добавить редактор.';

  @override
  String addedEditor(String email) {
    return 'Добавлен $email в качестве редактора.';
  }

  @override
  String get cannotRemoveOwner => 'Владельца удалить невозможно.';

  @override
  String get failedToRemoveEditor => 'Не удалось удалить редактор.';

  @override
  String removedEditor(String name) {
    return 'Удален $name.';
  }

  @override
  String get noOwnerFound => 'Соавторы для этой формы не найдены.';

  @override
  String get noEditorsYet =>
      'Редакторов пока нет. Нажмите +Добавить, чтобы пригласить кого-нибудь через Gmail.';

  @override
  String get noEditorsOnForm => 'В этой форме нет редакторов.';

  @override
  String get failedToLoadEditors => 'Не удалось загрузить редакторы.';

  @override
  String get saveChangesTitle => 'Сохранить изменения?';

  @override
  String breakingChangesDesc(String desc) {
    return 'Это изменение повлияет на существующие ответы: $desc.\n\nВы хотите продолжить?';
  }

  @override
  String get duplicateChoicesError =>
      'В вопросе с несколькими вариантами ответов не может быть дублирования ответов.';

  @override
  String get invalidDataError =>
      'Неверные данные. Пожалуйста, проверьте свою форму и повторите попытку.';

  @override
  String get permissionDeniedError =>
      'Доступ запрещен. Пожалуйста, проверьте доступ к своей учетной записи Google.';

  @override
  String get addAtLeastOneQuestion =>
      'Прежде чем сохранить, добавьте хотя бы один вопрос.';

  @override
  String get failedToUpdateForm => 'Не удалось обновить форму.';

  @override
  String get failedToLoadCurrentForm =>
      'Не удалось загрузить текущие данные формы. Пожалуйста, попробуйте еще раз.';

  @override
  String couldNotLoadSettings(String error) {
    return 'Не удалось загрузить настройки формы: $error.';
  }

  @override
  String get linkCopiedToClipboardExclaim =>
      'Ссылка скопирована в буфер обмена!';

  @override
  String get userFallback => 'Пользователь';

  @override
  String get languagePortugueseBrazil => 'Português (Brasil)';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageFrench => 'Français';

  @override
  String get noInternetConnection => 'Нет подключения к интернету';

  @override
  String get noInternetConnectionDesc =>
      'Пожалуйста, проверьте настройки сети и попробуйте снова.';

  @override
  String get noInternetSaveError =>
      'Нет подключения к интернету. Невозможно сохранить форму.';

  @override
  String get noInternetLoadError =>
      'Нет подключения к интернету. Невозможно загрузить форму.';

  @override
  String get retry => 'Повторить';

  @override
  String get formNoLongerExists =>
      'Эта форма больше не существует или была удалена.';

  @override
  String get failedToPickImage =>
      'Не удалось выбрать изображение. Пожалуйста, попробуйте еще раз.';

  @override
  String get failedToShareFile => 'Не удалось поделиться файлом.';
}
