import re   
import sys

logName = sys.argv[1]
reFN    = re.compile(r"[./\\]*(\w+)_(\d+)\.")
reSim   = re.compile(' (Generic|AVX|AVX2)$')
rePars  = re.compile(r'OMP_NUM_THREADS=(\d) fusedSpan=(\d) fusedLimit=(\d+)')
reInfo  = re.compile(r'sz=([.\d]+) nQs=([.\d]+) nCs=([.\d]+) flushes= *(\d+).*gates= *(\d+).*elap= *(\d+).*gps= *([.\d]+).*fus= *([.\d]+).*ker= *([.\d]+)')
found   = reFN.search(logName)
env     = found.group(1)
qs      = found.group(2)
fp      = open(logName,'r')
gpss    = []
print(f'"env","sim","qs","threads","span","sz","nQs+nCs","gps"')
while True:
    inp = fp.readline()
    if inp == "": 
        if len(gpss) > 0:
            gps = max(gpss)
            print(f"{env},{sim},{qs},{threads},{span},{sz},{nQs+nCs:.2f},{gps:.1f}")
            gpss = []
        break
    found   = reSim.search(inp)
    if found:
        if len(gpss) > 0:
            gps = max(gpss)
            print(f"{env},{sim},{qs},{threads},{span},{sz},{nQs+nCs:.2f},{gps:.1f}")
            gpss = []
        sim     = found.group(1)
        continue
    found   = rePars.search(inp)
    if found:
        threads     = found.group(1)
        span        = found.group(2)
        limit       = found.group(3)
        continue
    found   = reInfo.search(inp)
    if found:
        sz          = found.group(1)
        nQs         = float(found.group(2))
        nCs         = float(found.group(3))
        flushes     = found.group(4)
        gates       = found.group(5)
        elap        = found.group(6)
        gps         = float(found.group(7))
        fusions     = found.group(8)
        kernel      = found.group(9)
        gpss.append(gps)
        continue


fp.close()

