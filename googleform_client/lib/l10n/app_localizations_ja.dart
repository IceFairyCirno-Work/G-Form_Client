// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Form';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get discard => '破棄';

  @override
  String get continueAction => '続行';

  @override
  String get done => '完了';

  @override
  String get remove => '削除';

  @override
  String get add => '追加';

  @override
  String get settings => '設定';

  @override
  String get close => '閉じる';

  @override
  String get untitled => '無題';

  @override
  String get open => '開く';

  @override
  String get change => '変更';

  @override
  String get export => 'エクスポート';

  @override
  String get publish => '公開';

  @override
  String get unlink => 'リンク解除';

  @override
  String get duplicate => 'コピーを作成';

  @override
  String get rename => '名前を変更';

  @override
  String get renameForm => '名前を変更';

  @override
  String get enterNewName => '新しい名前を入力';

  @override
  String get documentName => 'ドキュメント名';

  @override
  String get formRenamed => '名前を変更しました';

  @override
  String get failedToRename => '名前を変更できませんでした';

  @override
  String get required => '必須';

  @override
  String get optional => '任意';

  @override
  String get other => 'その他';

  @override
  String get description => '説明';

  @override
  String get question => '質問';

  @override
  String get columns => '列';

  @override
  String get rows => '行';

  @override
  String get image => '画像';

  @override
  String get video => '動画';

  @override
  String get owner => 'オーナー';

  @override
  String get loginSubtitle => '外出先でもフォームを作成・管理';

  @override
  String get signInWithGoogle => 'Google でログイン';

  @override
  String get signInFailed => 'ログインに失敗しました。もう一度お試しください。';

  @override
  String get tabMyForms => 'マイフォーム';

  @override
  String get tabTemplates => 'テンプレート';

  @override
  String get searchForms => 'フォームを検索';

  @override
  String get searchTemplates => 'テンプレートを検索';

  @override
  String get recentForms => '最近使用したフォーム';

  @override
  String get noRecentForms => '最近のアイテムはありません';

  @override
  String noFormsMatching(String query) {
    return '「$query」に一致するフォームはありません';
  }

  @override
  String get tryDifferentSearch => '別の検索語をお試しください';

  @override
  String noTemplatesMatching(String query) {
    return '「$query」に一致するテンプレートはありません';
  }

  @override
  String get tryDifferentSearchOrCategory => '別の検索語またはカテゴリをお試しください';

  @override
  String get thisIsTheEnd => '-これ以上ありません-';

  @override
  String get linkCopiedToClipboard => 'リンクをクリップボードにコピーしました';

  @override
  String get deleteFormTitle => 'ゴミ箱に移動しますか？';

  @override
  String get deleteFormContent => 'ゴミ箱に移動されます。';

  @override
  String get formMovedToTrash => 'ゴミ箱に移動しました';

  @override
  String get failedToDeleteForm => 'フォームを削除できませんでした';

  @override
  String get duplicatingForm => 'コピーを作成しています…';

  @override
  String get formDuplicated => 'コピーを作成しました';

  @override
  String get failedToDuplicateForm => 'コピーを作成できませんでした';

  @override
  String get templateComingSoon => 'テンプレートは近日公開！';

  @override
  String get loadingTemplate => 'テンプレートを読み込んでいます…';

  @override
  String get failedToLoadTemplate => 'テンプレートを読み込めませんでした。もう一度お試しください。';

  @override
  String get soon => '近日公開';

  @override
  String templateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'テンプレート $count 件',
      one: 'テンプレート 1 件',
    );
    return '$_temp0';
  }

  @override
  String get ownedByAnyone => 'オーナー指定なし';

  @override
  String get ownedByMe => '自分がオーナー';

  @override
  String get notOwnedByMe => '自分以外がオーナー';

  @override
  String get lastModified => '最終更新';

  @override
  String get lastOpened => '最終閲覧(自分)';

  @override
  String get titleAZ => 'タイトル';

  @override
  String get copyLink => 'リンクをコピー';

  @override
  String get categoryAll => 'すべて';

  @override
  String get categoryWork => '仕事';

  @override
  String get categoryEducation => '教育';

  @override
  String get categoryCommunity => 'コミュニティ';

  @override
  String get categoryHealth => '健康とウェルネス';

  @override
  String get tplPrayerRequestSafety => '安全と保護の祈り';

  @override
  String get tplPrayerRequestSafetyDesc => '安全と保護の祈りのリクエストを提出';

  @override
  String get tplWorkshopEvaluation => 'ワークショップ評価';

  @override
  String get tplWorkshopEvaluationDesc => 'ワークショップの効果を評価';

  @override
  String get tplSoccerTryoutEvaluation => 'サッカー選考評価';

  @override
  String get tplSoccerTryoutEvaluationDesc => 'サッカー選考のパフォーマンスを評価';

  @override
  String get tplOralPresentationEvaluation => '口頭発表評価フォーム';

  @override
  String get tplOralPresentationEvaluationDesc => '口頭発表スキルを評価';

  @override
  String get tplPeerFeedback => 'ピアフィードバックフォーム';

  @override
  String get tplPeerFeedbackDesc => 'ピアにフィードバックを提供';

  @override
  String get tplPresentationFeedback => 'プレゼンテーションフィードバック';

  @override
  String get tplPresentationFeedbackDesc => 'プレゼンテーションにフィードバックを提供';

  @override
  String get tplPatientFeedback => '患者フィードバックフォーム';

  @override
  String get tplPatientFeedbackDesc => 'ケアに対する患者のフィードバックを収集';

  @override
  String get tplChildcareRegistration => '保育登録フォーム';

  @override
  String get tplChildcareRegistrationDesc => '保育サービスに子供を登録';

  @override
  String get tplMedicationOrder => '薬剤注文フォーム';

  @override
  String get tplMedicationOrderDesc => '薬剤の注文を提出';

  @override
  String get tplTeamworkCollaborationEvaluation => 'チームワーク・コラボレーション評価';

  @override
  String get tplTeamworkCollaborationEvaluationDesc => 'チームコラボレーションスキルを評価';

  @override
  String get tplTrainingDevelopmentFeedback => '研修・開発フィードバックフォーム';

  @override
  String get tplTrainingDevelopmentFeedbackDesc => '研修プログラムにフィードバックを提供';

  @override
  String get tplAnnualEmployeePerformanceReview => '年次従業員パフォーマンスレビュー';

  @override
  String get tplAnnualEmployeePerformanceReviewDesc => '従業員の年次パフォーマンスをレビュー';

  @override
  String get useThisTemplate => 'このテンプレートを使用';

  @override
  String get failedToCopyTemplate => 'テンプレートをコピーできませんでした。もう一度お試しください。';

  @override
  String get untitledForm => '無題のフォーム';

  @override
  String sectionTitleOf(int n, int total) {
    return 'セクション $n / $total';
  }

  @override
  String get sectionTitle => 'セクションのタイトル';

  @override
  String get shortAnswerText => '記述式の回答';

  @override
  String get longAnswerText => '段落の回答';

  @override
  String get imageTitleOptional => '画像のタイトル（任意）';

  @override
  String get videoTitle => '動画のタイトル';

  @override
  String optionLabel(int n) {
    return '選択肢 $n';
  }

  @override
  String get youTubeVideo => 'YouTube 動画';

  @override
  String get dateFormatWithYear => 'MM/DD/YYYY';

  @override
  String get dateFormatNoYear => 'MM/DD';

  @override
  String get timeFormatDuration => 'HH:MM:SS';

  @override
  String get timeFormatStandard => 'HH:MM';

  @override
  String get googleAccount => 'Google アカウント';

  @override
  String get signOut => 'ログアウト';

  @override
  String get signOutTitle => 'ログアウトしますか？';

  @override
  String get signOutContent => 'アカウントからログアウトしてもよろしいですか？';

  @override
  String get goPremium => 'プレミアムにアップグレード';

  @override
  String get goPremiumDesc => 'すべての機能を解除し、広告を削除';

  @override
  String get about => '情報';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfUse => '利用規約';

  @override
  String get version => 'バージョン 1.0.0';

  @override
  String get language => '言語';

  @override
  String get languageSystemDefault => 'システムのデフォルト';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get tabEdit => '編集';

  @override
  String get tabPreview => 'プレビュー';

  @override
  String get tabResponses => '回答';

  @override
  String get tabSettings => '設定';

  @override
  String get qTypeMultipleChoice => 'ラジオボタン';

  @override
  String get qTypeCheckboxes => 'チェックボックス';

  @override
  String get qTypeShortAnswer => '記述式(短文)';

  @override
  String get qTypeParagraph => '段落';

  @override
  String get qTypeDropdown => 'プルダウン';

  @override
  String get qTypeImage => '画像';

  @override
  String get qTypeVideo => '動画';

  @override
  String get qTypeLinearScale => '均等目盛';

  @override
  String get qTypeMultipleChoiceGrid => '選択式(グリッド)';

  @override
  String get qTypeCheckboxGrid => 'チェックボックス (グリッド)';

  @override
  String get qTypeDate => '日付';

  @override
  String get qTypeTime => '時刻';

  @override
  String get qTypeInfo => '見出し';

  @override
  String get qTypeSection => 'セクション';

  @override
  String get qTypeTitleDescription => 'タイトルと説明';

  @override
  String get addQuestion => '質問を追加';

  @override
  String get addImage => '画像を追加';

  @override
  String get addVideo => '動画を追加';

  @override
  String get addInfo => '見出しを追加';

  @override
  String get addSection => 'セクションを追加';

  @override
  String get addYouTubeVideo => 'YouTube 動画を追加';

  @override
  String get pasteYouTubeUrl => 'YouTube の URL を貼り付け';

  @override
  String get clickToUploadImage => 'クリックして画像をアップロード';

  @override
  String get pasteYouTubeVideoUrl => 'YouTube 動画の URL を貼り付け';

  @override
  String get saving => '保存中…';

  @override
  String get formSaved => 'フォームを保存しました！リンクをクリップボードにコピーしました。';

  @override
  String formSavedWithWarnings(String warnings) {
    return 'フォームを保存しました！リンクをコピーしました。$warnings';
  }

  @override
  String get failedToSaveForm => 'フォームを保存できませんでした。';

  @override
  String get failedToLoadForm => 'フォームを読み込めませんでした。';

  @override
  String get saveToPreview => '保存してプレビュー';

  @override
  String get saveForm => 'フォームを保存';

  @override
  String get saveTheFormFirst => 'リンクを取得するには、まずフォームを保存してください';

  @override
  String get saveBeforePublishing => '公開する前にフォームを保存してください。';

  @override
  String get unsavedChanges => '未保存の変更';

  @override
  String get unsavedChangesBackDesc => '未保存の変更があります。終了する前に保存しますか？';

  @override
  String get unsavedChangesPreviewDesc => '最新のプレビューを表示するには、フォームを保存してください。';

  @override
  String get dontSave => '保存しない';

  @override
  String get untitledQuestion => '無題の質問';

  @override
  String get formTitle => 'フォームのタイトル';

  @override
  String get formDescription => 'フォームの説明';

  @override
  String get addOption => '選択肢を追加';

  @override
  String columnN(int n) {
    return '列 $n';
  }

  @override
  String rowN(int n) {
    return '行 $n';
  }

  @override
  String get addColumn => '列を追加';

  @override
  String get addRow => '行を追加';

  @override
  String get minValue => '最小値';

  @override
  String get maxValue => '最大値';

  @override
  String get labelOptional => 'ラベル（任意）';

  @override
  String get showDescription => '説明を表示';

  @override
  String get includeYear => '年を含める';

  @override
  String get duration => '所要時間';

  @override
  String get tooltipDragToReorder => 'ドラッグして並べ替え';

  @override
  String get tooltipCopyLink => 'リンクをコピー';

  @override
  String get tooltipPublished => '公開済み';

  @override
  String get tooltipPublish => '公開';

  @override
  String get tooltipSave => '保存';

  @override
  String get tooltipDuplicate => 'コピーを作成';

  @override
  String get tooltipDelete => '削除';

  @override
  String get tooltipMoreOptions => 'その他のオプション';

  @override
  String get tooltipAddImageToQuestion => '質問に画像を追加';

  @override
  String get tooltipExportXlsx => '.xlsx としてエクスポート';

  @override
  String get tooltipExportCsv => '.csv としてエクスポート';

  @override
  String get tooltipOpenLinkedSheet => 'リンクされた Google スプレッドシートを開く';

  @override
  String get tooltipLinkToSheet => 'Google スプレッドシートにリンク';

  @override
  String get tooltipRemoveEditor => '編集者を削除';

  @override
  String get noPreviewAvailable => 'プレビューは利用できません';

  @override
  String get noPreviewDesc => '回答者に表示される内容をプレビューするには、まずフォームを保存してください。';

  @override
  String get saveYourFormFirst => 'まずフォームを保存してください';

  @override
  String get needSaveForResponses => '回答を表示するには、まずフォームを保存する必要があります。';

  @override
  String get noResponsesYet => '回答はまだありません';

  @override
  String get noResponsesDesc => 'フォームが送信されると、ここに回答が表示されます。';

  @override
  String get shareThisForm => 'このフォームを共有';

  @override
  String get responseSubSummary => '概要';

  @override
  String get responseSubQuestion => '質問';

  @override
  String get responseSubIndividual => '個別';

  @override
  String nResponses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '回答 $count 件',
      one: '回答 1 件',
    );
    return '$_temp0';
  }

  @override
  String get noAnswersYet => '回答はまだありません。';

  @override
  String get noGridData => 'グリッドデータがありません。';

  @override
  String andNMore(int n) {
    return '…他 $n 件';
  }

  @override
  String get noQuestionsFound => '質問が見つかりません。';

  @override
  String get questionLabel => '質問：';

  @override
  String questionN(int n) {
    return '質問 $n';
  }

  @override
  String get noResponses => '回答がありません。';

  @override
  String responseNOfTotal(int n, int total) {
    return '$n / $total';
  }

  @override
  String submittedTime(String time) {
    return '送信日時：$time';
  }

  @override
  String responseN(int n) {
    return '回答 $n';
  }

  @override
  String get noAnswer => '未回答';

  @override
  String get couldNotOpenYouTube => 'YouTube を開けませんでした。';

  @override
  String exportAs(String format) {
    return '$format としてエクスポート';
  }

  @override
  String get enterFileName => 'エクスポートするファイル名を入力：';

  @override
  String get fileName => 'ファイル名';

  @override
  String exportFailed(String error) {
    return 'エクスポートに失敗しました：$error';
  }

  @override
  String get responseId => '回答 ID';

  @override
  String get createTime => '作成日時';

  @override
  String get lastSubmittedTime => '最終送信日時';

  @override
  String get responsesSheet => '回答';

  @override
  String get exportXlsx => 'XLSX';

  @override
  String get exportCsv => 'CSV';

  @override
  String get sheets => 'Sheets';

  @override
  String get linkedToSheet => 'スプレッドシートにリンク済み';

  @override
  String get responsesAutoSaved => '回答はこのスプレッドシートに自動保存されます：';

  @override
  String get linkedSpreadsheet => 'リンクされたスプレッドシート';

  @override
  String get tapToOpenInBrowser => 'タップしてブラウザで開く';

  @override
  String get openSheet => 'シートを開く';

  @override
  String get linkToGoogleSheet => 'Google スプレッドシートにリンク';

  @override
  String get linkSheetDesc =>
      'フォームの回答はこのスプレッドシートに自動保存されます。すべての回答を含む新しいシートが作成されます。';

  @override
  String get createAndLink => '作成してリンク';

  @override
  String get spreadsheetName => 'スプレッドシート名';

  @override
  String get unlinkSheetTitle => 'シートのリンクを解除しますか？';

  @override
  String get unlinkSheetDesc =>
      '新しいフォームの回答はこのスプレッドシートに保存されなくなります。既存の回答は削除されません。';

  @override
  String get sheetUnlinked => 'シートのリンクを解除しました。';

  @override
  String get failedToCreateSheet => 'スプレッドシートを作成できませんでした。もう一度お試しください。';

  @override
  String formLinkedToSheet(String name) {
    return 'フォームを「$name」にリンクしました！';
  }

  @override
  String failedToLink(String error) {
    return 'リンクに失敗しました：$error';
  }

  @override
  String failedToUnlink(String error) {
    return 'リンク解除に失敗しました：$error';
  }

  @override
  String errorWithMessage(String message) {
    return 'エラー：$message';
  }

  @override
  String get publishRequired => '公開が必要です';

  @override
  String get publishRequiredDesc => '回答を受け付けるには、このフォームを公開する必要があります。今すぐ公開しますか？';

  @override
  String get formPublished => 'フォームを公開し、回答を受け付けています！';

  @override
  String failedToPublish(String error) {
    return '公開に失敗しました：$error';
  }

  @override
  String get formUnpublished => 'フォームの公開を停止しました';

  @override
  String get formIsPublished => 'フォームは公開中です';

  @override
  String get copyFormLink => '回答者へのリンクをコピー';

  @override
  String get unpublishForm => 'フォームの公開を停止';

  @override
  String get unpublishFormDesc => 'フォームは回答を受け付けなくなります';

  @override
  String get settingsResponses => '回答';

  @override
  String get settingsPresentation => '表示設定';

  @override
  String get settingsEditors => '編集者';

  @override
  String get acceptResponses => '回答を受け付ける';

  @override
  String get acceptResponsesEnabled => 'このフォームに回答を送信できます';

  @override
  String get acceptResponsesDisabled => 'このフォームは回答を受け付けていません';

  @override
  String get collectEmail => 'メールアドレスを収集';

  @override
  String get collectEmailDesc => '回答者のメールアドレスの収集方法を選択';

  @override
  String get dontCollect => '収集しない';

  @override
  String get verified => '確認済み';

  @override
  String get responderInput => '回答者の入力';

  @override
  String get limitToOneResponse => '回答を 1 回に制限';

  @override
  String get limitToOneResponseDesc => '回答者のログインが必要';

  @override
  String get editAfterSubmit => '送信後に編集';

  @override
  String get editAfterSubmitDesc => '回答者が送信後に回答を編集できるようにする';

  @override
  String get showProgressBar => 'プログレスバーを表示';

  @override
  String get showProgressBarDesc => 'フォームの下部にプログレスバーを表示';

  @override
  String get shuffleQuestionOrder => '質問の順序をシャッフルする';

  @override
  String get shuffleQuestionOrderDesc => '回答者ごとに質問の順序が異なります';

  @override
  String get confirmationMessage => '確認メッセージ';

  @override
  String get confirmationMessageDesc => 'フォーム送信後に表示されるメッセージ';

  @override
  String get enterConfirmationMessage => '確認メッセージを入力';

  @override
  String get defaultConfirmationMessage => '回答を記録しました。';

  @override
  String get addEditor => '編集者を追加';

  @override
  String get gmailAddress => 'Gmail アドレス';

  @override
  String get gmailHint => 'name@gmail.com';

  @override
  String get enterGmail => 'Gmail アドレスを入力してください。';

  @override
  String get enterValidEmail => '有効なメールアドレスを入力してください。';

  @override
  String get removeEditorTitle => '編集者を削除しますか？';

  @override
  String removeEditorDesc(String name) {
    return '$name をこのフォームから削除しますか？編集できなくなります。';
  }

  @override
  String get alreadyOwner => 'あなたはすでにこのフォームのオーナーです。';

  @override
  String get alreadyOwnerOther => 'このユーザーはすでにこのフォームのオーナーです。';

  @override
  String get alreadyEditor => 'このユーザーはすでにこのフォームの編集者です。';

  @override
  String get failedToAddEditor => '編集者を追加できませんでした。';

  @override
  String addedEditor(String email) {
    return '$email を編集者として追加しました。';
  }

  @override
  String get cannotRemoveOwner => 'オーナーは削除できません。';

  @override
  String get failedToRemoveEditor => '編集者を削除できませんでした。';

  @override
  String removedEditor(String name) {
    return '$name を削除しました。';
  }

  @override
  String get noOwnerFound => 'このフォームの共同編集者が見つかりません。';

  @override
  String get noEditorsYet => '編集者はまだいません。+追加 をタップして Gmail で招待してください。';

  @override
  String get noEditorsOnForm => 'このフォームに編集者はいません。';

  @override
  String get failedToLoadEditors => '編集者を読み込めませんでした。';

  @override
  String get saveChangesTitle => '変更を保存しますか？';

  @override
  String breakingChangesDesc(String desc) {
    return 'この変更は既存の回答に影響します：$desc。\n\n続行しますか？';
  }

  @override
  String get duplicateChoicesError => 'ラジオボタンの質問に重複した選択肢を設定することはできません。';

  @override
  String get invalidDataError => '無効なデータです。フォームを確認してもう一度お試しください。';

  @override
  String get permissionDeniedError => '権限が拒否されました。Google アカウントのアクセスを確認してください。';

  @override
  String get addAtLeastOneQuestion => '保存する前に、少なくとも 1 つの質問を追加してください。';

  @override
  String get failedToUpdateForm => 'フォームを更新できませんでした。';

  @override
  String get failedToLoadCurrentForm => '現在のフォームデータを読み込めませんでした。もう一度お試しください。';

  @override
  String couldNotLoadSettings(String error) {
    return 'フォーム設定を読み込めませんでした：$error';
  }

  @override
  String get linkCopiedToClipboardExclaim => 'リンクをクリップボードにコピーしました！';

  @override
  String get userFallback => 'ユーザー';

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
  String get noInternetConnection => 'インターネットに接続されていません';

  @override
  String get noInternetConnectionDesc => 'ネットワーク設定を確認して、もう一度お試しください。';

  @override
  String get noInternetSaveError => 'インターネットに接続されていません。フォームを保存できません。';

  @override
  String get noInternetLoadError => 'インターネットに接続されていません。フォームを読み込めません。';

  @override
  String get retry => '再試行';

  @override
  String get formNoLongerExists => 'このフォームは存在しないか、削除されました。';

  @override
  String get failedToPickImage => '画像を選択できませんでした。もう一度お試しください。';

  @override
  String get failedToShareFile => 'ファイルを共有できませんでした。';
}
