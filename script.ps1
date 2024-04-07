param (
    [Parameter(Mandatory=$true)]
    [int]
    $startIndex, # Номер серии, с которой начать. Даже если номер состоит из двух цифр (например, "01", пишем 1)

    [Parameter(Mandatory=$true)]
    [int]
    $endIndex # Номер серии, на которой закончить (включительно). Даже если номер состоит из двух цифр (например, "01", пишем 1)
)

$removeOriginalSound = "-A"
$removeOriginalSubs = "-S"

for ($i = $startIndex; $i -le $endIndex; $i++) {
    # обработчик если номер серии всегда состоит из двух цифр
    # закомментировать или изменить количествно нулей по необходимости
    if ($i -lt 10) {
        $number = "0$i"
    } else {
        $number = $i
    }

    # ПУТИ УКАЗЫВАТЬ ЧЕРЕЗ "\"!

    # путь до файла вывода
    $outPath = "D:\Titles\Haiyore! Nyaruko-san W\[Yousei-raws] Haiyore! Nyaruko-san W $number [BDrip 1920x1080 x264 FLAC].mkv"
    # путь до видеоряда
    $videoPath = "D:\Titles\Haiyore! Nyaruko-san W [BDRip] [1080p]\[Yousei-raws] Haiyore! Nyaruko-san W $number [BDrip 1920x1080 x264 FLAC].mkv"
    # путь до аудиофайлов
    $audioPathPrimary = "D:\Titles\Haiyore! Nyaruko-san W [BDRip] [1080p]\RUS Sound\[ShadMG & Лизавета]\[Yousei-raws] Haiyore! Nyaruko-san W $number [BDrip 1920x1080 x264 FLAC].mka"
    $audioPathSecondary = "D:\Titles\Haiyore! Nyaruko-san W [BDRip] [1080p]\RUS Sound\[ShadMG & Лизавета]\[Yousei-raws] Haiyore! Nyaruko-san W $number [BDrip 1920x1080 x264 FLAC].mka"
    # путь до файла субтитров
    $subtitlePath = "D:\Titles\Haiyore! Nyaruko-san W [BDRip] [1080p]\RUS Subs\[Yousei-raws] Haiyore! Nyaruko-san W $number [BDrip 1920x1080 x264 FLAC].ass"
    $subtitleInscriptionsPath = "D:\Titles\Haiyore! Nyaruko-san W [BDRip] [1080p]\RUS Subs\надписи\[Yousei-raws] Haiyore! Nyaruko-san W $number [BDrip 1920x1080 x264 FLAC].ass"

    $progress = [math]::Round((($number - $startIndex) / ($endIndex - $startIndex + 1)) * 100, 1)
    $outFile = $outPath.Split("\")[-1]
    Write-Progress -Activity "Working.." -Status "$progress%      $outFile..." -PercentComplete $progress

    # сам merge
    # из-за специфики запуска программ через *это*, настройки через параметры не удались. Поэтому всё делаем ручками.
    # если нужна оригинальная аудиодорожка, убираем "$removeOriginalSound"
    # если не нужно внешнее аудио, то убираем "--language 0:rus $audioPathPrimary"
    # если нужна лишь одна аудиодорожка (только primary), то убираем "--language 0:eng $audioPathSecondary"
    # если не нужны внешние субтитры, то убираем "--language 0:rus --track-name 0:"Субтитры" $subtitlePath"
    # если не нужны надписи, то убираем "--language 0:rus --track-name 0:"Надписи" $subtitleInscriptionsPath"
    # P.S. Изначально выбираемой дорожкой становится аудио, которое указано в параметрах раньше, а субтитры - последними
    .\mkvmerge.exe -q -o $outPath $removeOriginalSound $removeOriginalSubs $videoPath --language 0:rus $audioPathPrimary --language 0:eng $audioPathSecondary --language 0:rus --track-name 0:"Субтитры" $subtitlePath --language 0:rus --track-name 0:"Надписи" $subtitleInscriptionsPath
}
Write-Progress -Activity "Ready!" -Completed
