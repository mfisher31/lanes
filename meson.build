project ('lanes', ['c'], 
    version : '2.1', 
    default_options : [
        'c_std=c99',
        'buildtype=release'
    ])

cc = meson.get_compiler('c')

luadir = ''
luacdir = ''

lua_dep = dependency ('luajit', version: ['>=2.1',  '<3.0'], required: true)

if lua_dep.found()
    luadir = 'share' / 'lua' / '5.1'
    luacdir = 'lib'/ 'lua' / '5.1'
endif

if not lua_dep.found()
    lua_versions = [
        { 'subdir': '5.1', 'check': '>= 5.1 and < 5.1' },
        { 'subdir': '5.2', 'check': '>= 5.2 and < 5.2' },
        { 'subdir': '5.3', 'check': '>= 5.3 and < 5.4' },
        { 'subdir': '5.4', 'check': '>= 5.4 and < 5.5' },
    ]
    
    foreach map: lua_versions
        if not lua_dep.found()
            lua_dep = dependency ('lua', version:map.get('check'), required: false)
            luadir = 'share' / 'lua' / map.get('subdir')
            luacdir = 'share' / 'lua' / map.get('subdir')
        endif    
    endforeach
endif

assert(lua_dep.found(), 'Could not find a lua version to use')

lanes_source = '''
    src/cancel.c
    src/compat.c
    src/deep.c
    src/keeper.c
    src/lanes.c
    src/linda.c
    src/state.c
    src/threading.c
    src/tools.c
    src/universe.c
'''.split()

if host_machine.system() =='linux'
    add_project_arguments ('''
        -D_GNU_SOURCE
        -Wno-unused-const-variable
        -Wno-unused-variable
    '''.split(), language: 'c')
endif

install_data('src/lanes.lua', install_dir: luadir)
shared_module ('core', lanes_source, 
    name_prefix: '',
    dependencies: [ lua_dep ],
    install: true,
    install_dir: luacdir / 'lanes')

summary ('PATH', get_option('prefix') / luadir, section: 'Install')
summary ('CPATH', get_option('prefix') / luacdir, section: 'Install')
