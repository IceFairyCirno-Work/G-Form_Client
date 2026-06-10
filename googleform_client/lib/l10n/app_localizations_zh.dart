// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Form';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get discard => '舍弃';

  @override
  String get continueAction => '继续';

  @override
  String get done => '完成';

  @override
  String get remove => '移除';

  @override
  String get add => '添加';

  @override
  String get settings => '设置';

  @override
  String get close => '关闭';

  @override
  String get untitled => '未命名';

  @override
  String get open => '打开';

  @override
  String get change => '更改';

  @override
  String get export => '导出';

  @override
  String get publish => '发布';

  @override
  String get unlink => '取消关联';

  @override
  String get duplicate => '复制';

  @override
  String get rename => '重命名';

  @override
  String get renameForm => '重命名表单';

  @override
  String get enterNewName => '输入新名称';

  @override
  String get documentName => '文档名称';

  @override
  String get formRenamed => '表单已重命名';

  @override
  String get failedToRename => '重命名表单失败';

  @override
  String get required => '必填';

  @override
  String get optional => '选填';

  @override
  String get other => '其他';

  @override
  String get description => '说明';

  @override
  String get question => '问题';

  @override
  String get columns => '列';

  @override
  String get rows => '行';

  @override
  String get image => '图片';

  @override
  String get video => '视频';

  @override
  String get owner => '所有者';

  @override
  String get loginSubtitle => '随时随地创建和管理表单';

  @override
  String get signInWithGoogle => '使用 Google 账号登录';

  @override
  String get signInFailed => '登录失败，请重试。';

  @override
  String get tabMyForms => '我的表单';

  @override
  String get tabTemplates => '模板';

  @override
  String get searchForms => '搜索您的表单';

  @override
  String get searchTemplates => '搜索模板';

  @override
  String get recentForms => '最近的表单';

  @override
  String get noRecentForms => '没有最近的表单';

  @override
  String noFormsMatching(String query) {
    return '没有符合「$query」的表单';
  }

  @override
  String get tryDifferentSearch => '尝试其他搜索词';

  @override
  String noTemplatesMatching(String query) {
    return '没有符合「$query」的模板';
  }

  @override
  String get tryDifferentSearchOrCategory => '尝试其他搜索词或类别';

  @override
  String get thisIsTheEnd => '-已经到底了-';

  @override
  String get linkCopiedToClipboard => '链接已复制到剪贴板';

  @override
  String get deleteFormTitle => '删除表单？';

  @override
  String get deleteFormContent => '此表单将移至回收站。';

  @override
  String get formMovedToTrash => '表单已移至回收站';

  @override
  String get failedToDeleteForm => '无法删除表单';

  @override
  String get duplicatingForm => '正在复制表单…';

  @override
  String get formDuplicated => '表单已复制！';

  @override
  String get failedToDuplicateForm => '无法复制表单';

  @override
  String get templateComingSoon => '模板即将推出！';

  @override
  String get loadingTemplate => '正在加载模板…';

  @override
  String get failedToLoadTemplate => '无法加载模板，请重试。';

  @override
  String get soon => '即将推出';

  @override
  String templateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个模板',
      one: '1 个模板',
    );
    return '$_temp0';
  }

  @override
  String get ownedByAnyone => '任何人拥有';

  @override
  String get ownedByMe => '我拥有的';

  @override
  String get notOwnedByMe => '非我拥有的';

  @override
  String get lastModified => '最近修改';

  @override
  String get lastOpened => '最近打开';

  @override
  String get titleAZ => '标题 (A–Z)';

  @override
  String get copyLink => '复制链接';

  @override
  String get categoryAll => '全部';

  @override
  String get categoryWork => '工作';

  @override
  String get categoryEducation => '教育';

  @override
  String get categoryCommunity => '社区';

  @override
  String get categoryHealth => '健康与养生';

  @override
  String get tplPrayerRequestSafety => '安全与保护祷告请求';

  @override
  String get tplPrayerRequestSafetyDesc => '提交安全与保护的祷告请求';

  @override
  String get tplWorkshopEvaluation => '工作坊评估';

  @override
  String get tplWorkshopEvaluationDesc => '评估工作坊的效果';

  @override
  String get tplSoccerTryoutEvaluation => '足球选拔评估';

  @override
  String get tplSoccerTryoutEvaluationDesc => '评估足球选拔表现';

  @override
  String get tplOralPresentationEvaluation => '口头演讲评估表';

  @override
  String get tplOralPresentationEvaluationDesc => '评估口头演讲技巧';

  @override
  String get tplPeerFeedback => '同伴反馈表';

  @override
  String get tplPeerFeedbackDesc => '向同伴提供反馈';

  @override
  String get tplPresentationFeedback => '演讲反馈';

  @override
  String get tplPresentationFeedbackDesc => '对演讲提供反馈';

  @override
  String get tplPatientFeedback => '患者反馈表';

  @override
  String get tplPatientFeedbackDesc => '收集患者对护理的反馈';

  @override
  String get tplChildcareRegistration => '托儿登记表';

  @override
  String get tplChildcareRegistrationDesc => '为孩子登记托儿服务';

  @override
  String get tplMedicationOrder => '药物订购表';

  @override
  String get tplMedicationOrderDesc => '提交药物订单';

  @override
  String get tplTeamworkCollaborationEvaluation => '团队合作与协作评估';

  @override
  String get tplTeamworkCollaborationEvaluationDesc => '评估团队协作能力';

  @override
  String get tplTrainingDevelopmentFeedback => '培训与发展反馈表';

  @override
  String get tplTrainingDevelopmentFeedbackDesc => '对培训项目提供反馈';

  @override
  String get tplAnnualEmployeePerformanceReview => '年度员工绩效评估';

  @override
  String get tplAnnualEmployeePerformanceReviewDesc => '年度员工绩效回顾';

  @override
  String get useThisTemplate => '使用此模板';

  @override
  String get failedToCopyTemplate => '无法复制模板，请重试。';

  @override
  String get untitledForm => '未命名表单';

  @override
  String sectionTitleOf(int n, int total) {
    return '第 $n 小节，共 $total 小节';
  }

  @override
  String get sectionTitle => '小节标题';

  @override
  String get shortAnswerText => '简短回答文字';

  @override
  String get longAnswerText => '长段回答文字';

  @override
  String get imageTitleOptional => '图片标题（选填）';

  @override
  String get videoTitle => '视频标题';

  @override
  String optionLabel(int n) {
    return '选项 $n';
  }

  @override
  String get youTubeVideo => 'YouTube 视频';

  @override
  String get dateFormatWithYear => 'MM/DD/YYYY';

  @override
  String get dateFormatNoYear => 'MM/DD';

  @override
  String get timeFormatDuration => 'HH:MM:SS';

  @override
  String get timeFormatStandard => 'HH:MM';

  @override
  String get googleAccount => 'Google 账号';

  @override
  String get signOut => '退出登录';

  @override
  String get signOutTitle => '退出登录？';

  @override
  String get signOutContent => '确定要退出您的账号吗？';

  @override
  String get goPremium => '升级高级版';

  @override
  String get goPremiumDesc => '解锁所有功能并移除广告';

  @override
  String get about => '关于';

  @override
  String get privacyPolicy => '隐私权政策';

  @override
  String get termsOfUse => '使用条款';

  @override
  String get version => '版本 1.0.0';

  @override
  String get language => '语言';

  @override
  String get languageSystemDefault => '跟随系统';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get tabEdit => '编辑';

  @override
  String get tabPreview => '预览';

  @override
  String get tabResponses => '回复';

  @override
  String get tabSettings => '设置';

  @override
  String get qTypeMultipleChoice => '单选题';

  @override
  String get qTypeCheckboxes => '多选题';

  @override
  String get qTypeShortAnswer => '简短回答';

  @override
  String get qTypeParagraph => '段落';

  @override
  String get qTypeDropdown => '下拉列表';

  @override
  String get qTypeImage => '图片';

  @override
  String get qTypeVideo => '视频';

  @override
  String get qTypeLinearScale => '线性量表';

  @override
  String get qTypeMultipleChoiceGrid => '单选网格';

  @override
  String get qTypeCheckboxGrid => '多选网格';

  @override
  String get qTypeDate => '日期';

  @override
  String get qTypeTime => '时间';

  @override
  String get qTypeInfo => '标题';

  @override
  String get qTypeSection => '小节';

  @override
  String get qTypeTitleDescription => '标题和说明';

  @override
  String get addQuestion => '添加问题';

  @override
  String get addImage => '添加图片';

  @override
  String get addVideo => '添加视频';

  @override
  String get addInfo => '添加标题';

  @override
  String get addSection => '添加小节';

  @override
  String get addYouTubeVideo => '添加 YouTube 视频';

  @override
  String get pasteYouTubeUrl => '在此粘贴 YouTube 链接';

  @override
  String get clickToUploadImage => '点击上传图片';

  @override
  String get pasteYouTubeVideoUrl => '粘贴 YouTube 视频链接';

  @override
  String get saving => '保存中…';

  @override
  String get formSaved => '表单已保存！链接已复制到剪贴板。';

  @override
  String formSavedWithWarnings(String warnings) {
    return '表单已保存！链接已复制。$warnings';
  }

  @override
  String get failedToSaveForm => '无法保存表单。';

  @override
  String get failedToLoadForm => '无法加载表单。';

  @override
  String get saveToPreview => '保存以预览';

  @override
  String get saveForm => '保存表单';

  @override
  String get saveTheFormFirst => '请先保存表单以获取链接';

  @override
  String get saveBeforePublishing => '请先保存表单再发布。';

  @override
  String get unsavedChanges => '未保存的更改';

  @override
  String get unsavedChangesBackDesc => '您有未保存的更改。离开前要保存吗？';

  @override
  String get unsavedChangesPreviewDesc => '请保存表单以预览最新的更改。';

  @override
  String get dontSave => '不保存';

  @override
  String get untitledQuestion => '未命名问题';

  @override
  String get formTitle => '表单标题';

  @override
  String get formDescription => '表单说明';

  @override
  String get addOption => '添加选项';

  @override
  String columnN(int n) {
    return '列 $n';
  }

  @override
  String rowN(int n) {
    return '行 $n';
  }

  @override
  String get addColumn => '添加列';

  @override
  String get addRow => '添加行';

  @override
  String get minValue => '最小值';

  @override
  String get maxValue => '最大值';

  @override
  String get labelOptional => '标签（选填）';

  @override
  String get showDescription => '显示说明';

  @override
  String get includeYear => '包含年份';

  @override
  String get duration => '时长';

  @override
  String get tooltipDragToReorder => '拖动以重新排序问题';

  @override
  String get tooltipCopyLink => '复制链接';

  @override
  String get tooltipPublished => '已发布';

  @override
  String get tooltipPublish => '发布';

  @override
  String get tooltipSave => '保存';

  @override
  String get tooltipDuplicate => '复制';

  @override
  String get tooltipDelete => '删除';

  @override
  String get tooltipMoreOptions => '更多选项';

  @override
  String get tooltipAddImageToQuestion => '在问题中添加图片';

  @override
  String get tooltipExportXlsx => '导出为 .xlsx';

  @override
  String get tooltipExportCsv => '导出为 .csv';

  @override
  String get tooltipOpenLinkedSheet => '打开已关联的 Google 表格';

  @override
  String get tooltipLinkToSheet => '关联 Google 表格';

  @override
  String get tooltipRemoveEditor => '移除编辑者';

  @override
  String get noPreviewAvailable => '没有可用的预览';

  @override
  String get noPreviewDesc => '请先保存表单，才能预览回复者看到的样子。';

  @override
  String get saveYourFormFirst => '请先保存表单';

  @override
  String get needSaveForResponses => '您需要先保存表单才能查看回复。';

  @override
  String get noResponsesYet => '还没有回复';

  @override
  String get noResponsesDesc => '有人提交您的表单后，回复将显示在这里。';

  @override
  String get shareThisForm => '分享此表单';

  @override
  String get responseSubSummary => '摘要';

  @override
  String get responseSubQuestion => '问题';

  @override
  String get responseSubIndividual => '个别';

  @override
  String nResponses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 则回复',
      one: '1 则回复',
    );
    return '$_temp0';
  }

  @override
  String get noAnswersYet => '还没有回答。';

  @override
  String get noGridData => '没有网格数据。';

  @override
  String andNMore(int n) {
    return '…以及其他 $n 个';
  }

  @override
  String get noQuestionsFound => '找不到问题。';

  @override
  String get questionLabel => '问题：';

  @override
  String questionN(int n) {
    return '问题 $n';
  }

  @override
  String get noResponses => '没有回复。';

  @override
  String responseNOfTotal(int n, int total) {
    return '第 $n 个，共 $total 个';
  }

  @override
  String submittedTime(String time) {
    return '提交时间：$time';
  }

  @override
  String responseN(int n) {
    return '回复 $n';
  }

  @override
  String get noAnswer => '未回答';

  @override
  String get couldNotOpenYouTube => '无法打开 YouTube。';

  @override
  String exportAs(String format) {
    return '导出为 $format';
  }

  @override
  String get enterFileName => '请输入导出文件名：';

  @override
  String get fileName => '文件名';

  @override
  String exportFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String get responseId => '回复 ID';

  @override
  String get createTime => '创建时间';

  @override
  String get lastSubmittedTime => '最近提交时间';

  @override
  String get responsesSheet => '回复';

  @override
  String get exportXlsx => 'XLSX';

  @override
  String get exportCsv => 'CSV';

  @override
  String get sheets => 'Sheets';

  @override
  String get linkedToSheet => '已关联表格';

  @override
  String get responsesAutoSaved => '回复会自动保存到此电子表格：';

  @override
  String get linkedSpreadsheet => '已关联的电子表格';

  @override
  String get tapToOpenInBrowser => '点击在浏览器中打开';

  @override
  String get openSheet => '打开表格';

  @override
  String get linkToGoogleSheet => '关联 Google 表格';

  @override
  String get linkSheetDesc => '表单回复会自动保存到此电子表格。将创建一个包含所有回复的新工作表。';

  @override
  String get createAndLink => '创建并关联';

  @override
  String get spreadsheetName => '电子表格名称';

  @override
  String get unlinkSheetTitle => '取消关联表格？';

  @override
  String get unlinkSheetDesc => '新的表单回复将不再保存到此电子表格。表格中现有的回复不会被删除。';

  @override
  String get sheetUnlinked => '表格已成功取消关联。';

  @override
  String get failedToCreateSheet => '无法创建电子表格，请重试。';

  @override
  String formLinkedToSheet(String name) {
    return '表单已成功关联到「$name」！';
  }

  @override
  String failedToLink(String error) {
    return '无法关联：$error';
  }

  @override
  String failedToUnlink(String error) {
    return '无法取消关联：$error';
  }

  @override
  String errorWithMessage(String message) {
    return '错误：$message';
  }

  @override
  String get publishRequired => '需要发布';

  @override
  String get publishRequiredDesc => '您需要先发布此表单才能接收回复。是否现在发布？';

  @override
  String get formPublished => '表单已发布，现在可以接收回复！';

  @override
  String failedToPublish(String error) {
    return '无法发布：$error';
  }

  @override
  String get formUnpublished => '表单已取消发布';

  @override
  String get formIsPublished => '表单已发布';

  @override
  String get copyFormLink => '复制表单链接';

  @override
  String get unpublishForm => '取消发布表单';

  @override
  String get unpublishFormDesc => '表单将停止接收回复';

  @override
  String get settingsResponses => '回复';

  @override
  String get settingsPresentation => '呈现方式';

  @override
  String get settingsEditors => '编辑者';

  @override
  String get acceptResponses => '接受回复';

  @override
  String get acceptResponsesEnabled => '用户可以提交此表单的回复';

  @override
  String get acceptResponsesDisabled => '此表单目前不接受回复';

  @override
  String get collectEmail => '收集电子邮件地址';

  @override
  String get collectEmailDesc => '选择收集回复者电子邮件的方式';

  @override
  String get dontCollect => '不收集';

  @override
  String get verified => '已验证';

  @override
  String get responderInput => '回复者输入';

  @override
  String get limitToOneResponse => '限制为 1 次回复';

  @override
  String get limitToOneResponseDesc => '需要回复者登录';

  @override
  String get editAfterSubmit => '提交后可编辑';

  @override
  String get editAfterSubmitDesc => '允许回复者在提交后编辑回复';

  @override
  String get showProgressBar => '显示进度条';

  @override
  String get showProgressBarDesc => '在表单底部显示进度条';

  @override
  String get shuffleQuestionOrder => '随机编排问题的顺序';

  @override
  String get shuffleQuestionOrderDesc => '每位回复者看到的问题顺序会不同';

  @override
  String get confirmationMessage => '确认消息';

  @override
  String get confirmationMessageDesc => '表单提交后显示的消息';

  @override
  String get enterConfirmationMessage => '输入确认消息';

  @override
  String get defaultConfirmationMessage => '您的回复已记录。';

  @override
  String get addEditor => '添加编辑者';

  @override
  String get gmailAddress => 'Gmail 地址';

  @override
  String get gmailHint => 'name@gmail.com';

  @override
  String get enterGmail => '请输入 Gmail 地址。';

  @override
  String get enterValidEmail => '请输入有效的电子邮件地址。';

  @override
  String get removeEditorTitle => '移除编辑者？';

  @override
  String removeEditorDesc(String name) {
    return '确定从此表单移除 $name？对方将无法再编辑此表单。';
  }

  @override
  String get alreadyOwner => '您已经是此表单的所有者。';

  @override
  String get alreadyOwnerOther => '此用户已经是此表单的所有者。';

  @override
  String get alreadyEditor => '此用户已经是此表单的编辑者。';

  @override
  String get failedToAddEditor => '无法添加编辑者。';

  @override
  String addedEditor(String email) {
    return '已添加 $email 为编辑者。';
  }

  @override
  String get cannotRemoveOwner => '无法移除所有者。';

  @override
  String get failedToRemoveEditor => '无法移除编辑者。';

  @override
  String removedEditor(String name) {
    return '已移除 $name。';
  }

  @override
  String get noOwnerFound => '找不到此表单的协作者。';

  @override
  String get noEditorsYet => '还没有编辑者。点击 +添加 通过 Gmail 邀请他人。';

  @override
  String get noEditorsOnForm => '此表单没有编辑者。';

  @override
  String get failedToLoadEditors => '无法加载编辑者。';

  @override
  String get saveChangesTitle => '保存更改？';

  @override
  String breakingChangesDesc(String desc) {
    return '此更改将影响现有的回复：$desc。\n\n您要继续吗？';
  }

  @override
  String get duplicateChoicesError => '单选题不能有重复的选项。';

  @override
  String get invalidDataError => '数据无效，请检查您的表单后重试。';

  @override
  String get permissionDeniedError => '权限被拒绝，请检查您的 Google 账号权限。';

  @override
  String get addAtLeastOneQuestion => '请在保存前添加至少一个问题。';

  @override
  String get failedToUpdateForm => '无法更新表单。';

  @override
  String get failedToLoadCurrentForm => '无法加载当前表单数据，请重试。';

  @override
  String couldNotLoadSettings(String error) {
    return '无法加载表单设置：$error';
  }

  @override
  String get linkCopiedToClipboardExclaim => '链接已复制到剪贴板！';

  @override
  String get userFallback => '用户';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appName => 'Form';

  @override
  String get cancel => '取消';

  @override
  String get save => '儲存';

  @override
  String get delete => '刪除';

  @override
  String get discard => '捨棄';

  @override
  String get continueAction => '繼續';

  @override
  String get done => '完成';

  @override
  String get remove => '移除';

  @override
  String get add => '新增';

  @override
  String get settings => '設定';

  @override
  String get close => '關閉';

  @override
  String get untitled => '未命名';

  @override
  String get open => '開啟';

  @override
  String get change => '變更';

  @override
  String get export => '匯出';

  @override
  String get publish => '發佈';

  @override
  String get unlink => '取消連結';

  @override
  String get duplicate => '複製';

  @override
  String get rename => '重新命名';

  @override
  String get renameForm => '重新命名表單';

  @override
  String get enterNewName => '輸入新名稱';

  @override
  String get documentName => '文件名稱';

  @override
  String get formRenamed => '表單已重新命名';

  @override
  String get failedToRename => '重新命名表單失敗';

  @override
  String get required => '必填';

  @override
  String get optional => '選填';

  @override
  String get other => '其他';

  @override
  String get description => '說明';

  @override
  String get question => '問題';

  @override
  String get columns => '欄';

  @override
  String get rows => '列';

  @override
  String get image => '圖片';

  @override
  String get video => '影片';

  @override
  String get owner => '擁有者';

  @override
  String get loginSubtitle => '隨時隨地建立同管理表單';

  @override
  String get signInWithGoogle => '使用 Google 登入';

  @override
  String get signInFailed => '登入失敗，請再試一次。';

  @override
  String get tabMyForms => '我的表單';

  @override
  String get tabTemplates => '範本';

  @override
  String get searchForms => '搜尋你的表單';

  @override
  String get searchTemplates => '搜尋範本';

  @override
  String get recentForms => '近期表單';

  @override
  String get noRecentForms => '沒有近期表單';

  @override
  String noFormsMatching(String query) {
    return '沒有符合「$query」的表單';
  }

  @override
  String get tryDifferentSearch => '嘗試其他搜尋字詞';

  @override
  String noTemplatesMatching(String query) {
    return '沒有符合「$query」的範本';
  }

  @override
  String get tryDifferentSearchOrCategory => '嘗試其他搜尋字詞或分類';

  @override
  String get thisIsTheEnd => '已經到底了';

  @override
  String get linkCopiedToClipboard => '連結已複製到剪貼簿';

  @override
  String get deleteFormTitle => '刪除表單？';

  @override
  String get deleteFormContent => '此表單將會被移至垃圾桶。';

  @override
  String get formMovedToTrash => '表單已移至垃圾桶';

  @override
  String get failedToDeleteForm => '無法刪除表單';

  @override
  String get duplicatingForm => '正在複製表單…';

  @override
  String get formDuplicated => '表單已複製！';

  @override
  String get failedToDuplicateForm => '無法複製表單';

  @override
  String get templateComingSoon => '範本即將推出！';

  @override
  String get loadingTemplate => '正在載入範本…';

  @override
  String get failedToLoadTemplate => '無法載入範本，請再試一次。';

  @override
  String get soon => '即將推出';

  @override
  String templateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個範本',
      one: '1 個範本',
    );
    return '$_temp0';
  }

  @override
  String get ownedByAnyone => '任何人擁有';

  @override
  String get ownedByMe => '我擁有的';

  @override
  String get notOwnedByMe => '非我擁有的';

  @override
  String get lastModified => '最近修改';

  @override
  String get lastOpened => '最近開啟';

  @override
  String get titleAZ => '標題 (A-Z)';

  @override
  String get copyLink => '複製連結';

  @override
  String get categoryAll => '全部';

  @override
  String get categoryWork => '工作';

  @override
  String get categoryEducation => '教育';

  @override
  String get categoryCommunity => '社群';

  @override
  String get categoryHealth => '健康與養生';

  @override
  String get tplPrayerRequestSafety => '安全與保護禱告請求';

  @override
  String get tplPrayerRequestSafetyDesc => '提交安全與保護的禱告請求';

  @override
  String get tplWorkshopEvaluation => '工作坊評估';

  @override
  String get tplWorkshopEvaluationDesc => '評估工作坊的效果';

  @override
  String get tplSoccerTryoutEvaluation => '足球選拔評估';

  @override
  String get tplSoccerTryoutEvaluationDesc => '評估足球選拔表現';

  @override
  String get tplOralPresentationEvaluation => '口頭演講評估表';

  @override
  String get tplOralPresentationEvaluationDesc => '評估口頭演講技巧';

  @override
  String get tplPeerFeedback => '同儕回饋表';

  @override
  String get tplPeerFeedbackDesc => '向同儕提供回饋';

  @override
  String get tplPresentationFeedback => '簡報回饋';

  @override
  String get tplPresentationFeedbackDesc => '對簡報提供回饋';

  @override
  String get tplPatientFeedback => '病人回饋表';

  @override
  String get tplPatientFeedbackDesc => '收集病人對護理的回饋';

  @override
  String get tplChildcareRegistration => '托兒登記表';

  @override
  String get tplChildcareRegistrationDesc => '為孩子登記托兒服務';

  @override
  String get tplMedicationOrder => '藥物訂購表';

  @override
  String get tplMedicationOrderDesc => '提交藥物訂單';

  @override
  String get tplTeamworkCollaborationEvaluation => '團隊合作與協作評估';

  @override
  String get tplTeamworkCollaborationEvaluationDesc => '評估團隊協作能力';

  @override
  String get tplTrainingDevelopmentFeedback => '培訓與發展回饋表';

  @override
  String get tplTrainingDevelopmentFeedbackDesc => '對培訓計畫提供回饋';

  @override
  String get tplAnnualEmployeePerformanceReview => '年度員工績效評估';

  @override
  String get tplAnnualEmployeePerformanceReviewDesc => '年度員工績效回顧';

  @override
  String get useThisTemplate => '使用此範本';

  @override
  String get failedToCopyTemplate => '無法複製範本，請再試一次。';

  @override
  String get untitledForm => '未命名表單';

  @override
  String sectionTitleOf(int n, int total) {
    return '第 $n 版面，共 $total 版面';
  }

  @override
  String get sectionTitle => '版面標題';

  @override
  String get shortAnswerText => '簡短答案文字';

  @override
  String get longAnswerText => '長篇答案文字';

  @override
  String get imageTitleOptional => '圖片標題（選填）';

  @override
  String get videoTitle => '影片標題';

  @override
  String optionLabel(int n) {
    return '選項 $n';
  }

  @override
  String get youTubeVideo => 'YouTube 影片';

  @override
  String get dateFormatWithYear => 'MM/DD/YYYY';

  @override
  String get dateFormatNoYear => 'MM/DD';

  @override
  String get timeFormatDuration => 'HH:MM:SS';

  @override
  String get timeFormatStandard => 'HH:MM';

  @override
  String get googleAccount => 'Google 帳戶';

  @override
  String get signOut => '登出';

  @override
  String get signOutTitle => '登出？';

  @override
  String get signOutContent => '確定要登出你的帳戶嗎？';

  @override
  String get goPremium => '升級為進階版';

  @override
  String get goPremiumDesc => '解鎖所有功能並移除廣告';

  @override
  String get about => '關於';

  @override
  String get privacyPolicy => '隱私權政策';

  @override
  String get termsOfUse => '使用條款';

  @override
  String get version => '版本 1.0.0';

  @override
  String get language => '語言';

  @override
  String get languageSystemDefault => '跟隨系統';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get tabEdit => '編輯';

  @override
  String get tabPreview => '預覽';

  @override
  String get tabResponses => '回覆';

  @override
  String get tabSettings => '設定';

  @override
  String get qTypeMultipleChoice => '單選按鈕';

  @override
  String get qTypeCheckboxes => '多選題';

  @override
  String get qTypeShortAnswer => '簡短答案';

  @override
  String get qTypeParagraph => '段落';

  @override
  String get qTypeDropdown => '下拉式選單';

  @override
  String get qTypeImage => '圖片';

  @override
  String get qTypeVideo => '影片';

  @override
  String get qTypeLinearScale => '線性比例';

  @override
  String get qTypeMultipleChoiceGrid => '單選按鈕方格';

  @override
  String get qTypeCheckboxGrid => '選框格線';

  @override
  String get qTypeDate => '日期';

  @override
  String get qTypeTime => '時間';

  @override
  String get qTypeInfo => '標題';

  @override
  String get qTypeSection => '版面';

  @override
  String get qTypeTitleDescription => '標題與說明';

  @override
  String get addQuestion => '新增問題';

  @override
  String get addImage => '新增圖片';

  @override
  String get addVideo => '新增影片';

  @override
  String get addInfo => '新增標題';

  @override
  String get addSection => '新增版面';

  @override
  String get addYouTubeVideo => '新增 YouTube 影片';

  @override
  String get pasteYouTubeUrl => '請在此貼上 YouTube 連結';

  @override
  String get clickToUploadImage => '點擊上傳圖片';

  @override
  String get pasteYouTubeVideoUrl => '貼上 YouTube 影片連結';

  @override
  String get saving => '儲存中…';

  @override
  String get formSaved => '表單已儲存！連結已複製到剪貼簿。';

  @override
  String formSavedWithWarnings(String warnings) {
    return '表單已儲存！連結已複製。$warnings';
  }

  @override
  String get failedToSaveForm => '無法儲存表單。';

  @override
  String get failedToLoadForm => '無法載入表單。';

  @override
  String get saveToPreview => '儲存以預覽';

  @override
  String get saveForm => '儲存表單';

  @override
  String get saveTheFormFirst => '請先儲存表單以取得連結';

  @override
  String get saveBeforePublishing => '請先儲存表單再發佈。';

  @override
  String get unsavedChanges => '未儲存的變更';

  @override
  String get unsavedChangesBackDesc => '你有未儲存的變更。離開前要儲存嗎？';

  @override
  String get unsavedChangesPreviewDesc => '請儲存表單以預覽最新的變更。';

  @override
  String get dontSave => '不儲存';

  @override
  String get untitledQuestion => '未命名問題';

  @override
  String get formTitle => '表單標題';

  @override
  String get formDescription => '表單說明';

  @override
  String get addOption => '新增選項';

  @override
  String columnN(int n) {
    return '欄 $n';
  }

  @override
  String rowN(int n) {
    return '列 $n';
  }

  @override
  String get addColumn => '新增欄';

  @override
  String get addRow => '新增列';

  @override
  String get minValue => '最小值';

  @override
  String get maxValue => '最大值';

  @override
  String get labelOptional => '標籤（選填）';

  @override
  String get showDescription => '顯示說明';

  @override
  String get includeYear => '包含年份';

  @override
  String get duration => '時長';

  @override
  String get tooltipDragToReorder => '拖曳以重新排序問題';

  @override
  String get tooltipCopyLink => '複製連結';

  @override
  String get tooltipPublished => '已發佈';

  @override
  String get tooltipPublish => '發佈';

  @override
  String get tooltipSave => '儲存';

  @override
  String get tooltipDuplicate => '複製';

  @override
  String get tooltipDelete => '刪除';

  @override
  String get tooltipMoreOptions => '更多選項';

  @override
  String get tooltipAddImageToQuestion => '在問題中新增圖片';

  @override
  String get tooltipExportXlsx => '匯出為 .xlsx';

  @override
  String get tooltipExportCsv => '匯出為 .csv';

  @override
  String get tooltipOpenLinkedSheet => '開啟已連結的 Google 試算表';

  @override
  String get tooltipLinkToSheet => '連結 Google 試算表';

  @override
  String get tooltipRemoveEditor => '移除編輯者';

  @override
  String get noPreviewAvailable => '沒有可用的預覽';

  @override
  String get noPreviewDesc => '請先儲存表單，才能預覽回覆者看到的樣貌。';

  @override
  String get saveYourFormFirst => '請先儲存表單';

  @override
  String get needSaveForResponses => '你需要先儲存表單才能查看回覆。';

  @override
  String get noResponsesYet => '還沒有回覆';

  @override
  String get noResponsesDesc => '當有人提交你的表單後，回覆會顯示喺呢度。';

  @override
  String get shareThisForm => '分享此表單';

  @override
  String get responseSubSummary => '摘要';

  @override
  String get responseSubQuestion => '問題';

  @override
  String get responseSubIndividual => '個別';

  @override
  String nResponses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 則回覆',
      one: '1 則回覆',
    );
    return '$_temp0';
  }

  @override
  String get noAnswersYet => '還沒有回答。';

  @override
  String get noGridData => '沒有矩陣資料。';

  @override
  String andNMore(int n) {
    return '…以及其他 $n 個';
  }

  @override
  String get noQuestionsFound => '找不到問題。';

  @override
  String get questionLabel => '問題：';

  @override
  String questionN(int n) {
    return '問題 $n';
  }

  @override
  String get noResponses => '沒有回覆。';

  @override
  String responseNOfTotal(int n, int total) {
    return '第 $n 個，共 $total 個';
  }

  @override
  String submittedTime(String time) {
    return '提交時間：$time';
  }

  @override
  String responseN(int n) {
    return '回覆 $n';
  }

  @override
  String get noAnswer => '未回答';

  @override
  String get couldNotOpenYouTube => '無法開啟 YouTube。';

  @override
  String exportAs(String format) {
    return '匯出為 $format';
  }

  @override
  String get enterFileName => '請輸入匯出檔案名稱：';

  @override
  String get fileName => '檔案名稱';

  @override
  String exportFailed(String error) {
    return '匯出失敗：$error';
  }

  @override
  String get responseId => '回覆 ID';

  @override
  String get createTime => '建立時間';

  @override
  String get lastSubmittedTime => '最近提交時間';

  @override
  String get responsesSheet => '回覆';

  @override
  String get exportXlsx => 'XLSX';

  @override
  String get exportCsv => 'CSV';

  @override
  String get sheets => 'Sheets';

  @override
  String get linkedToSheet => '已連結試算表';

  @override
  String get responsesAutoSaved => '回覆會自動儲存到此試算表：';

  @override
  String get linkedSpreadsheet => '已連結的試算表';

  @override
  String get tapToOpenInBrowser => '點擊在瀏覽器中開啟';

  @override
  String get openSheet => '開啟試算表';

  @override
  String get linkToGoogleSheet => '連結 Google 試算表';

  @override
  String get linkSheetDesc => '表單回覆會自動儲存到此試算表。會建立一個新的工作表分頁存放所有回覆。';

  @override
  String get createAndLink => '建立並連結';

  @override
  String get spreadsheetName => '試算表名稱';

  @override
  String get unlinkSheetTitle => '取消連結試算表？';

  @override
  String get unlinkSheetDesc => '新的表單回覆將不再儲存到此試算表。試算表中現有的回覆不會被刪除。';

  @override
  String get sheetUnlinked => '試算表已成功取消連結。';

  @override
  String get failedToCreateSheet => '無法建立試算表，請再試一次。';

  @override
  String formLinkedToSheet(String name) {
    return '表單已成功連結到「$name」！';
  }

  @override
  String failedToLink(String error) {
    return '無法連結：$error';
  }

  @override
  String failedToUnlink(String error) {
    return '無法取消連結：$error';
  }

  @override
  String errorWithMessage(String message) {
    return '錯誤：$message';
  }

  @override
  String get publishRequired => '需要發佈';

  @override
  String get publishRequiredDesc => '你需要先發佈此表單才能接收回覆。你想現在發佈嗎？';

  @override
  String get formPublished => '表單已發佈，現在可以接收回覆！';

  @override
  String failedToPublish(String error) {
    return '無法發佈：$error';
  }

  @override
  String get formUnpublished => '表單已取消發佈';

  @override
  String get formIsPublished => '表單已發佈';

  @override
  String get copyFormLink => '複製表單連結';

  @override
  String get unpublishForm => '取消發佈表單';

  @override
  String get unpublishFormDesc => '表單將停止接收回覆';

  @override
  String get settingsResponses => '回覆';

  @override
  String get settingsPresentation => '呈現方式';

  @override
  String get settingsEditors => '編輯者';

  @override
  String get acceptResponses => '接收回覆';

  @override
  String get acceptResponsesEnabled => '用戶可以提交此表單的回覆';

  @override
  String get acceptResponsesDisabled => '此表單目前不接受回覆';

  @override
  String get collectEmail => '收集電子郵件地址';

  @override
  String get collectEmailDesc => '選擇收集回覆者電子郵件的方式';

  @override
  String get dontCollect => '不收集';

  @override
  String get verified => '已驗證';

  @override
  String get responderInput => '回覆者輸入';

  @override
  String get limitToOneResponse => '限制為 1 次回覆';

  @override
  String get limitToOneResponseDesc => '需要回覆者登入';

  @override
  String get editAfterSubmit => '提交後可編輯';

  @override
  String get editAfterSubmitDesc => '允許回覆者在提交後編輯回覆';

  @override
  String get showProgressBar => '顯示進度列';

  @override
  String get showProgressBarDesc => '在表單底部顯示進度列';

  @override
  String get shuffleQuestionOrder => '隨機排列問題順序';

  @override
  String get shuffleQuestionOrderDesc => '每位回覆者看到的問題順序會不同';

  @override
  String get confirmationMessage => '確認訊息';

  @override
  String get confirmationMessageDesc => '表單提交後顯示的訊息';

  @override
  String get enterConfirmationMessage => '輸入確認訊息';

  @override
  String get defaultConfirmationMessage => '你的回覆已記錄。';

  @override
  String get addEditor => '新增編輯者';

  @override
  String get gmailAddress => 'Gmail 地址';

  @override
  String get gmailHint => 'name@gmail.com';

  @override
  String get enterGmail => '請輸入 Gmail 地址。';

  @override
  String get enterValidEmail => '請輸入有效的電子郵件地址。';

  @override
  String get removeEditorTitle => '移除編輯者？';

  @override
  String removeEditorDesc(String name) {
    return '確定從此表單移除 $name？對方將無法再編輯此表單。';
  }

  @override
  String get alreadyOwner => '你已經是此表單的擁有者。';

  @override
  String get alreadyOwnerOther => '此用戶已經是此表單的擁有者。';

  @override
  String get alreadyEditor => '此用戶已經是此表單的編輯者。';

  @override
  String get failedToAddEditor => '無法新增編輯者。';

  @override
  String addedEditor(String email) {
    return '已新增 $email 為編輯者。';
  }

  @override
  String get cannotRemoveOwner => '無法移除擁有者。';

  @override
  String get failedToRemoveEditor => '無法移除編輯者。';

  @override
  String removedEditor(String name) {
    return '已移除 $name。';
  }

  @override
  String get noOwnerFound => '找不到此表單的協作者。';

  @override
  String get noEditorsYet => '還沒有編輯者。點擊 +新增 以透過 Gmail 邀請他人。';

  @override
  String get noEditorsOnForm => '此表單沒有編輯者。';

  @override
  String get failedToLoadEditors => '無法載入編輯者。';

  @override
  String get saveChangesTitle => '儲存變更？';

  @override
  String breakingChangesDesc(String desc) {
    return '此變更將影響現有的回覆：$desc。\n\n你要繼續嗎？';
  }

  @override
  String get duplicateChoicesError => '單選按鈕不能有重複的選項。';

  @override
  String get invalidDataError => '資料無效，請檢查你的表單後再試一次。';

  @override
  String get permissionDeniedError => '權限被拒絕，請檢查你的 Google 帳戶權限。';

  @override
  String get addAtLeastOneQuestion => '請在儲存前新增至少一個問題。';

  @override
  String get failedToUpdateForm => '無法更新表單。';

  @override
  String get failedToLoadCurrentForm => '無法載入目前表單資料，請再試一次。';

  @override
  String couldNotLoadSettings(String error) {
    return '無法載入表單設定：$error';
  }

  @override
  String get linkCopiedToClipboardExclaim => '連結已複製到剪貼簿！';

  @override
  String get userFallback => '用戶';
}
