@echo off
rem Build region maps. Run in the folder with planetiler.jar and the downloaded .osm.pbf files.
rem Each build is skipped if the source file is missing or too small (planetiler would otherwise
rem silently download Monaco sample data instead).

call :build central-fed-district-latest.osm.pbf 100000000 moscow-tula "--bounds=35.0,53.0,40.4,57.0"
call :build central-fed-district-latest.osm.pbf 100000000 voronezh "--bounds=38.0,49.4,43.0,52.3"
call :build south-fed-district-latest.osm.pbf 50000000 south "--bounds=36.6,43.3,44.4,50.3"
call :build north-caucasus-fed-district-latest.osm.pbf 20000000 north-caucasus ""
call :build crimean-fed-district-latest.osm.pbf 10000000 crimea ""
call :build georgia-latest.osm.pbf 10000000 south-ossetia "--bounds=43.3,41.9,44.9,42.8"
echo.
echo Done. Output sizes:
for %%F in (*.pmtiles) do echo   %%F  %%~zF bytes
goto :eof

:build
rem args: 1 source file, 2 min size in bytes, 3 output name, 4 extra flags
if not exist "%~1" goto :nofile
set SZ=0
for %%A in ("%~1") do set SZ=%%~zA
if %SZ% LSS %~2 goto :small
echo [BUILD] %~3 from %~1
java -Xmx4g -jar planetiler.jar --download --force --osm-path=%~1 %~4 --output=%~3.pmtiles --maxzoom=14
if errorlevel 1 echo [ERROR] %~3 failed
if exist "%~3.pmtiles" for %%A in ("%~3.pmtiles") do if %%~zA LSS 1000000 echo [WARNING] %~3.pmtiles is under 1 MB - the data is probably wrong
goto :eof

:nofile
echo [SKIP] %~3: file %~1 not found - download it from download.geofabrik.de
goto :eof

:small
echo [SKIP] %~3: file %~1 is too small, %SZ% bytes - wrong file, download it again
goto :eof
