// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Form';

  @override
  String get cancel => 'Membatalkan';

  @override
  String get save => 'Menyimpan';

  @override
  String get delete => 'Menghapus';

  @override
  String get discard => 'Membuang';

  @override
  String get continueAction => 'Melanjutkan';

  @override
  String get done => 'Selesai';

  @override
  String get remove => 'Menghapus';

  @override
  String get add => 'Menambahkan';

  @override
  String get settings => 'Pengaturan';

  @override
  String get close => 'Menutup';

  @override
  String get untitled => 'Tanpa judul';

  @override
  String get open => 'Membuka';

  @override
  String get change => 'Mengubah';

  @override
  String get export => 'Ekspor';

  @override
  String get publish => 'Menerbitkan';

  @override
  String get unlink => 'Putuskan tautan';

  @override
  String get duplicate => 'Buat salinan';

  @override
  String get rename => 'Ganti nama';

  @override
  String get renameForm => 'Ganti nama';

  @override
  String get enterNewName => 'Masukkan nama baru';

  @override
  String get documentName => 'Nama dokumen';

  @override
  String get formRenamed => 'Nama diganti';

  @override
  String get failedToRename => 'Gagal mengganti nama';

  @override
  String get required => 'Wajib diisi';

  @override
  String get optional => 'Opsional';

  @override
  String get other => 'Lainnya';

  @override
  String get description => 'Keterangan';

  @override
  String get question => 'Pertanyaan';

  @override
  String get columns => 'Kolom';

  @override
  String get rows => 'Baris';

  @override
  String get image => 'Gambar';

  @override
  String get video => 'Video';

  @override
  String get owner => 'Pemilik';

  @override
  String get loginSubtitle => 'Buat dan kelola formulir saat bepergian';

  @override
  String get signInWithGoogle => 'Masuk dengan Google';

  @override
  String get signInFailed => 'Gagal masuk. Silakan coba lagi.';

  @override
  String get tabMyForms => 'Formulir saya';

  @override
  String get tabTemplates => 'Galeri Template';

  @override
  String get searchForms => 'Cari formulir Anda';

  @override
  String get searchTemplates => 'Templat pencarian';

  @override
  String get recentForms => 'Formulir terbaru';

  @override
  String get noRecentForms => 'Tidak ada formulir terbaru';

  @override
  String noFormsMatching(String query) {
    return 'Tidak ada formulir yang cocok dengan \"$query\"';
  }

  @override
  String get tryDifferentSearch => 'Coba istilah pencarian lain';

  @override
  String noTemplatesMatching(String query) {
    return 'Tidak ada templat yang cocok dengan \"$query\"';
  }

  @override
  String get tryDifferentSearchOrCategory =>
      'Coba istilah pencarian atau kategori lain';

  @override
  String get thisIsTheEnd => '-Inilah akhirnya-';

  @override
  String get linkCopiedToClipboard => 'Tautan disalin ke papan klip';

  @override
  String get deleteFormTitle => 'Pindahkan ke Sampah?';

  @override
  String get deleteFormContent => 'Formulir ini akan dipindahkan ke Sampah.';

  @override
  String get formMovedToTrash => 'Dipindahkan ke Sampah';

  @override
  String get failedToDeleteForm => 'Gagal menghapus formulir';

  @override
  String get duplicatingForm => 'Membuat salinan…';

  @override
  String get formDuplicated => 'Salinan dibuat';

  @override
  String get failedToDuplicateForm => 'Gagal membuat salinan';

  @override
  String get templateComingSoon => 'Templat segera hadir!';

  @override
  String get loadingTemplate => 'Memuat templat...';

  @override
  String get failedToLoadTemplate => 'Gagal memuat templat. Silakan coba lagi.';

  @override
  String get soon => 'Segera';

  @override
  String templateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count templat',
      one: '1 templat',
    );
    return '$_temp0';
  }

  @override
  String get ownedByAnyone => 'Milik siapa pun';

  @override
  String get ownedByMe => 'Milik saya';

  @override
  String get notOwnedByMe => 'Bukan milik saya';

  @override
  String get lastModified => 'Terakhir diubah';

  @override
  String get lastOpened => 'Terakhir dibuka saya';

  @override
  String get titleAZ => 'Nama';

  @override
  String get copyLink => 'Salin tautan';

  @override
  String get categoryAll => 'Semua';

  @override
  String get categoryWork => 'Bekerja';

  @override
  String get categoryEducation => 'Pendidikan';

  @override
  String get categoryCommunity => 'Masyarakat';

  @override
  String get categoryHealth => 'Kesehatan & Kebugaran';

  @override
  String get tplPrayerRequestSafety =>
      'Doa Permohonan Keselamatan dan Perlindungan';

  @override
  String get tplPrayerRequestSafetyDesc =>
      'Kirimkan permohonan doa untuk keselamatan dan perlindungan';

  @override
  String get tplWorkshopEvaluation => 'Evaluasi Lokakarya';

  @override
  String get tplWorkshopEvaluationDesc => 'Evaluasi efektivitas lokakarya';

  @override
  String get tplSoccerTryoutEvaluation => 'Evaluasi Uji Coba Sepak Bola';

  @override
  String get tplSoccerTryoutEvaluationDesc =>
      'Menilai kinerja uji coba sepak bola';

  @override
  String get tplOralPresentationEvaluation =>
      'Formulir Evaluasi Presentasi Lisan';

  @override
  String get tplOralPresentationEvaluationDesc =>
      'Evaluasi keterampilan presentasi lisan';

  @override
  String get tplPeerFeedback => 'Formulir Umpan Balik Rekan';

  @override
  String get tplPeerFeedbackDesc => 'Memberikan umpan balik kepada rekan-rekan';

  @override
  String get tplPresentationFeedback => 'Umpan Balik Presentasi';

  @override
  String get tplPresentationFeedbackDesc =>
      'Berikan umpan balik pada presentasi';

  @override
  String get tplPatientFeedback => 'Formulir Umpan Balik Pasien';

  @override
  String get tplPatientFeedbackDesc =>
      'Kumpulkan umpan balik pasien tentang perawatan';

  @override
  String get tplChildcareRegistration => 'Formulir Pendaftaran Penitipan Anak';

  @override
  String get tplChildcareRegistrationDesc =>
      'Daftarkan anak untuk layanan penitipan anak';

  @override
  String get tplMedicationOrder => 'Formulir Pemesanan Obat';

  @override
  String get tplMedicationOrderDesc => 'Kirim pesanan pengobatan';

  @override
  String get tplTeamworkCollaborationEvaluation =>
      'Evaluasi Kerja Sama Tim & Kolaborasi';

  @override
  String get tplTeamworkCollaborationEvaluationDesc =>
      'Evaluasi keterampilan kolaborasi tim';

  @override
  String get tplTrainingDevelopmentFeedback =>
      'Formulir Umpan Balik Pelatihan & Pengembangan';

  @override
  String get tplTrainingDevelopmentFeedbackDesc =>
      'Memberikan umpan balik pada program pelatihan';

  @override
  String get tplAnnualEmployeePerformanceReview =>
      'Tinjauan Kinerja Karyawan Tahunan';

  @override
  String get tplAnnualEmployeePerformanceReviewDesc =>
      'Tinjau kinerja karyawan setiap tahun';

  @override
  String get useThisTemplate => 'Gunakan templat ini';

  @override
  String get failedToCopyTemplate =>
      'Gagal menyalin templat. Silakan coba lagi.';

  @override
  String get untitledForm => 'Formulir tanpa judul';

  @override
  String sectionTitleOf(int n, int total) {
    return 'Bagian $n dari $total';
  }

  @override
  String get sectionTitle => 'Judul bagian';

  @override
  String get shortAnswerText => 'Teks jawaban singkat';

  @override
  String get longAnswerText => 'Teks jawaban panjang';

  @override
  String get imageTitleOptional => 'Judul gambar (opsional)';

  @override
  String get videoTitle => 'Judul video';

  @override
  String optionLabel(int n) {
    return 'Opsi $n';
  }

  @override
  String get youTubeVideo => 'video YouTube';

  @override
  String get dateFormatWithYear => 'MM/DD/YYYY';

  @override
  String get dateFormatNoYear => 'MM/DD';

  @override
  String get timeFormatDuration => 'HH:MM:SS';

  @override
  String get timeFormatStandard => 'HH:MM';

  @override
  String get googleAccount => 'Akun Google';

  @override
  String get signOut => 'Keluar';

  @override
  String get signOutTitle => 'Keluar?';

  @override
  String get signOutContent => 'Apakah Anda yakin ingin keluar dari akun Anda?';

  @override
  String get goPremium => 'Gunakan Premium';

  @override
  String get goPremiumDesc => 'Buka kunci semua fitur dan hapus iklan';

  @override
  String get about => 'Tentang';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get termsOfUse => 'Ketentuan Penggunaan';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get language => 'Bahasa';

  @override
  String get languageSystemDefault => 'Bawaan sistem';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get tabEdit => 'Sunting';

  @override
  String get tabPreview => 'Pratinjau';

  @override
  String get tabResponses => 'Jawaban';

  @override
  String get tabSettings => 'Pengaturan';

  @override
  String get qTypeMultipleChoice => 'Pilihan ganda';

  @override
  String get qTypeCheckboxes => 'kotak centang';

  @override
  String get qTypeShortAnswer => 'Jawaban singkat';

  @override
  String get qTypeParagraph => 'Ayat';

  @override
  String get qTypeDropdown => 'tarik-turun';

  @override
  String get qTypeImage => 'Gambar';

  @override
  String get qTypeVideo => 'Video';

  @override
  String get qTypeLinearScale => 'Skala linier';

  @override
  String get qTypeMultipleChoiceGrid => 'Kisi pilihan ganda';

  @override
  String get qTypeCheckboxGrid => 'Kisi kotak centang';

  @override
  String get qTypeDate => 'Tanggal';

  @override
  String get qTypeTime => 'Waktu';

  @override
  String get qTypeInfo => 'Informasi';

  @override
  String get qTypeSection => 'Bagian';

  @override
  String get qTypeTitleDescription => 'Judul & deskripsi';

  @override
  String get addQuestion => 'Tambahkan pertanyaan';

  @override
  String get addImage => 'Tambahkan gambar';

  @override
  String get addVideo => 'Tambahkan video';

  @override
  String get addInfo => 'Tambahkan informasi';

  @override
  String get addSection => 'Tambahkan bagian';

  @override
  String get addYouTubeVideo => 'Tambahkan video YouTube';

  @override
  String get pasteYouTubeUrl => 'Tempel URL YouTube di sini';

  @override
  String get clickToUploadImage => 'Klik untuk mengunggah gambar';

  @override
  String get pasteYouTubeVideoUrl => 'Tempel URL video YouTube';

  @override
  String get saving => 'Penghematan...';

  @override
  String get formSaved => 'Formulir disimpan! Tautan disalin ke papan klip.';

  @override
  String formSavedWithWarnings(String warnings) {
    return 'Formulir disimpan! Tautan disalin. $warnings';
  }

  @override
  String get failedToSaveForm => 'Gagal menyimpan formulir.';

  @override
  String get failedToLoadForm => 'Gagal memuat formulir.';

  @override
  String get saveToPreview => 'Simpan ke pratinjau';

  @override
  String get saveForm => 'Simpan formulir';

  @override
  String get saveTheFormFirst =>
      'Simpan formulir terlebih dahulu untuk mendapatkan link';

  @override
  String get saveBeforePublishing =>
      'Harap simpan formulir terlebih dahulu sebelum dipublikasikan.';

  @override
  String get unsavedChanges => 'Perubahan yang belum disimpan';

  @override
  String get unsavedChangesBackDesc =>
      'Anda memiliki perubahan yang belum disimpan. Apakah Anda ingin menabung sebelum berangkat?';

  @override
  String get unsavedChangesPreviewDesc =>
      'Simpan formulir Anda untuk melihat pratinjau terbaru perubahan Anda.';

  @override
  String get dontSave => 'Jangan simpan';

  @override
  String get untitledQuestion => 'Pertanyaan Tanpa Judul';

  @override
  String get formTitle => 'Judul formulir';

  @override
  String get formDescription => 'Deskripsi formulir';

  @override
  String get addOption => 'Tambahkan opsi';

  @override
  String columnN(int n) {
    return 'Kolom $n';
  }

  @override
  String rowN(int n) {
    return 'Baris $n';
  }

  @override
  String get addColumn => 'Tambahkan kolom';

  @override
  String get addRow => 'Tambahkan baris';

  @override
  String get minValue => 'Nilai minimal';

  @override
  String get maxValue => 'Nilai maksimal';

  @override
  String get labelOptional => 'Label (opsional)';

  @override
  String get showDescription => 'Tampilkan deskripsi';

  @override
  String get includeYear => 'Sertakan tahun';

  @override
  String get duration => 'Lamanya';

  @override
  String get tooltipDragToReorder => 'Tarik untuk menyusun ulang pertanyaan';

  @override
  String get tooltipCopyLink => 'Salin Tautan';

  @override
  String get tooltipPublished => 'Diterbitkan';

  @override
  String get tooltipPublish => 'Menerbitkan';

  @override
  String get tooltipSave => 'Menyimpan';

  @override
  String get tooltipDuplicate => 'Buat salinan';

  @override
  String get tooltipDelete => 'Menghapus';

  @override
  String get tooltipMoreOptions => 'Opsi lainnya';

  @override
  String get tooltipAddImageToQuestion => 'Tambahkan gambar ke pertanyaan';

  @override
  String get tooltipExportXlsx => 'Ekspor sebagai .xlsx';

  @override
  String get tooltipExportCsv => 'Download jawaban (.csv)';

  @override
  String get tooltipOpenLinkedSheet => 'Buka Google Sheet yang tertaut';

  @override
  String get tooltipLinkToSheet => 'Tautan ke Google Spreadsheet';

  @override
  String get tooltipRemoveEditor => 'Hapus editor';

  @override
  String get noPreviewAvailable => 'Tidak ada pratinjau yang tersedia';

  @override
  String get noPreviewDesc =>
      'Simpan formulir Anda terlebih dahulu untuk melihat pratinjau langsung tampilannya bagi responden.';

  @override
  String get saveYourFormFirst => 'Simpan formulir Anda terlebih dahulu';

  @override
  String get needSaveForResponses =>
      'Anda perlu menyimpan formulir Anda sebelum Anda dapat melihat tanggapan.';

  @override
  String get noResponsesYet => 'Belum ada tanggapan';

  @override
  String get noResponsesDesc =>
      'Tanggapan akan muncul di sini setelah orang mengirimkan formulir Anda.';

  @override
  String get shareThisForm => 'Bagikan formulir ini';

  @override
  String get responseSubSummary => 'Ringkasan';

  @override
  String get responseSubQuestion => 'Pertanyaan';

  @override
  String get responseSubIndividual => 'Individual';

  @override
  String nResponses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tanggapan',
      one: '1 tanggapan',
    );
    return '$_temp0';
  }

  @override
  String get noAnswersYet => 'Belum ada jawaban.';

  @override
  String get noGridData => 'Tidak ada data jaringan.';

  @override
  String andNMore(int n) {
    return '... dan $n lainnya';
  }

  @override
  String get noQuestionsFound => 'Tidak ada pertanyaan yang ditemukan.';

  @override
  String get questionLabel => 'Pertanyaan:';

  @override
  String questionN(int n) {
    return 'Pertanyaan $n';
  }

  @override
  String get noResponses => 'Tidak ada tanggapan.';

  @override
  String responseNOfTotal(int n, int total) {
    return '$n dari $total';
  }

  @override
  String submittedTime(String time) {
    return 'Dikirim: $time';
  }

  @override
  String responseN(int n) {
    return 'Tanggapan $n';
  }

  @override
  String get noAnswer => 'Tidak ada jawaban';

  @override
  String get couldNotOpenYouTube => 'Tidak dapat membuka YouTube.';

  @override
  String exportAs(String format) {
    return 'Ekspor sebagai $format';
  }

  @override
  String get enterFileName => 'Masukkan nama file untuk ekspor:';

  @override
  String get fileName => 'Nama berkas';

  @override
  String exportFailed(String error) {
    return 'Ekspor gagal: $error';
  }

  @override
  String get responseId => 'ID Respons';

  @override
  String get createTime => 'Ciptakan Waktu';

  @override
  String get lastSubmittedTime => 'Waktu Terakhir Dikirim';

  @override
  String get responsesSheet => 'Tanggapan';

  @override
  String get exportXlsx => 'XLSX';

  @override
  String get exportCsv => 'CSV';

  @override
  String get sheets => 'Sheets';

  @override
  String get linkedToSheet => 'Tertaut ke Lembar';

  @override
  String get responsesAutoSaved =>
      'Tanggapan secara otomatis disimpan ke spreadsheet ini:';

  @override
  String get linkedSpreadsheet => 'Spreadsheet Tertaut';

  @override
  String get tapToOpenInBrowser => 'Ketuk untuk membuka di browser';

  @override
  String get openSheet => 'Buka Lembar';

  @override
  String get linkToGoogleSheet => 'Tautan ke Google Spreadsheet';

  @override
  String get linkSheetDesc =>
      'Tanggapan formulir akan disimpan secara otomatis ke spreadsheet ini. Tab lembar baru akan dibuat dengan semua tanggapan.';

  @override
  String get createAndLink => 'Buat & Tautkan';

  @override
  String get spreadsheetName => 'Nama lembar bentang';

  @override
  String get unlinkSheetTitle => 'Batalkan tautan Lembar?';

  @override
  String get unlinkSheetDesc =>
      'Tanggapan formulir baru tidak akan disimpan lagi ke spreadsheet ini. Respons yang ada di sheet tidak akan dihapus.';

  @override
  String get sheetUnlinked => 'Tautan sheet berhasil dibatalkan.';

  @override
  String get failedToCreateSheet =>
      'Gagal membuat spreadsheet. Silakan coba lagi.';

  @override
  String formLinkedToSheet(String name) {
    return 'Formulir berhasil ditautkan ke \"$name\"!';
  }

  @override
  String failedToLink(String error) {
    return 'Gagal menautkan: $error';
  }

  @override
  String failedToUnlink(String error) {
    return 'Gagal membatalkan tautan: $error';
  }

  @override
  String errorWithMessage(String message) {
    return 'Kesalahan: $message';
  }

  @override
  String get publishRequired => 'Publikasikan Diperlukan';

  @override
  String get publishRequiredDesc =>
      'Anda perlu memublikasikan formulir ini agar dapat menerima tanggapan. Apakah Anda ingin mempublikasikannya sekarang?';

  @override
  String get formPublished =>
      'Formulir diterbitkan dan sekarang menerima tanggapan!';

  @override
  String failedToPublish(String error) {
    return 'Gagal mempublikasikan: $error';
  }

  @override
  String get formUnpublished => 'Formulir tidak dipublikasikan';

  @override
  String get formIsPublished => 'Formulir diterbitkan';

  @override
  String get copyFormLink => 'Salin tautan formulir';

  @override
  String get unpublishForm => 'Batalkan publikasi formulir';

  @override
  String get unpublishFormDesc => 'Formulir akan berhenti menerima tanggapan';

  @override
  String get settingsResponses => 'Jawaban';

  @override
  String get settingsPresentation => 'Presentasi';

  @override
  String get settingsEditors => 'Editor';

  @override
  String get acceptResponses => 'Menerima jawaban';

  @override
  String get acceptResponsesEnabled =>
      'Orang dapat mengirimkan tanggapan ke formulir ini';

  @override
  String get acceptResponsesDisabled => 'Formulir ini tidak menerima tanggapan';

  @override
  String get collectEmail => 'Kumpulkan alamat email';

  @override
  String get collectEmailDesc => 'Pilih cara mengumpulkan email responden';

  @override
  String get dontCollect => 'Jangan kumpulkan';

  @override
  String get verified => 'Telah Diverifikasi';

  @override
  String get responderInput => 'Masukan responden';

  @override
  String get limitToOneResponse => 'Batasi hingga 1 respons';

  @override
  String get limitToOneResponseDesc => 'Mengharuskan responden untuk masuk';

  @override
  String get editAfterSubmit => 'Edit setelah dikirim';

  @override
  String get editAfterSubmitDesc =>
      'Izinkan responden untuk mengedit tanggapan mereka setelah pengiriman';

  @override
  String get showProgressBar => 'Tampilkan status progres';

  @override
  String get showProgressBarDesc =>
      'Menampilkan bilah kemajuan di bagian bawah formulir';

  @override
  String get shuffleQuestionOrder => 'Acak urutan pertanyaan';

  @override
  String get shuffleQuestionOrderDesc =>
      'Pertanyaan akan muncul dalam urutan berbeda untuk setiap responden';

  @override
  String get confirmationMessage => 'Konfirmasi pesan';

  @override
  String get confirmationMessageDesc =>
      'Pesan ditampilkan setelah pengiriman formulir';

  @override
  String get enterConfirmationMessage => 'Masukkan pesan konfirmasi';

  @override
  String get defaultConfirmationMessage => 'Tanggapan Anda telah dicatat.';

  @override
  String get addEditor => 'Tambahkan editor';

  @override
  String get gmailAddress => 'Alamat Gmail';

  @override
  String get gmailHint => 'name@gmail.com';

  @override
  String get enterGmail => 'Silakan masukkan alamat Gmail.';

  @override
  String get enterValidEmail => 'Silakan masukkan alamat email yang valid.';

  @override
  String get removeEditorTitle => 'Hapus editor?';

  @override
  String removeEditorDesc(String name) {
    return 'Hapus $name dari formulir ini? Mereka tidak dapat lagi mengeditnya.';
  }

  @override
  String get alreadyOwner => 'Anda sudah menjadi pemilik formulir ini.';

  @override
  String get alreadyOwnerOther =>
      'Pengguna ini sudah menjadi pemilik formulir ini.';

  @override
  String get alreadyEditor => 'Pengguna ini sudah menjadi editor formulir ini.';

  @override
  String get failedToAddEditor => 'Gagal menambahkan editor.';

  @override
  String addedEditor(String email) {
    return 'Menambahkan $email sebagai editor.';
  }

  @override
  String get cannotRemoveOwner => 'Pemiliknya tidak dapat dihapus.';

  @override
  String get failedToRemoveEditor => 'Gagal menghapus editor.';

  @override
  String removedEditor(String name) {
    return 'Menghapus $name.';
  }

  @override
  String get noOwnerFound =>
      'Tidak ada kolaborator yang ditemukan untuk formulir ini.';

  @override
  String get noEditorsYet =>
      'Belum ada editor. Ketuk +Tambahkan untuk mengundang seseorang melalui Gmail.';

  @override
  String get noEditorsOnForm => 'Tidak ada editor pada formulir ini.';

  @override
  String get failedToLoadEditors => 'Gagal memuat editor.';

  @override
  String get saveChangesTitle => 'Simpan perubahan?';

  @override
  String breakingChangesDesc(String desc) {
    return 'Perubahan ini akan mempengaruhi respons yang ada: $desc.\n\nApakah Anda ingin melanjutkan?';
  }

  @override
  String get duplicateChoicesError =>
      'Anda tidak dapat memiliki pilihan duplikat dalam pertanyaan pilihan ganda.';

  @override
  String get invalidDataError =>
      'Data tidak valid. Silakan periksa formulir Anda dan coba lagi.';

  @override
  String get permissionDeniedError =>
      'Izin ditolak. Silakan periksa akses akun Google Anda.';

  @override
  String get addAtLeastOneQuestion =>
      'Harap tambahkan setidaknya satu pertanyaan sebelum menyimpan.';

  @override
  String get failedToUpdateForm => 'Gagal memperbarui formulir.';

  @override
  String get failedToLoadCurrentForm =>
      'Gagal memuat data formulir saat ini. Silakan coba lagi.';

  @override
  String couldNotLoadSettings(String error) {
    return 'Tidak dapat memuat pengaturan formulir: $error';
  }

  @override
  String get linkCopiedToClipboardExclaim => 'Tautan disalin ke papan klip!';

  @override
  String get userFallback => 'Pengguna';

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
  String get noInternetConnection => 'Tidak ada koneksi internet';

  @override
  String get noInternetConnectionDesc =>
      'Silakan periksa pengaturan jaringan Anda dan coba lagi.';

  @override
  String get noInternetSaveError =>
      'Tidak ada koneksi internet. Tidak dapat menyimpan formulir.';

  @override
  String get noInternetLoadError =>
      'Tidak ada koneksi internet. Tidak dapat memuat formulir.';

  @override
  String get retry => 'Coba lagi';

  @override
  String get formNoLongerExists =>
      'Formulir ini tidak ada lagi atau telah dihapus.';

  @override
  String get failedToPickImage =>
      'Tidak dapat memilih gambar. Silakan coba lagi.';

  @override
  String get failedToShareFile => 'Tidak dapat membagikan file.';
}
