#!/usr/bin/env python
from time import time
from contextlib import contextmanager
import os
import sys
import subprocess


@contextmanager
def change_folder(where):
    here = os.getcwd()
    os.chdir(where)
    yield
    os.chdir(here)


def get_tests_from_test_name(test_name, makefile_fn):
    # test.serial.sander.MM has a bunch of small tests.
    with open(makefile_fn) as fh:
        lines = fh.readlines()

    index_0 = 0
    index_next = -1
    for index, line in enumerate(lines):
        if line.startswith(test_name):
            break
    index_0 = index

    for index in range(index_0 + 1, 1000):
        if lines[index].startswith('test.'):
            break

    index_next = index
    my_lines = [
        word for word in ''.join(lines[index_0:index_next]).strip().split()
        if word != '\\'
    ]
    my_lines.pop(0)
    return my_lines


test_task = os.getenv('TEST_TASK', 'fast')
sanderapi_tests = [
    'test.parm7', 'Fortran', 'Fortran2', 'C', 'CPP', 'Python', 'clean'
]
amberhome = os.getenv('AMBERHOME')
amber_test_dir = amberhome + '/test'
ambertools_test_dir = amberhome + '/AmberTools/test'

if test_task == 'fast':
    test_suite = [
        'test.cpptraj', 'test.pytraj', 'test.parmed', 'test.pdb4amber',
        'test.leap', 'test.antechamber', 'test.unitcell', 'test.reduce',
        'test.nab', 'test.mdgx', 'test.resp', 'test.sqm', 'test.gbnsr6',
        'test.elsize', 'test.paramfit', 'test.FEW', 'test.cphstats',
        'test.cpinutil'
    ]
elif test_task == 'mmpbsa':
    test_suite = [
        'clean',
        'is_amberhome_defined',
        'test.mmpbsa',
        'test.mm_pbsa',
    ]
elif test_task == 'rism':
    test_suite = ['test.rism1d', 'test.rism3d.periodic']
elif test_task == 'serial_MM':
    excluded_tests = ['test.serial.sander.emap', ]
    print('excluded_tests', excluded_tests)
    test_suite = get_tests_from_test_name('test.serial.sander.MM',
                                          amber_test_dir +
                                          '/Makefile') + ['test.nmode', ]
    for test in excluded_tests:
        test_suite.remove(test)
elif test_task == 'serial_QMMM':
    test_suite = get_tests_from_test_name('test.serial.QMMM',
                                          amber_test_dir + '/Makefile')
elif test_task == 'python':
    test_suite = ['test.pytraj', 'test.parmed', 'test.pdb4amber']
    # pymsmt have not passed its tests yet.
else:
    print('not sure how to test with test_task = {}'.format(test_task))
    sys.exit(0)


def execute(command):
    then = time()
    # adapted from StackOverflow
    # http://stackoverflow.com/a/4418193
    print(' '.join(command))
    output_lines = []
    process = subprocess.Popen(
        command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

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
    ERRORS = []
    ALL_OUTPUTS = []
    amberhome = os.getenv('AMBERHOME')

    def run_all(test_suite):
        for me in test_suite:
            output = execute(['make', me])
            ALL_OUTPUTS.extend(output.split('\n'))
            if ('Program error' in output or 'possible FAILURE' in output or
                    'No rule to make target' in output):
                ERRORS.append(output)

    print('test_suite', test_suite)
    # amberXX/test/
    if test_task in ['serial_MM', 'serial_QMMM']:
        print('serial MM and QMMM')
        test_folder = amber_test_dir
    # amberXX/AmberTools/test/
    else:
        print(amberhome + '/AmberTools/test/')
        test_folder = ambertools_test_dir
    print('test_folder', test_folder)
    with change_folder(test_folder):
        run_all(test_suite)

    # sanderapi
    with change_folder(amberhome + '/test/sanderapi'):
        print(amberhome + '/test/sanderapi')
        run_all(sanderapi_tests)

    if ERRORS:
        for out in ERRORS:
            print(out)

    n_passes = n_fails = n_program_errors = 0

    for line in ALL_OUTPUTS:
        if 'PASSED' in line:
            n_passes += 1
        if 'Program error' in line:
            n_program_errors += 1
        if 'possible FAILURE' in line:
            n_fails += 1
    print("{} file comparisons passed".format(n_passes))
    print("{} file comparisons failed".format(n_fails))
    print("{} tests experienced errors".format(n_program_errors))
    assert len(ERRORS) == 0


if __name__ == '__main__':
    test_me()
