#!/usr/bin/env python3
"""Patch Category 10 (Forms home / Drive list) Google official terms."""
import json
from pathlib import Path

L10N = Path(__file__).resolve().parent.parent / "lib" / "l10n"

# Google Drive / Docs official UI terminology (help docs).
CAT10: dict[str, dict[str, str]] = {
    "app_ja.arb": {
        "tabTemplates": "テンプレート",
        "recentForms": "最近使用したフォーム",
        "noRecentForms": "最近のアイテムはありません",
        "lastModified": "最終更新",
        "lastOpened": "最終閲覧(自分)",
        "ownedByMe": "自分がオーナー",
        "ownedByAnyone": "オーナー指定なし",
        "notOwnedByMe": "自分以外がオーナー",
        "titleAZ": "タイトル",
        "deleteFormTitle": "ゴミ箱に移動しますか？",
        "deleteFormContent": "ゴミ箱に移動されます。",
        "formMovedToTrash": "ゴミ箱に移動しました",
        "duplicate": "コピーを作成",
        "tooltipDuplicate": "コピーを作成",
        "duplicatingForm": "コピーを作成しています…",
        "formDuplicated": "コピーを作成しました",
        "failedToDuplicateForm": "コピーを作成できませんでした",
        "rename": "名前を変更",
        "renameForm": "名前を変更",
        "formRenamed": "名前を変更しました",
        "failedToRename": "名前を変更できませんでした",
    },
    "app_pt_BR.arb": {
        "tabTemplates": "Galeria de modelos",
        "recentForms": "Formulários recentes",
        "noRecentForms": "Nenhum item recente",
        "lastModified": "Modificado",
        "lastOpened": "Aberto por mim",
        "ownedByMe": "De minha propriedade",
        "notOwnedByMe": "Não é de minha propriedade",
        "titleAZ": "Nome",
        "deleteFormTitle": "Mover para a lixeira?",
        "deleteFormContent": "Este formulário será movido para a lixeira.",
        "formMovedToTrash": "Movido para a lixeira",
        "duplicate": "Fazer uma cópia",
        "tooltipDuplicate": "Fazer uma cópia",
        "duplicatingForm": "Criando uma cópia…",
        "formDuplicated": "Cópia criada",
        "failedToDuplicateForm": "Falha ao criar uma cópia",
        "rename": "Renomear",
        "renameForm": "Renomear",
        "formRenamed": "Renomeado",
        "failedToRename": "Falha ao renomear",
    },
    "app_pt.arb": {},  # filled from pt_BR below
    "app_id.arb": {
        "tabTemplates": "Galeri Template",
        "recentForms": "Formulir terbaru",
        "noRecentForms": "Tidak ada formulir terbaru",
        "lastModified": "Terakhir diubah",
        "lastOpened": "Terakhir dibuka saya",
        "ownedByMe": "Milik saya",
        "notOwnedByMe": "Bukan milik saya",
        "titleAZ": "Nama",
        "deleteFormTitle": "Pindahkan ke Sampah?",
        "deleteFormContent": "Formulir ini akan dipindahkan ke Sampah.",
        "formMovedToTrash": "Dipindahkan ke Sampah",
        "duplicate": "Buat salinan",
        "tooltipDuplicate": "Buat salinan",
        "duplicatingForm": "Membuat salinan…",
        "formDuplicated": "Salinan dibuat",
        "failedToDuplicateForm": "Gagal membuat salinan",
        "rename": "Ganti nama",
        "renameForm": "Ganti nama",
        "formRenamed": "Nama diganti",
        "failedToRename": "Gagal mengganti nama",
    },
    "app_ru.arb": {
        "tabTemplates": "Галерея шаблонов",
        "recentForms": "Недавние формы",
        "noRecentForms": "Нет недавних элементов",
        "lastModified": "Последнее изменение",
        "lastOpened": "Последнее открытие мной",
        "ownedByMe": "Принадлежит мне",
        "notOwnedByMe": "Не принадлежит мне",
        "titleAZ": "Название",
        "deleteFormTitle": "Переместить в корзину?",
        "deleteFormContent": "Форма будет перемещена в корзину.",
        "formMovedToTrash": "Перемещено в корзину",
        "duplicate": "Создать копию",
        "tooltipDuplicate": "Создать копию",
        "duplicatingForm": "Создание копии…",
        "formDuplicated": "Копия создана",
        "failedToDuplicateForm": "Не удалось создать копию",
        "rename": "Переименовать",
        "renameForm": "Переименовать",
        "formRenamed": "Переименовано",
        "failedToRename": "Не удалось переименовать",
    },
    "app_de.arb": {
        "tabTemplates": "Vorlagengalerie",
        "recentForms": "Zuletzt verwendete Formulare",
        "noRecentForms": "Keine zuletzt verwendeten Elemente",
        "lastModified": "Geändert",
        "lastOpened": "Zuletzt von mir geöffnet",
        "ownedByMe": "Von mir",
        "notOwnedByMe": "Nicht von mir",
        "titleAZ": "Name",
        "deleteFormTitle": "In den Papierkorb verschieben?",
        "deleteFormContent": "Dieses Formular wird in den Papierkorb verschoben.",
        "formMovedToTrash": "In den Papierkorb verschoben",
        "duplicate": "Kopie erstellen",
        "tooltipDuplicate": "Kopie erstellen",
        "duplicatingForm": "Kopie wird erstellt…",
        "formDuplicated": "Kopie erstellt",
        "failedToDuplicateForm": "Kopie konnte nicht erstellt werden",
        "rename": "Umbenennen",
        "renameForm": "Umbenennen",
        "formRenamed": "Umbenannt",
        "failedToRename": "Umbenennen fehlgeschlagen",
    },
    "app_fr.arb": {
        "tabTemplates": "Galerie de modèles",
        "recentForms": "Formulaires récents",
        "noRecentForms": "Aucun élément récent",
        "lastModified": "Modifié",
        "lastOpened": "Dernière ouverture par moi",
        "ownedByMe": "Possédé par moi",
        "notOwnedByMe": "Ne m'appartient pas",
        "titleAZ": "Nom",
        "deleteFormTitle": "Placer dans la corbeille ?",
        "deleteFormContent": "Ce formulaire sera placé dans la corbeille.",
        "formMovedToTrash": "Placé dans la corbeille",
        "duplicate": "Créer une copie",
        "tooltipDuplicate": "Créer une copie",
        "duplicatingForm": "Création d'une copie…",
        "formDuplicated": "Copie créée",
        "failedToDuplicateForm": "Impossible de créer une copie",
        "rename": "Renommer",
        "renameForm": "Renommer",
        "formRenamed": "Renommé",
        "failedToRename": "Échec du renommage",
    },
}

CAT10["app_pt.arb"] = dict(CAT10["app_pt_BR.arb"])


def main() -> None:
    for filename, patches in CAT10.items():
        path = L10N / filename
        data = json.loads(path.read_text(encoding="utf-8"))
        for key, value in patches.items():
            data[key] = value
        path.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print(f"Patched {filename} ({len(patches)} keys)")


if __name__ == "__main__":
    main()
