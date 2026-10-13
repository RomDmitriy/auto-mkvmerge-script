#!/usr/bin/env bash
#
# Использование: ./merge.sh <startIndex> <endIndex>
#   startIndex — номер серии, с которой начать. Даже если номер состоит из двух цифр (например, "01", пишем 1)
#   endIndex   — номер серии, на которой закончить (включительно)

set -uo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <startIndex> <endIndex>" >&2
    exit 1
fi

if [[ ! $1 =~ ^[0-9]+$ || ! $2 =~ ^[0-9]+$ ]]; then
    echo "Error: episode indexes must be non-negative integers" >&2
    exit 1
fi

# 10# — чтобы "08" и "09" не воспринимались bash как восьмеричные числа
start_index=$((10#$1))
end_index=$((10#$2))

if (( start_index > end_index )); then
    echo "Error: startIndex is more than endIndex" >&2
    exit 1
fi

# путь до mkvmerge (можно переопределить: MKVMERGE=/path/to/mkvmerge ./merge.sh 1 12)
MKVMERGE="${MKVMERGE:-mkvmerge}"

if ! command -v "$MKVMERGE" >/dev/null 2>&1; then
    echo "Error: mkvmerge is not found ($MKVMERGE)" >&2
    exit 1
fi

total=$((end_index - start_index + 1))
failed=0

for ((i = start_index; i <= end_index; i++)); do
    # номер серии всегда из двух цифр; поменять %02d на %03d / %d по необходимости
    printf -v number '%02d' "$i"

    # ПУТИ УКАЗЫВАТЬ ЧЕРЕЗ "/"!
    # Внутри кавычек "~" НЕ раскрывается в домашнюю папку — используем $HOME

    # путь до файла вывода
    out_path="$HOME/Movies/Chou Kaguya-hime [1080p].mkv"
    # путь до видеоряда
    video_path="$HOME/Movies/Chou Kaguya-hime [WEB-DL 1080p]/Chou Kaguya-hime (2026) $number [WEB-DL NF AVC DDP 1080p].mkv"
    # пути до аудиофайлов
    audio_path_primary="$HOME/Movies/Chou Kaguya-hime [WEB-DL 1080p]/RUS Sound/Chou Kaguya-hime (2026) [WEB-DL NF AVC DDP 1080p].dub.rus.mka"
    audio_path_secondary="$HOME/Movies/Chou Kaguya-hime [WEB-DL 1080p]/ENG Sound/Chou Kaguya-hime (2026) [WEB-DL NF AVC DDP 1080p].dub.eng.mka"
    # пути до файлов субтитров
    subtitle_path="$HOME/Movies/Chou Kaguya-hime [WEB-DL 1080p]/RUS Subs/Chou Kaguya-hime (2026) [WEB-DL NF AVC DDP 1080p].full.nf.rus.ass"
    subtitle_inscriptions_path="$HOME/Movies/Chou Kaguya-hime [WEB-DL 1080p]/RUS Subs/Chou Kaguya-hime (2026) [WEB-DL NF AVC DDP 1080p].signs.nf.rus.ass"

    mkdir -p "$(dirname "$out_path")"

    progress=$(( (i - start_index) * 100 / total ))
    printf '\r\033[K[%3d%%] (%d/%d) %s...' "$progress" "$((i - start_index + 1))" "$total" "${out_path##*/}"

    # сам merge
    # Ненужное просто закомментировать строкой целиком:
    #   -A — убрать оригинальное аудио, -S — убрать оригинальные субтитры
    #   (оба флага относятся к следующему за ними файлу, т.е. к видеоряду)
    # P.S. Изначально выбираемой дорожкой становится аудио, которое указано раньше, а субтитры — последними
    args=(
        -q -o "$out_path"
        -A
        -S
        "$video_path"
        --language 0:rus "$audio_path_primary"
        --language 0:eng "$audio_path_secondary"
        --language 0:rus --track-name "0:Субтитры" "$subtitle_path"
        --language 0:rus --track-name "0:Надписи" "$subtitle_inscriptions_path"
    )

    "$MKVMERGE" "${args[@]}"
    rc=$?

    # коды выхода mkvmerge: 0 — успех, 1 — предупреждения, 2 — ошибка
    if (( rc == 2 )); then
        printf '\nFailed to process the episodes %s\n' "$number" >&2
        failed=$((failed + 1))
    elif (( rc == 1 )); then
        printf '\nEpisode %s: mkvmerge finished with warnings\n' "$number" >&2
    fi
done

printf '\r\033[K[100%%] Ready!\n'

if (( failed > 0 )); then
    echo "Failed to process the episodes: $failed" >&2
    exit 1
fi
