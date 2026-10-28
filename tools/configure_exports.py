from pathlib import Path
import zipfile, subprocess

root=Path(__file__).resolve().parents[1]
target=root/'tools/godot/editor_data/export_templates/4.5.1.stable'
target.mkdir(parents=True,exist_ok=True)
if (root/'tools/templates.zip').exists():
    with zipfile.ZipFile(root/'tools/templates.zip') as z:
        for info in z.infolist():
            name=Path(info.filename).name
            if name in ['windows_release_x86_64.exe','windows_debug_x86_64.exe','android_debug.apk','android_release.apk','version.txt']:
                (target/name).write_bytes(z.read(info))
elif not (target/'android_debug.apk').exists():
    raise SystemExit('Download Godot 4.5.1 export templates to tools/templates.zip first.')
sdk=root/'tools/android/sdk'
jdk=next((root/'tools/android/jdk').iterdir())
key=root/'tools/android/debug.keystore'
if not key.exists():
    subprocess.run([str(jdk/'bin/keytool.exe'),'-genkeypair','-keystore',str(key),'-alias','androiddebugkey','-storepass','android','-keypass','android','-dname','CN=Android Debug,O=Android,C=US','-keyalg','RSA','-keysize','2048','-validity','10000'],check=True)
settings=root/'tools/godot/editor_data/editor_settings-4.5.tres'
text=settings.read_text()
entries={'export/android/java_sdk_path':jdk.as_posix(),'export/android/android_sdk_path':sdk.as_posix(),'export/android/debug_keystore':key.as_posix(),'export/android/debug_keystore_user':'androiddebugkey','export/android/debug_keystore_pass':'android'}
lines=text.splitlines()
for k,v in entries.items():
    lines=[line for line in lines if not line.startswith(k+' =')]
    lines.append(f'{k} = "{v}"')
settings.write_text('\n'.join(lines)+'\n')
for platform in ['windows','android']:
    (root/'builds'/platform).mkdir(exist_ok=True)
print('Godot 4.5.1 export templates and local Android paths configured.')
