#!/usr/bin/env python
# -*- coding: utf-8 -*-

#####################################
######### import libraries ##########
#####################################

import os
import sys

#####################################
########### #parameters #############
#####################################

CONV2_OUNINUM = 16

F2_FILENUM = 2

NX_UNITNUM = 120

F2_BIAS_ST = 120 # 

MEM_DEPTH = 84


PARAMNUM_PER_WORD = 128
NEXT_PARM = 8
F2_LASTPARM = 52 # 10164 % 128
F2_KERNELNUM = 96
F2_BIASNUM = 120
F2_UPDATETIMING = CONV2_OUNINUM - 1

def full02_params_molding(ori_L4data):

    # ori_L1data format 
    # width 1024
    # depth 377

    # List type : 2 dimensional array
    # list length : 256 [ weight : 200 | bias : 8 | dammy : 48]
    # list depth  : 16
    knl_weight = [[] for j in range(MEM_DEPTH)]

    # List length : 128 [(bias : 8)* 6 ]
    # List depth  : 1
    bias = []

    state = 0 # state register 
    knl_ptr = 0 # kernel pointer 

    ##############################################
    ## file initialize and get full1 file list ###
    ##############################################

    F2_FILES, F2_FILEPATH = F2_fileinit() # return value : conv2_list[CONV2_PARAMS00.coe ........ CONV2_PARAMS05.coe]

    ##############################################
    ###### Allocate weights for each kernel ######
    ##############################################

    # ori_L2data depth 
    for i in range(len(ori_L4data)):

        # knl_ptr initialize
        knl_ptr = 0

        # Divide 1 word
        for j in range(PARAMNUM_PER_WORD):

            # if Deepest part and last parameter  
            if (i == len(ori_L4data)-1) & (j == F2_LASTPARM):
                state = 0
                knl_ptr = 0
                break

            #############################################
            ##############  state machine  ##############
            #############################################

            # kernel1 -> kernel2 -> ....... -> kernel15 -> kernel16 -> kernel1
            
            # knl_weight[state].append(str(ori_L4data[i][knl_ptr:knl_ptr+8]))

            if state != F2_BIAS_ST:
                knl_weight[state].append(ori_L4data[i][knl_ptr:knl_ptr+8])
            else:
                if j != F2_LASTPARM-1:
                    bias.append(''.join(ori_L4data[i][knl_ptr:knl_ptr+8])+'000000000000000000000000,\n')
                else:
                    bias.append(''.join(ori_L4data[i][knl_ptr:knl_ptr+8])+'000000000000000000000000;')

            # next state 
            if (i >= len(ori_L4data)-2) & (j >= 95) | (i >= len(ori_L4data)-1):
                state = F2_BIAS_ST
            elif state != MEM_DEPTH-1:
                state += 1
            else:
                state = 0
            # pointer update
            knl_ptr += NEXT_PARM

    #####################################
    #######    Fit to 256bit    #########
    #####################################

    F2_PARAMS = [[] for i in range(84)]

    for i in range(84):
        if i != 83:
            F2_PARAMS[i] = ''.join(knl_weight[i])+'0000000000000000000000000000000000000000000000000000000000000000,\n'
        else:
            F2_PARAMS[i] = ''.join(knl_weight[i])+'0000000000000000000000000000000000000000000000000000000000000000;'

    #####################################
    #######    write to file    #########
    #####################################

    for i in range(len(F2_FILES)):
        if F2_FILES[i] != 'FULL2_BIAS.coe':
            for j in range(84):
                fd = open(F2_FILEPATH + F2_FILES[i],'a')
                fd.writelines(str(F2_PARAMS[j]))
                fd.close()
        else:
            for j in range(84):
                fd = open(F2_FILEPATH + F2_FILES[i],'a')
                fd.writelines(str(bias[j]))
                fd.close()

    print('Layer 4(FULL2) parameter saving completed')


def F2_fileinit():

    F2_FILES = [] # conv2 file list
    F2_FILEPATH = 'L4_PARAMS/'
    F2_FILENAME = 'FULL2_PARAMS' # ソースネーム
    F2_BIASNAME = 'FULL2_BIAS.coe'
    string = ['memory_initialization_radix=2;','\n','memory_initialization_vector=','\n']

    # filelist create 

    for i in range(F2_FILENUM):
        if i != (F2_FILENUM-1):
            F2_FILES.append(F2_FILENAME + '.coe')
        else:
            F2_FILES.append(F2_BIASNAME)

    # coe initialize

    for i in range(len(F2_FILES)):
        if os.path.isfile(F2_FILEPATH + F2_FILES[i]):
            os.remove(F2_FILEPATH + F2_FILES[i])

    for i in range(len(F2_FILES)):
        fd = open(F2_FILEPATH + F2_FILES[i],'a')
        fd.writelines(string)
        fd.close()

    return F2_FILES, F2_FILEPATH