import re   
import sys
import numpy as np

logName = sys.argv[1]
reSched = re.compile(r"^==== sched:\s+(\S+)")
reFN    = re.compile(r"^(\S+)\.")
reNQs   = re.compile(r"nQs=(\d+) .*range=(\d+).*prb=(\d+)")
reSim   = re.compile(' (Generic|AVX|AVX2|AVX512)$')
rePars  = re.compile(r'OMP_NUM_THREADS=(\d+) fusedSpan=(\d) fusedDepth=(\d+) wfnCapacity=(\d+)')
reInfo  = re.compile(r'sz=([.\d]+) nQs=([.\d]+) nCs=([.\d]+) flsh= *([.\de+-]+).*gts= *([.\de+-]+).*elap= *(\d+).*(.)gps= *([.\de+-]+).*fus= *([.\d]+).*ker= *([.\d]+)')
found   = reFN.search(logName)
env     = found.group(1)
fp      = open(logName,'r')
gpss    = []
print(f'"env","test","typ","sim","qs","threads","span","sz","gps"')
sim     = ""
totalQs = -1
threads = -1
span    = -1
sz      = -1
rng     = 1
prb     = -1
sched   = "???"

prbs = [
    "ladder"   ,
    "ladder"   ,
    "shor_4"   ,
    "shor_6"   ,
    "shor_8"   ,
    "shor_10"  ,
    "shor_12"  ,
    "suprem_44",
    "suprem_55",
    "suprem_56",
    "qulacs_5",
    "qulacs_10",
    "qulacs_15",
    "qulacs_20",
    "qulacs_25"
]
def dumpGpss():
    global gpss,env,sim,totalQs,threads,span,sz,rng,prb,sched
    if len(gpss) > 0:
        gpsMed  = np.median(gpss)
        cnt     = 0.0
        tot     = 0.0
        for gps in gpss:
            if gps > gpsMed/2.0 and gps < gpsMed*1.5:
                cnt += 1.0
                tot += gps
        if cnt > 0: gps = tot/cnt
        else:       gps = gpsAvg

        nam     = prbs[prb]

        if rng == 0:    nam  = f'{env},{nam}L'
        elif rng == 2:  nam  = f'{env},{nam}H'
        else:           nam  = f'{env},{nam}'

        print(f"{nam},{sched},{sim},{totalQs},{threads},{span},{sz},{gps:.1f}")
        
        gpss = []

while True:
    inp = fp.readline()
    if inp == "": 
        dumpGpss()
        break
    found   = reSched.search(inp)
    if found:
        dumpGpss()
        sched        = found.group(1)
        continue
    found   = reNQs.search(inp)
    if found:
        dumpGpss()
        totalQs     = found.group(1)
        rng         = int(found.group(2))
        prb         = int(found.group(3))
        continue
    found   = reSim.search(inp)
    if found:
        dumpGpss()
        sim     = found.group(1)
        continue
    found   = rePars.search(inp)
    if found:
        threads     = found.group(1)
        span        = found.group(2)
        limit       = found.group(3)
        wfnSiz      = found.group(4)
        continue
    found   = reInfo.search(inp)
    if found:
        sz          = found.group(1)
        nQs         = float(found.group(2))
        nCs         = float(found.group(3))
        flushes     = found.group(4)
        gates       = found.group(5)
        elap        = found.group(6)
        if (found.group(7) == 'k'): mul = 1000.0
        else:                       mul = 1.0
        gps         = float(found.group(8)) * mul
        fusions     = found.group(9)
        kernel      = found.group(10)
        gpss.append(gps)
        continue


fp.close()

