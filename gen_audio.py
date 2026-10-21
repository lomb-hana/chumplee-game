import numpy as np, wave, random
SR=22050
def save(name,x):
    x=np.clip(x,-1,1); d=(x*30000).astype(np.int16)
    w=wave.open(f"audio/{name}.wav","wb"); w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(d.tobytes()); w.close()
def f(n): return 440*2**((n-69)/12)
def sq(freq,dur,duty=0.5,vol=0.3,dec=0.0):
    t=np.arange(int(SR*dur))/SR
    ph=(t*freq)%1; x=np.where(ph<duty,1.0,-1.0)*vol
    env=np.ones_like(t)
    if dec: env=np.exp(-t*dec)
    r=min(len(t),200); env[-r:]*=np.linspace(1,0,r)
    return x*env
def tri(freq,dur,vol=0.35):
    t=np.arange(int(SR*dur))/SR; ph=(t*freq)%1
    x=(4*np.abs(ph-0.5)-1)*vol; r=min(len(t),150); x[-r:]*=np.linspace(1,0,r); return x
def noise(dur,vol=0.3,dec=20,step=1):
    n=int(SR*dur); x=np.repeat(np.random.uniform(-1,1,n//step+1),step)[:n]
    return x*vol*np.exp(-np.arange(n)/SR*dec)
def mix(buf,x,pos):
    pos=int(pos); e=min(len(buf),pos+len(x)); buf[pos:e]+=x[:e-pos]
CH={'Am':[57,60,64],'F':[53,57,60],'C':[48,52,55],'G':[55,59,62],'Em':[52,55,59],'D':[50,54,57],'B':[47,51,54],'Dm':[50,53,57],'Bb':[46,50,53],'A':[45,49,52],'E':[52,56,59]}
def song(name,bpm,prog,seed,lead_duty=0.25,bars_rep=2,dark=False):
    random.seed(seed); s16=60/bpm/4
    nb=len(prog)*bars_rep; L=int(SR*s16*16*nb); buf=np.zeros(L)
    # melody per bar pattern
    for b in range(nb):
        ch=CH[prog[b%len(prog)]]; t0=b*16*s16*SR
        for i in range(16):
            p=t0+i*s16*SR
            mix(buf,sq(f(ch[i%3]+12),s16*0.9,0.125,0.07),p)  # arp
            if i%2==0: mix(buf,tri(f(ch[0]-12 + (12 if i%4==2 else 0)),s16*1.8,0.3),p)  # bass
            if i%4==0: # kick
                t=np.arange(int(SR*0.12))/SR; mix(buf,np.sin(2*np.pi*np.cumsum(120*np.exp(-t*30)+40)/SR)*0.5*np.exp(-t*25),p)
            if i%8==4: mix(buf,noise(0.15,0.25,25,2),p)
            if i%2==1: mix(buf,noise(0.04,0.08,80,1),p)
        # lead melody (second half of song loops get lead)
        rhythm=[0,3,6,8,10,12,14] if b%2==0 else [0,2,4,7,10,12]
        if b>=len(prog) or not dark:
            random.seed(seed*100+b%len(prog)+(0 if b<len(prog) else 50))
            scale=sorted(set([n+12 for n in ch]+[n+24 for n in ch]))
            for k,i in enumerate(rhythm):
                nxt=rhythm[k+1] if k+1<len(rhythm) else 16
                n=random.choice(scale)
                mix(buf,sq(f(n),s16*(nxt-i)*0.95,lead_duty,0.11,2.0),t0+i*s16*SR)
    return buf
save("music_title",song("t",120,['Am','F','C','G'],3,0.5)*0.9)
save("music_level",song("l",150,['Em','C','D','B'],7,0.25)*0.9)
save("music_boss",song("b",168,['Dm','Bb','A','A'],11,0.125,2,True)*0.9)
save("music_cutscene",song("c",132,['C','G','Am','F'],5,0.5)*0.9)
# victory jingle
v=np.zeros(int(SR*3)); s=0.12
for i,n in enumerate([60,64,67,72,67,72,76,79]): mix(v,sq(f(n),s*0.95 if i<7 else 1.2,0.5,0.25,1.5),i*s*SR)
save("jingle_win",v)
g=np.zeros(int(SR*2.5))
for i,n in enumerate([67,66,65,64,63,62,61,55]): mix(g,sq(f(n),0.25 if i<7 else 0.8,0.5,0.25),i*0.25*SR)
save("jingle_over",g)
def sweep(f0,f1,dur,duty=0.5,vol=0.3):
    t=np.arange(int(SR*dur))/SR; fr=np.linspace(f0,f1,len(t)); ph=np.cumsum(fr)/SR%1
    return np.where(ph<duty,1.,-1.)*vol*np.linspace(1,0,len(t))
save("shoot",sweep(1400,300,0.08,0.25,0.25))
save("jump",sweep(300,800,0.12,0.5,0.25))
save("hit",noise(0.1,0.4,40,3))
save("explode",noise(0.5,0.6,8,6))
save("hurt",sweep(600,100,0.3,0.5,0.35))
p=np.zeros(int(SR*0.5))
for i,n in enumerate([72,76,79,84]): mix(p,sq(f(n),0.1,0.25,0.25),i*0.08*SR)
save("powerup",p)
save("select",np.concatenate([sq(f(84),0.05,0.5,0.25),sq(f(91),0.08,0.5,0.25)]))
gl=noise(0.8,0.5,6,1)
for i in range(14): mix(gl,sq(random.uniform(2500,5000),0.05,0.5,0.15,40),random.uniform(0,0.6)*SR)
save("glass",gl)
c=noise(1.2,0.9,4,12); t=np.arange(len(c))/SR; c+=np.sin(2*np.pi*np.cumsum(90*np.exp(-t*4)+30)/SR)*0.8*np.exp(-t*3)
save("crash",c)
o=np.concatenate([sweep(400,1200,0.1,0.5,0.2),sweep(1200,400,0.1,0.5,0.2),sweep(400,1600,0.15,0.5,0.2)])
save("orb",o)
w=np.random.uniform(-1,1,SR*2); w=np.convolve(w,np.ones(30)/30,'same')*1.2; save("wind",w)
save("bosshit",sweep(200,80,0.08,0.5,0.35))
save("taunt",np.concatenate([sweep(500,900,0.06,0.5,.2),sweep(500,900,0.06,0.5,.2),sweep(400,300,0.1,0.5,.2)]))
