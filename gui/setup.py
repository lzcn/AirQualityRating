from distutils.core import setup
import py2exe

DATA = [('imageformats',
    ['D:\\Python/Python27/Lib/site-packages/PyQt4/plugins/imageformats/qjpeg4.dll',
    'D:\\Python/Python27/Lib/site-packages/PyQt4/plugins/imageformats/qgif4.dll',
    'D:\\Python/Python27/Lib/site-packages/PyQt4/plugins/imageformats/qico4.dll',
    'D:\\Python/Python27/Lib/site-packages/PyQt4/plugins/imageformats/qmng4.dll',
    'D:\\Python/Python27/Lib/site-packages/PyQt4/plugins/imageformats/qsvg4.dll',
    'D:\\Python/Python27/Lib/site-packages/PyQt4/plugins/imageformats/qtiff4.dll'
    ])]
py2exe_options = {
    "includes": ["sip"],
    "dll_excludes": ["MSVCP90.dll",],
    "compressed": 1,
    "optimize": 2,
    "ascii": 0,
}
setup(
    name = 'Aqi Test',
    version = '1.0',
	options = {'py2exe': py2exe_options},
	windows = ['main.py'],
	data_files = DATA
    )
