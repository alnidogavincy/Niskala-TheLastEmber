"""Package distributable builds and source without caches, toolchains, or signing keys."""
from pathlib import Path
import zipfile, hashlib
root=Path(__file__).resolve().parents[1]
out=root/'builds'
with zipfile.ZipFile(out/'Niskala-Windows.zip','w',zipfile.ZIP_DEFLATED) as z:
    z.write(out/'windows/Niskala.exe','Niskala/Niskala.exe')
    for file in [root/'docs/PLAY.txt',root/'docs/VALIDATION.md',root/'docs/GODOT_LICENSE.txt',root/'docs/ASSETS.md',root/'assets/Nunito-OFL.txt']:
        z.write(file,'Niskala/'+file.name)
with zipfile.ZipFile(out/'Niskala-Source.zip','w',zipfile.ZIP_DEFLATED) as z:
    for name in ['assets','scripts','scenes','art_source','docs']:
        for file in (root/name).rglob('*'):
            if file.is_file(): z.write(file, 'Niskala/'+file.relative_to(root).as_posix())
    for name in ['project.godot','export_presets.cfg','README.md','.gitignore']:
        z.write(root/name,'Niskala/'+name)
    for file in (root/'tools').iterdir():
        if file.is_file() and file.suffix in ['.gd','.py']:
            z.write(file,'Niskala/tools/'+file.name)
    z.write(root/'tools/.gdignore','Niskala/tools/.gdignore')
files=[out/'Niskala-Windows.zip',out/'Niskala-Source.zip',out/'android/Niskala.apk',out/'windows/Niskala.exe']
(out/'SHA256SUMS.txt').write_text('\n'.join(hashlib.sha256(f.read_bytes()).hexdigest()+'  '+str(f.relative_to(out)) for f in files)+'\n')
for f in files: print(f.name, f.stat().st_size)
