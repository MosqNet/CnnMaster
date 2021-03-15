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

O_BIAS_ST = 120 # 

MEM_DEPTH = 10


PARAMNUM_PER_WORD = 128
NEXT_PARM = 8
O_LASTPARM = 82 # 850 % 128
F2_KERNELNUM = 96
F2_BIASNUM = 120
F2_UPDATETIMING = CONV2_OUNINUM - 1

def out_params_molding(ori_L5data):

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

    O_FILES, O_FILEPATH = O_fileinit() # return value : conv2_list[CONV2_PARAMS00.coe ........ CONV2_PARAMS05.coe]

    ##############################################
    ###### Allocate weights for each kernel ######
    ##############################################

    # ori_L2data depth 
    for i in range(len(ori_L5data)):

        # knl_ptr initialize
        knl_ptr = 0

        # Divide 1 word
        for j in range(PARAMNUM_PER_WORD):

            # if Deepest part and last parameter  
            if (i == len(ori_L5data)-1) & (j == O_LASTPARM):
                state = 0
                knl_ptr = 0
                break

            #############################################
            ##############  state machine  ##############
            #############################################

            # kernel1 -> kernel2 -> ....... -> kernel15 -> kernel16 -> kernel1
            
            # knl_weight[state].append(str(ori_L5data[i][knl_ptr:knl_ptr+8]))

            if state != O_BIAS_ST:
                knl_weight[state].append(ori_L5data[i][knl_ptr:knl_ptr+8])
            else:
                if j != O_LASTPARM-1:
                    bias.append(''.join(ori_L5data[i][knl_ptr:knl_ptr+8])+'000000000000000000000000,\n')
                else:
                    bias.append(''.join(ori_L5data[i][knl_ptr:knl_ptr+8])+'000000000000000000000000;')

            # next state 
            if (i >= len(ori_L5data)-1) & (j >= 71):
                state = O_BIAS_ST
            elif state != MEM_DEPTH-1:
                state += 1
            else:
                state = 0
            # pointer update
            knl_ptr += NEXT_PARM

    #####################################
    #######    Fit to 256bit    #########
    #####################################

    O_PARAMS = [[] for i in range(10)]

    for i in range(10):
        if i != 9:
            O_PARAMS[i] = ''.join(knl_weight[i])+O_zeropad()+',\n'
        else:
            O_PARAMS[i] = ''.join(knl_weight[i])+O_zeropad()+';'

    #####################################
    #######    write to file    #########
    #####################################

    for i in range(len(O_FILES)):
        if O_FILES[i] != 'OUT_BIAS.coe':
            for j in range(10):
                fd = open(O_FILEPATH + O_FILES[i],'a')
                fd.writelines(str(O_PARAMS[j]))
                fd.close()
        else:
            for j in range(10):
                fd = open(O_FILEPATH + O_FILES[i],'a')
                fd.writelines(str(bias[j]))
                fd.close()

    print('Layer 5(OUT LAYER) parameter saving completed')


def O_fileinit():

    O_FILES = [] # conv2 file list
    O_FILEPATH = 'L5_PARAMS/'
    O_FILENAME = 'OUT_PARAMS' # ソースネーム
    O_BIASNAME = 'OUT_BIAS.coe'
    string = ['memory_initialization_radix=2;','\n','memory_initialization_vector=','\n']

    # filelist create 

    for i in range(F2_FILENUM):
        if i != (F2_FILENUM-1):
            O_FILES.append(O_FILENAME + '.coe')
        else:
            O_FILES.append(O_BIASNAME)

    # coe initialize

    for i in range(len(O_FILES)):
        if os.path.isfile(O_FILEPATH + O_FILES[i]):
            os.remove(O_FILEPATH + O_FILES[i])

    for i in range(len(O_FILES)):
        fd = open(O_FILEPATH + O_FILES[i],'a')
        fd.writelines(string)
        fd.close()

    return O_FILES, O_FILEPATH


def O_zeropad():
    
    zero352 = '0'*352 # string list

    # for i in range(352):
    #     zero352+='0'

    return str(zero352)