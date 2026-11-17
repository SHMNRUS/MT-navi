# Карты регионов для приложения

Приложение (кнопка «Карты регионов») берёт список из `regions.json` и качает файлы `.pmtiles` по ссылкам из него.

## 1. Сделать файл региона
Нужен слой `transportation` схемы OpenMapTiles, уровни до 14. Его делает [planetiler](https://github.com/onthegomap/planetiler) (нужна Java 21+):

    java -Xmx4g -jar planetiler.jar --download --area=<область из Geofabrik> --output=moscow.pmtiles --maxzoom=14

Названия областей и флаги проверьте по документации planetiler: у меня они не проверены. Можно собрать и из своего `.osm.pbf` (`--osm-path=...`).

Для Windows есть `build_regions.bat`: кладёте рядом с `planetiler.jar` и скачанными `.osm.pbf`, запускаете. Он собирает все регионы и пропускает те, для которых нет настоящего исходного файла (planetiler при `--download` и отсутствующем файле молча берёт данные Монако).

## 2. Выложить файл
Релиз в этом репозитории: Releases → Draft a new release → метка `maps-1` → приложить `moscow.pmtiles` (до 2 ГБ на файл).
Ссылка будет вида `https://github.com/SHMNRUS/MT-navi/releases/download/maps-1/moscow.pmtiles`.
Репозиторий должен быть публичным: загрузчик Android не авторизуется, у приватного репозитория ссылки не откроются.

## 3. Добавить в список
    python3 maps/add_region.py moscow.pmtiles --name "Москва и область" --url <ссылка из шага 2>

Скрипт проверяет формат, считает размер и `sha256` и дописывает запись в `regions.json`. Закоммитьте файл.

## 4. В приложении
Ссылка на список (после слияния в `main`):

    https://raw.githubusercontent.com/SHMNRUS/MT-navi/main/maps/regions.json

«Карты регионов» → вставить ссылку → «Обновить список» → «Скачать».

Данные карты © OpenStreetMap contributors (ODbL).
