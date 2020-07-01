import re   
import sys

logName = sys.argv[1]
reXtra  = re.compile(r"^==== idxXtra:\s+(\d+)")
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
xtra    = "???"

prbs = [
    ("ladder",""),
    ("ladder",""),
    ("shor_4","std"),
    ("shor_4","qio"),
    ("shor_6","std"),
    ("shor_6","qio"),
    ("shor_8","std"),
    ("shor_8","qio"),
    ("shor_10","std"),
    ("shor_10","qio"),
    ("shor_12","std"),
    ("shor_12","qio"),
    ("shor_14","std"),
    ("shor_14","qio"),
    ("suprem_4","std"),
    ("suprem_4","qio"),
    ("suprem_5","std"),
    ("suprem_5","qio"),
    ("suprem_4","std"),
    ("suprem_4","qio"),
    ("suprem_5","std"),
    ("suprem_5","qio"),
    ("suprem_4","std"),
    ("suprem_5","std"),
]
def dumpGpss():
    global gpss,env,sim,totalQs,threads,span,sz,rng,prb,xtra
    if len(gpss) > 0:
        gpsAvg  = sum(gpss) / len(gpss)
        cnt     = 0.0
        tot     = 0.0
        for gps in gpss:
            if gps > gpsAvg/2.0 and gps < gpsAvg*1.5:
                cnt += 1.0
                tot += gps

        nam,typ = prbs[prb]
        if xtra == 1 and typ == "qio": typ = "sim"
        if xtra == 2 and typ == "qio": typ = "ord"
        
        if rng == 0:    nam  = f'{env},{nam}L'
        elif rng == 2:  nam  = f'{env},{nam}H'
        else:           nam  = f'{env},{nam}'

        if cnt > 0:
            gps = tot/cnt
            print(f"{nam},{typ},{sim},{totalQs},{threads},{span},{sz},{gps:.1f}")
        else:
            print(f"{nam},{typ},{sim},{totalQs},{threads},{span},{sz},{0.0},'<<<<< bad entry")
        
        gpss = []

while True:
    inp = fp.readline()
    if inp == "": 
        dumpGpss()
        break
    found   = reXtra.search(inp)
    if found:
        xtra        = int(found.group(1))
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

