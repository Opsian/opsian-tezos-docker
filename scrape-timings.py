#!/usr/bin/env python3

# Parsing lines like:
# 655.54user 145.28system 13:01.08elapsed 102%CPU (0avgtext+0avgdata 6039016maxresident)k

import sys
import re

print("User, System, Elapsed")

for line in sys.stdin:
    split = line.split(' ')
    user = split[0].replace("user", "")
    system = split[1].replace("system", "")
    elapsed = split[2].replace("elapsed", "")
    print(user + ", " + system + ", " + elapsed)

