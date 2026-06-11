#!/usr/bin/env python3
"""Generate pt-BR, id, ru, de, fr ARB files from app_en.arb with Google Forms term overrides."""
from __future__ import annotations

import json
import re
import time
from copy import deepcopy
from pathlib import Path

from deep_translator import GoogleTranslator

L10N = Path(__file__).resolve().parent.parent / "lib" / "l10n"
EN_PATH = L10N / "app_en.arb"

# ARB key -> locale-specific override (Google Forms web terminology).
GOOGLE_OVERRIDES: dict[str, dict[str, str]] = {
    "ja": {
        "qTypeDropdown": "プルダウン",
        "settingsPresentation": "表示設定",
        "copyFormLink": "回答者へのリンクをコピー",
    },
    "pt_BR": {
        "qTypeTime": "Horário",
        "other": "Outro",
        "openSheet": "Ver no app Planilhas",
        "tooltipExportCsv": "Baixar respostas (.csv)",
        "copyFormLink": "Copiar link do participante",
    },
    "id": {
        "qTypeMultipleChoiceGrid": "Kisi pilihan ganda",
        "required": "Wajib diisi",
        "duplicate": "Buat salinan",
        "responseSubIndividual": "Individual",
        "tooltipExportCsv": "Download jawaban (.csv)",
        "tabResponses": "Jawaban",
        "settingsResponses": "Jawaban",
        "acceptResponses": "Menerima jawaban",
        "verified": "Telah Diverifikasi",
        "showProgressBar": "Tampilkan status progres",
        "confirmationMessage": "Konfirmasi pesan",
    },
    "ru": {
        "qTypeShortAnswer": "Текст (строка)",
        "qTypeParagraph": "Текст (абзац)",
        "qTypeMultipleChoice": "Один из списка",
        "qTypeCheckboxes": "Несколько из списка",
        "qTypeTitleDescription": "название и описание",
        "tabEdit": "Вопросы",
    },
    "de": {
        "qTypeDropdown": "Drop-down",
        "qTypeTime": "Zeit",
        "required": "Pflichtfrage",
        "openSheet": "In Google Sheets ansehen",
        "acceptResponses": "Antworten möglich",
        "copyFormLink": "Teilnehmerlink kopieren",
        "shareThisForm": "Freigeben",
    },
    "fr": {
        "qTypeTitleDescription": "titre et une description",
        "responderInput": "Informations saisies par le participant",
    },
}

LOCALE_CONFIG = {
    "pt_BR": {"target": "pt", "arb_locale": "pt_BR"},
    "id": {"target": "id", "arb_locale": "id"},
    "ru": {"target": "ru", "arb_locale": "ru"},
    "de": {"target": "de", "arb_locale": "de"},
    "fr": {"target": "fr", "arb_locale": "fr"},
}

# ICU plural strings must keep valid syntax (auto-translate breaks these).
PLURAL_FIXES: dict[str, dict[str, str]] = {
    "pt_BR": {
        "templateCount": "{count, plural, =1{1 modelo} other{{count} modelos}}",
        "nResponses": "{count, plural, =1{1 resposta} other{{count} respostas}}",
    },
    "de": {
        "templateCount": "{count, plural, =1{1 Vorlage} other{{count} Vorlagen}}",
        "nResponses": "{count, plural, =1{1 Antwort} other{{count} Antworten}}",
    },
    "fr": {
        "templateCount": "{count, plural, =1{1 modèle} other{{count} modèles}}",
        "nResponses": "{count, plural, =1{1 réponse} other{{count} réponses}}",
    },
    "id": {
        "templateCount": "{count, plural, =1{1 templat} other{{count} templat}}",
        "nResponses": "{count, plural, =1{1 tanggapan} other{{count} tanggapan}}",
    },
    "ru": {
        "templateCount": "{count, plural, =1{1 шаблон} other{{count} шаблонов}}",
        "nResponses": "{count, plural, =1{1 ответ} other{{count} ответов}}",
    },
}

LANGUAGE_LABELS = {
    "pt_BR": {
        "languagePortugueseBrazil": "Português (Brasil)",
        "languageIndonesian": "Bahasa Indonesia",
        "languageRussian": "Русский",
        "languageGerman": "Deutsch",
        "languageFrench": "Français",
    },
    "id": {
        "languagePortugueseBrazil": "Português (Brasil)",
        "languageIndonesian": "Bahasa Indonesia",
        "languageRussian": "Русский",
        "languageGerman": "Deutsch",
        "languageFrench": "Français",
    },
    "ru": {
        "languagePortugueseBrazil": "Português (Brasil)",
        "languageIndonesian": "Bahasa Indonesia",
        "languageRussian": "Русский",
        "languageGerman": "Deutsch",
        "languageFrench": "Français",
    },
    "de": {
        "languagePortugueseBrazil": "Português (Brasil)",
        "languageIndonesian": "Bahasa Indonesia",
        "languageRussian": "Русский",
        "languageGerman": "Deutsch",
        "languageFrench": "Français",
    },
    "fr": {
        "languagePortugueseBrazil": "Português (Brasil)",
        "languageIndonesian": "Bahasa Indonesia",
        "languageRussian": "Русский",
        "languageGerman": "Deutsch",
        "languageFrench": "Français",
    },
}

