"""Reproducible scene wrappers, original UI artwork, synthesized audio, ORA packaging."""
from pathlib import Path
import math, wave, zipfile, xml.etree.ElementTree as ET
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
for name, node, script in [('player','CharacterBody2D','player'), ('enemy','CharacterBody2D','enemy'), ('boss','CharacterBody2D','enemy'), ('altar','Area2D','altar'), ('level','Node2D','level'), ('hud','CanvasLayer','hud'), ('menu','CanvasLayer',None)]:
    content = '[gd_scene load_steps=2 format=3]\n' if script else '[gd_scene format=3]\n'
    if script:
        content += f'[ext_resource type="Script" path="res://scripts/{script}.gd" id="1"]\n'
    content += f'[node name="{name.title()}" type="{node}"]\n'
    if script: content += 'script = ExtResource("1")\n'
    if name == 'boss': content += 'kind = "boss"\n'
    (ROOT/'scenes'/f'{name}.tscn').write_text(content)

glyphs = {
    'N':'M4 90V10L48 90V10', 'I':'M14 10H42M28 10V90M14 90H42',
    'S':'M50 10H10V47H47V90H6', 'K':'M7 10V90M50 10L9 53L52 90',
    'A':'M3 90L28 8L53 90M15 59H40', 'L':'M8 10V90H50'}
paths=[]
for i,c in enumerate('NISKALA'):
    paths.append(f'<path transform="translate({i*67+10},0)" d="{glyphs[c]}"/>')
svg='<svg xmlns="http://www.w3.org/2000/svg" width="490" height="110" viewBox="0 0 490 110"><g fill="none" stroke="#f2e7ca" stroke-width="7" stroke-linejoin="miter">'+''.join(paths)+'</g><path d="M188 8L194 0L200 8L194 18Z" fill="#efb963"/></svg>'
(ROOT/'assets/logo.svg').write_text(svg)
icons={'left':'M52 22L28 40L52 58', 'right':'M28 22L52 40L28 58', 'jump':'M23 47L40 27L57 47M40 27V60', 'attack':'M45 18Q55 35 48 41Q63 53 44 64Q20 59 29 43Q42 30 45 18'}
for action, path in icons.items():
    (ROOT/'assets'/f'touch_{action}.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="80" height="80"><circle cx="40" cy="40" r="37" fill="#123a3a" fill-opacity=".72" stroke="#a2b5a0" stroke-width="2"/><path d="{path}" fill="none" stroke="#f5d297" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/></svg>')

audio=ROOT/'assets/audio'
audio.mkdir(exist_ok=True)
RATE=22050
rng=np.random.default_rng(43)
def save(name, data, loop=False):
    data=np.clip(data,-.95,.95)
    with wave.open(str(audio/f'{name}.wav'),'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(RATE)
        w.writeframes((data*32767).astype('<i2').tobytes())
    if loop:
        (audio/f'{name}.wav.import').write_text('[remap]\nimporter="wav"\ntype="AudioStreamWAV"\n\n[deps]\n\n[params]\nedit/loop_mode=2\nedit/loop_begin=0\nedit/loop_end=-1\n')
for name in ['forest','boss']:
    dur=32; t=np.arange(RATE*dur)/RATE; data=np.zeros_like(t)
    chords=[[146.83,174.61,220],[130.81,164.81,196],[110,146.83,174.61],[130.81,174.61,220]]
    for i,chord in enumerate(chords):
        start=i*8*RATE; tt=np.arange(8*RATE)/RATE
        env=np.minimum(tt/1.5,1)*np.minimum((8-tt)/1.5,1)
        for f in chord: data[start:start+len(tt)]+=np.sin(2*np.pi*f*tt)*env*.045
    melody=[440,523.25,587.33,659.25,587.33,523.25,440,349.23,392,440,523.25,440,392,349.23,293.66,349.23]
    step=1 if name=='boss' else 2
    for i in range(int(dur/step)):
        f=melody[i%len(melody)]; tt=np.arange(RATE*step)/RATE
        tone=(np.sin(2*np.pi*f*tt)+.3*np.sin(2*np.pi*f*2*tt))*np.exp(-tt*2.5)*np.minimum(tt*80,1)*.1
        data[i*RATE*step:(i+1)*RATE*step]+=tone
    if name=='boss':
        for i in range(64):
            tt=np.arange(RATE//3)/RATE
            drum=np.sin(2*np.pi*(65*tt-25*tt*tt))*np.exp(-tt*17)*.24
            start=int(i*.5*RATE); data[start:start+len(drum)]+=drum
    save(name,data,True)
t=np.arange(RATE*16)/RATE
noise=rng.normal(0,.025,len(t)); noise=np.convolve(noise,np.ones(21)/21,mode='same')
amb=noise+np.sin(2*np.pi*110*t)*.006
for start in [1,4,7,11,14]:
    tt=np.arange(RATE//2)/RATE
    chirp=np.sin(2*np.pi*(1800*tt+500*tt*tt))*np.sin(np.pi*tt*2)**2*.035
    amb[start*RATE:start*RATE+len(tt)]+=chirp
save('ambience',amb,True)
for name,f,duration in [('jump',440,.22),('attack',220,.18),('hit',110,.15),('hurt',140,.3),('altar',660,1.2),('portal',440,1.7),('slam',60,.5),('step',90,.08)]:
    tt=np.arange(int(RATE*duration))/RATE
    env=np.exp(-tt*(5/duration))*np.minimum(tt*400,1)
    data=np.sin(2*np.pi*(f*tt+(400 if name=='jump' else -f*.2)*tt*tt))*env*.4
    if name in ['attack','hit','slam','step']: data+=rng.normal(0,.13,len(tt))*env
    if name in ['altar','portal']:
        for mult in [1.25,1.5,2]: data+=np.sin(2*np.pi*f*mult*tt)*env*.12
    save(name,data)

# OpenRaster packages retain original pixels as independently editable layers in Krita.
def ora(name,width,height,layers):
    image=ET.Element('image',{'version':'0.0.3','w':str(width),'h':str(height),'name':name})
    stack=ET.SubElement(image,'stack')
    with zipfile.ZipFile(ROOT/'art_source'/f'{name}.ora','w') as z:
        z.writestr('mimetype','image/openraster')
        for i,(label,path,x,y) in enumerate(layers):
            src=f'data/layer{i}.png'
            ET.SubElement(stack,'layer',{'name':label,'src':src,'x':str(x),'y':str(y),'opacity':'1.0','visibility':'visible','composite-op':'svg:src-over'})
            z.write(ROOT/path,src)
        z.writestr('stack.xml',ET.tostring(image))
        z.write(ROOT/layers[0][1],'mergedimage.png')
ora('nara-source',1170,1345,[('Nara painted character','assets/nara.png',0,0)])
ora('forest-source',1536,1024,[('Painted forest','assets/forest.png',0,0)])
ora('creatures-source',1254,1254,[('Terrain and creatures atlas','assets/forest_atlas.png',0,0)])
if (ROOT/'assets/canopy.png').exists():
    ora('forest-layered',1536,1024,[('Near canopy','assets/canopy.png',0,0),('Painted vista','assets/forest.png',0,0)])
if (ROOT/'assets/nara_run.png').exists():
    ora('nara-run-source',2172,724,[('Four running frames','assets/nara_run.png',0,0)])
if (ROOT/'assets/props.png').exists():
    ora('altar-portal-source',1536,1024,[('Altar and portal','assets/props.png',0,0)])
print('Prepared scenes, UI, audio, and Krita-readable source packages.')
