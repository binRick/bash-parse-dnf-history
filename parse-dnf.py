#!/usr/bin/env python3
import os, subprocess, json, sys

DNF_HISTORY_CMD='sudo -u root dnf history list'
DNF_HISTORY_TIMEOUT=10

EXEC = 'timeout {} {}'.format(
        DNF_HISTORY_TIMEOUT,
        DNF_HISTORY_CMD,
       ).split(' ')
print(' '.join(EXEC))

P = subprocess.Popen(EXEC, shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
PID = P.pid
try:
    out, err = P.communicate(timeout=DNF_HISTORY_TIMEOUT+5)
except TimeoutExpired:
    P.kill()
    out, err = P.communicate()
    
code = P.returncode

outlines = []
for l in out.decode().strip().splitlines():
    l = l.strip()
    outlines.append(l)
    if l[0].isnumeric():
        PS = []
        for L in l.split('|'):
            L = L.strip()
            PS.append(L)
        #print('PS={}'.format(PS))
        PSO = {
         'id': PS[0],
         'args': PS[1],
         'date': PS[2],
         'actions': PS[3],
         'altered': PS[4],
        }
        print(PSO)

err = err.decode().strip().splitlines()

print('code={}'.format(code))
#print('outlines={}'.format(outlines))
#print('err={}'.format(err))
