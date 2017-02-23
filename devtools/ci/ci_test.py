#!/usr/bin/env python
from time import time
import sys
import subprocess

programs = ['clean', 'is_amberhome_defined',
            'cpptraj', 'pytraj', 'parmed', 'pdb4amber',
            'leap', 'antechamber', 'unitcell', 'reduce',
            'nab', 'mdgx', 'resp', 'sqm',
            'gbnsr6', 'elsize', 'paramfit',
            'FEW', 'cphstats', 'cpinutil']

def execute(command):
    then = time()
    # adapted from StackOverflow
    # http://stackoverflow.com/a/4418193
    print(' '.join(command))
    output_lines = []
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    # Poll process for new output until finished
    while True:
        nextline = process.stdout.readline().decode()
        if nextline == '' and process.poll() is not None:
            break
        sys.stdout.write('.')
        sys.stdout.flush()

        output_lines.append(nextline)
    output = ''.join(output_lines)
    now = time()
    time_diff = now - then
    if 'Program error' in output or 'possible FAILURE' in output or 'No rule to make target' in output:
        print('{0:.1f} (s), FAILURE'.format(time_diff))
    else:
        print('{0:.1f} (s), PASSED'.format(time_diff))
    return output

def test_me():
    errors = []
    for me in programs:
        if me not in ['clean', 'is_amberhome_defined']:
            me = 'test.' + me
        output = execute(['make', me])
        if 'Program error' in output or 'possible FAILURE' in output or 'No rule to make target' in output:
            errors.append(output)
    if errors:
        for out in errors:
            print(out)
    assert not errors
