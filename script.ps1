param (
    [Parameter(Mandatory=$true)]
    [int]
    $startIndex,

    [Parameter(Mandatory=$true)]
    [int]
    $endIndex
)

function Merge-Video-Audio-Subtitle ([int]$start, [int]$end) {
    Write-Output "Created by Alexey Ivashkin. v1.1.1"

    $originalAudioParam = "-A"

    for ($i = $start; $i -le $end; $i++) {
        # обработчик если номер серии всегда состоит из двух цифр
        # закомментировать или изменить количествно нулей по необходимости
        if ($i -lt 10) {
            $number = "0$i"
        } else {
            $number = $i
        }

        # путь до файла вывода
        $outPath = "D:\Titles\Alchemist/Fullmetal.Alchemist.Brotherhood.2009.E$number.mkv"
        # путь до видеоряда
        $videoPath = "D:\Titles\Fullmetal.Alchemist.Brotherhood.2009.MVO.STEPonee\Fullmetal.Alchemist.Brotherhood.2009.E$number.MVO.STEPonee.mp4"
        # путь до аудиофайла
        $audioPath = "D:\Titles\[mottoj] Fullmetal Alchemist Brotherhood (BDRip 1280x720 HEVC AAC)\[Audio]\[mottoj] Fullmetal Alchemist Brotherhood - $number (BDRip 1280x720 HEVC AAC).СВ-Дубль.mka"
        # путь до файла субтитров
        $subtitlePath = "D:\Titles\Fullmetal.Alchemist.Brotherhood.2009.MVO.STEPonee\Fullmetal.Alchemist.Brotherhood.2009.E$number.MVO.STEPonee.ass"

        $progress = [math]::Round((($number - $start)/($end - $start + 1)) * 100, 1)
        Write-Progress -Activity "Working.." -Status "$progress%           Merging in $outPath..." -PercentComplete $progress

        # сам merge
        # из-за специфики запуска программ через *это*, настройки через параметры не удались. Поэтому всё делаем ручками.
        # если нужна оригинальная аудиодорожка, убираем "$originalAudioParam"
        # если не нужен видеоряд, то убираем "$originalAudioParam $videoPath" (да, оба)
        # если не нужно внешнее аудио, то убираем "$audioPath"
        # если не нужны внешние субтитры, то убираем "$subtitlePath"
        .\mkvmerge.exe -q -o $outPath $originalAudioParam $videoPath $audioPath $subtitlePath
    }
    Write-Progress -Completed
}

Merge-Video-Audio-Subtitle -start $startIndex -end $endIndex
