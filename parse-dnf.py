#!/usr/bin/env python3
import os, subprocess, json, sys

DNF_TRANSACTIONS = {}
DNF_HISTORY_CMD='sudo -u root dnf history list'
DNF_HISTORY_INFO_CMD='sudo -u root dnf history info'
DNF_HISTORY_TIMEOUT=10

EXEC = 'timeout {} {}'.format(
        DNF_HISTORY_TIMEOUT,
        DNF_HISTORY_CMD,
       ).split(' ')

P = subprocess.Popen(EXEC, shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
pid = P.pid
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
        PSO = {
         'id': PS[0],
         'args': PS[1],
         'date': PS[2],
         'actions': PS[3],
         'altered': PS[4],
         'info_cmd': '{} {}'.format(
            DNF_HISTORY_INFO_CMD,
            PS[0],
          ).split(' '),
        }
        IP = subprocess.Popen(PSO['info_cmd'], shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        try:
            ip_out, ip_err = IP.communicate(timeout=10)
        except:
            IP.kill()
            ip_out, ip_err = IP.communicate()

        PSO['info_lines'] = ip_out.decode().strip().splitlines()
        
        for _l in PSO['info_lines']:
            if _l.startswith('Return-Code '):
                PSO['info_return_code'] = _l.split(':')[1].strip()
            if _l.startswith('User '):
                PSO['info_user'] = _l.split(':')[1].strip().split(' ')[0]

        DNF_TRANSACTIONS[PSO['id']] = PSO

err = err.decode().strip().splitlines()

DNF_REPORT = {
    'transactions': DNF_TRANSACTIONS,
}
print(json.dumps(DNF_REPORT))
