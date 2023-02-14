param ($startIndex, $endIndex)

function Merge-Video-Audio-Subtitle ([int]$start, [int]$end, [boolean]$mergeVideo = $true, [string]$mergeAudio = $true, [string]$mergeSubtitle = $true, [boolean]$noOriginalAudio = $true) {
    echo "Created by Alexey Ivashkin."
    for ($i=$start; $i -lt $end; $i++) {
        if ($i -lt 10) {
            $number = "0$i"
        } else {
            $number = $i
        }

        $out = "out/Fullmetal.Alchemist.Brotherhood.2009.E$number.mkv"
        $video = "D:\Titles\Fullmetal.Alchemist.Brotherhood.2009.MVO.STEPonee\Fullmetal.Alchemist.Brotherhood.2009.E$number.MVO.STEPonee.mp4"
        $audio = "D:\Titles\[mottoj] Fullmetal Alchemist Brotherhood (BDRip 1280x720 HEVC AAC)\[Audio]\[mottoj] Fullmetal Alchemist Brotherhood - $number (BDRip 1280x720 HEVC AAC).СВ-Дубль.mka"
        $subtitle = "D:\Titles\Fullmetal.Alchemist.Brotherhood.2009.MVO.STEPonee\Fullmetal.Alchemist.Brotherhood.2009.E$number.MVO.STEPonee.ass"

        $progress = [math]::Round((($number - $start)/($end - $start)) * 100, 1)
        Write-Progress -Activity "Working.." -Status "$progress%                Merging in $out..." -PercentComplete $progress

        if (-not ($mergeVideo)) {
            $video = ""
        }

        if (-not($mergeAudio)) {
            $audio = ""
        }

        if (-not ($mergeSubtitle)) {
            $subtitle = ""
        }

        if ($noOriginalAudio) {
            $originalAudioParameter = "-A"
        }

        .\mkvmerge.exe -q -o $out $originalAudioParameter $video $audio $subtitle
    }
    Write-Progress -Completed
}

Merge-Video-Audio-Subtitle -start $startIndex -end $endIndex