#!/usr/bin/env python
# -*- coding: utf-8 -*-

#####################################
######### Common parameters #########
#####################################

# -- Start index of each layer -- #
L1_ST = 0
L2_ST = 2
L3_ST = 21
L4_ST = 397
L5_ST = 477

# -- End index of each layer -- #
L1_END = 1
L2_END = 20
L3_END = 396
L4_END = 476
L5_END = 484

PARAMNUM_PER_WORD = 128 # 1word : 128 parameter
NEXT_PARM = 8 # 1parameter : 8bit

#####################################
######### Layer 1 parameters ########
#####################################

L1_U00_ST = 0
L1_U01_ST = 1
L1_U02_ST = 2
L1_U03_ST = 3
L1_U04_ST = 4
L1_U05_ST = 5
L1_KERNELNUM = 6
L1_UPDATETIMING = L1_KERNELNUM - 1
L1_LASTPARM = 28 # 156 % 128

#####################################
######### Layer 2 parameters ########
#####################################

L2_U00_ST = 0
L2_U01_ST = 1
L2_U02_ST = 2
L2_U03_ST = 3
L2_U04_ST = 4
L2_U05_ST = 5
L2_U06_ST = 6
L2_U07_ST = 7
L2_U08_ST = 8
L2_U09_ST = 9
L2_U10_ST = 10
L2_U11_ST = 11
L2_U12_ST = 12
L2_U13_ST = 13
L2_U14_ST = 14
L2_U15_ST = 15
L2_MEMDEPTH = 16
L2_MEMWIDTH = 150
L2_BIAS_ST = 99
L2_UPDATETIMING = L2_MEMDEPTH - 1
L2_KUPDATETIMING = 5
L2_LASTPARM = 112 # 2416 % 128

L2_BIAS_ROWPTR = 18 #
L2_BIAS_COLPTR = 95 #

L2_FILENUM = 7

#####################################
######### Layer 3 parameters ########
#####################################

L3_BIAS_PADLEN = 24
L3_WEIGHT_PADLEN = 56
L3_MEMDEPTH = 120
L3_MEMWIDTH = 16 # 400/25
L3_BIAS_ROWPTR = 374 #
L3_BIAS_COLPTR = 127 #
L3_BIAS_ST = 199 # 
L3_LASTPARM = 120 # 48120 % 128
L3_UPDATETIMING = L3_MEMDEPTH - 1
L3_FILENUM = 17

#####################################
########## Layer parameters #########
#####################################

#####################################
########## Layer parameters #########
#####################################