# Keys that must stay untranslated (placeholders, brands, formats).
SKIP_TRANSLATE = {
    "appName",
    "languageEnglish",
    "languageJapanese",
    "languageSimplifiedChinese",
    "languageTraditionalChinese",
    "dateFormatWithYear",
    "dateFormatNoYear",
    "timeFormatDuration",
    "timeFormatStandard",
    "gmailHint",
    "exportXlsx",
    "exportCsv",
    "sheets",
    "version",
}

PLACEHOLDER_RE = re.compile(r"\{[^}]+\}")


def load_en() -> dict:
    return json.loads(EN_PATH.read_text(encoding="utf-8"))


def is_translatable_key(key: str) -> bool:
    return not key.startswith("@") and key != "@@locale"


def protect_placeholders(text: str) -> tuple[str, list[str]]:
    tokens: list[str] = []

    def repl(match: re.Match[str]) -> str:
        tokens.append(match.group(0))
        return f"__PH{len(tokens) - 1}__"

    protected = PLACEHOLDER_RE.sub(repl, text)
    return protected, tokens


def restore_placeholders(text: str, tokens: list[str]) -> str:
    for i, token in enumerate(tokens):
        text = text.replace(f"__PH{i}__", token)
    return text


def translate_text(text: str, translator: GoogleTranslator) -> str:
    if not text or text.strip() == "":
        return text
    protected, tokens = protect_placeholders(text)
    # Skip pure format / technical strings.
    if protected.replace("_", "").replace(" ", "").isalnum() and "{" not in text:
        if re.fullmatch(r"[A-Z0-9./:\-–]+", text):
            return text
    try:
        translated = translator.translate(protected)
    except Exception:
        time.sleep(1)
        translated = translator.translate(protected)
    return restore_placeholders(translated, tokens)


def build_locale_arb(en_data: dict, locale_code: str) -> dict:
    config = LOCALE_CONFIG[locale_code]
    translator = GoogleTranslator(source="en", target=config["target"])
    overrides = GOOGLE_OVERRIDES.get(locale_code, {})
    plural_fixes = PLURAL_FIXES.get(locale_code, {})
    labels = LANGUAGE_LABELS[locale_code]

    out: dict = {"@@locale": config["arb_locale"]}
    cache: dict[str, str] = {}

    for key, value in en_data.items():
        if key == "@@locale":
            continue
        if key.startswith("@"):
            out[key] = deepcopy(value)
            continue

        if key in labels:
            out[key] = labels[key]
            continue

        if key in overrides:
            out[key] = overrides[key]
            continue

        if key in plural_fixes:
            out[key] = plural_fixes[key]
            continue

        if key in SKIP_TRANSLATE:
            out[key] = value
            continue

        if value in cache:
            out[key] = cache[value]
        else:
            translated = translate_text(value, translator)
            cache[value] = translated
            out[key] = translated
            time.sleep(0.05)

    out.update(labels)
    return out


def patch_existing_ja() -> None:
    ja_path = L10N / "app_ja.arb"
    data = json.loads(ja_path.read_text(encoding="utf-8"))
    for key, value in GOOGLE_OVERRIDES["ja"].items():
        data[key] = value
    for key, value in LANGUAGE_LABELS["pt_BR"].items():
        if key not in data:
            data[key] = value
    ja_path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def patch_en_labels() -> None:
    data = load_en()
    labels = LANGUAGE_LABELS["pt_BR"]
    for key, value in labels.items():
        data[key] = value
    EN_PATH.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def patch_zh_labels() -> None:
    for name in ("app_zh.arb", "app_zh_Hant.arb"):
        path = L10N / name
        data = json.loads(path.read_text(encoding="utf-8"))
        for key, value in LANGUAGE_LABELS["pt_BR"].items():
            data[key] = value
        path.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )


def main() -> None:
    patch_en_labels()
    en_data = load_en()
    patch_zh_labels()
    patch_existing_ja()

    for locale_code in LOCALE_CONFIG:
        print(f"Generating app_{locale_code}.arb ...")
        arb = build_locale_arb(en_data, locale_code)
        out_path = L10N / f"app_{locale_code}.arb"
        out_path.write_text(
            json.dumps(arb, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print(f"  Wrote {out_path.name}")

    # Re-apply Category 10 Google Drive list terms after generation.
    from patch_cat10_google_terms import main as patch_cat10

    patch_cat10()
    print("Done.")


if __name__ == "__main__":
    main()
