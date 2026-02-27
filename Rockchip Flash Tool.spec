# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['rk_flash_tool/__main__.py'],
    pathex=[],
    binaries=[],
    datas=[('tools', 'tools'), ('rkbin', 'rkbin')],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='Rockchip Flash Tool',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch='universal2',
    codesign_identity=None,
    entitlements_file=None,
    icon=['assets/icon.icns'],
)
coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='Rockchip Flash Tool',
)
app = BUNDLE(
    coll,
    name='Rockchip Flash Tool.app',
    icon='assets/icon.icns',
    bundle_identifier=None,
)
