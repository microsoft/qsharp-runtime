import re   
import sys
import numpy as np
from collections import namedtuple

info    = namedtuple('Info','test loop secs gates threads span depth gps')
logName = sys.argv[1]
reHead  = re.compile(r"^CSV,test,")
reInfo  = re.compile(r'^CSV,([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,\s]+)')
fp      = open(logName,'r')
infos   = []

print('test,secs,gates,threads,span,depth,gps')

def dumpGpss():
    global infos
    if len(infos) > 0:
        gpss    = [float(i.gps) for i in infos]
        gpsMed  = np.median(gpss)
        cnt     = 0.0
        tot     = 0.0
        #for gps in gpss:
        #    if gps > gpsMed/2.0 and gps < gpsMed*1.5:
        #        cnt += 1.0
        #        tot += gps
        #if cnt > 0: gps = tot/cnt
        #else:       gps = np.average(gpss)
        gps     = np.max(gpss)

        idx     = int(len(infos)/2)
        itm     = infos[idx]
        print(f"{itm.test},{itm.secs},{itm.gates},{itm.threads},{itm.span},{itm.depth},{gps:.1f}")
        infos = []

while True:
    inp = fp.readline()
    if inp == "": 
        dumpGpss()
        break
    found   = reHead.search(inp)
    if found:
        dumpGpss()
        continue
    found   = reInfo.search(inp)
    if found:
        infos.append(info(found.group(1),found.group(2),found.group(3),found.group(4),
                        found.group(5),found.group(6),found.group(7),found.group(8)))
        continue

fp.close()
