@echo off
chcp 65001 >nul
rem Сборка карт регионов. Запускать в папке, где лежат planetiler.jar и скачанные файлы .osm.pbf.
rem Перед каждой сборкой проверяется, что исходный файл настоящий (не Монако из примера planetiler).
rem Если файла нет, сборка региона пропускается, а не подменяется данными Монако.

call :build central-fed-district-latest.osm.pbf 100000000 moscow-tula  "--bounds=35.0,53.0,40.4,57.0"
call :build central-fed-district-latest.osm.pbf 100000000 voronezh     "--bounds=38.0,49.4,43.0,52.3"
call :build south-fed-district-latest.osm.pbf   50000000  south        "--bounds=36.6,43.3,44.4,50.3"
call :build north-caucasus-fed-district-latest.osm.pbf 20000000 north-caucasus ""
call :build crimean-fed-district-latest.osm.pbf 10000000  crimea       ""
call :build georgia-latest.osm.pbf              10000000  south-ossetia "--bounds=43.3,41.9,44.9,42.8"
echo.
echo Готово. Размеры результата:
for %%F in (*.pmtiles) do echo   %%F  %%~zF байт
goto :eof

:build
rem %1 исходный файл, %2 минимальный размер в байтах, %3 имя результата, %4 доп. флаги
if not exist "%~1" (
  echo [ПРОПУСК] %~3: нет файла %~1 - скачайте его с download.geofabrik.de
  goto :eof
)
for %%A in ("%~1") do set SZ=%%~zA
if %SZ% LSS %~2 (
  echo [ПРОПУСК] %~3: файл %~1 слишком маленький ^(%SZ% байт^) - это не тот файл, перекачайте
  goto :eof
)
echo [СБОРКА] %~3 из %~1
java -Xmx4g -jar planetiler.jar --download --force --osm-path=%~1 %~4 --output=%~3.pmtiles --maxzoom=14
if errorlevel 1 echo [ОШИБКА] %~3
for %%A in ("%~3.pmtiles") do if %%~zA LSS 1000000 echo [ВНИМАНИЕ] %~3.pmtiles меньше 1 МБ - скорее всего, данные не те
goto :eof
