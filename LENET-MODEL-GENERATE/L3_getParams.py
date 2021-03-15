#!/usr/bin/env python
# -*- coding: utf-8 -*-

#####################################
######### import libraries ##########
#####################################

import os
import sys
import cnst

def full1_params_molding(ori_L3data):

    # ori_L1data format 
    # width 1024
    # depth 377

    # List type : 2 dimensional array
    # list length : 256 [ weight : 200 | bias : 8 | dammy : 48]
    # list depth  : 16
    knl_weight = [[] for j in range(cnst.L3_MEMDEPTH)]

    # List length : 128 [(bias : 8)* 6 ]
    # List depth  : 1
    bias = []

    state = 0 # state register 
    knl_ptr = 0 # kernel pointer 

    ##############################################
    ## file initialize and get full1 file list ###
    ##############################################

    L3_FILES, L3_FILEPATH = L3_fileinit() # return value : conv2_list[CONV2_PARAMS00.coe ........ CONV2_PARAMS05.coe]

    ##############################################
    ###### Allocate weights for each kernel ######
    ##############################################

    # ori_L2data depth 
    for i in range(len(ori_L3data)):

        # knl_ptr initialize
        knl_ptr = 0

        # Divide 1 word
        for j in range(cnst.PARAMNUM_PER_WORD):

            # if Deepest part and last parameter  
            if (i == len(ori_L3data)-1) & (j == cnst.L3_LASTPARM):
                state = 0
                knl_ptr = 0
                break

            #############################################
            ##############  state machine  ##############
            #############################################

            # kernel1 -> kernel2 -> ....... -> kernel15 -> kernel16 -> kernel1
            
            # knl_weight[state].append(str(ori_L3data[i][knl_ptr:knl_ptr+8]))

            if state != cnst.L3_BIAS_ST:
                knl_weight[state].append(ori_L3data[i][knl_ptr:knl_ptr+cnst.NEXT_PARM])
            else:
                if j != cnst.L3_LASTPARM-1:
                    bias.append(''.join(ori_L3data[i][knl_ptr:knl_ptr+cnst.NEXT_PARM])+zeropad(cnst.L3_BIAS_PADLEN)+',\n')
                else:
                    bias.append(''.join(ori_L3data[i][knl_ptr:knl_ptr+cnst.NEXT_PARM])+zeropad(cnst.L3_BIAS_PADLEN)+';')

            # next state 
            if ((i >= cnst.L3_BIAS_ROWPTR) & (j >= cnst.L3_BIAS_COLPTR)) | (i >= cnst.L3_BIAS_ROWPTR+1):
            # if ((i >= len(ori_L3data)-2) & (j >= 127)) | (i >= len(ori_L3data)-1):
                state = cnst.L3_BIAS_ST
            elif state != cnst.L3_UPDATETIMING:
                state += 1
            else:
                state = 0
            # pointer update
            knl_ptr += cnst.NEXT_PARM

    #####################################
    #######    Fit to 256bit    #########
    #####################################

    F1_PARAMS = [[] for i in range(cnst.L3_FILENUM)]

    for i in range(cnst.L3_MEMDEPTH):
        knl_ptr = 0
        for j in range(cnst.L3_MEMWIDTH):
            if i != cnst.L3_MEMDEPTH-1:
                F1_PARAMS[j].append(''.join(knl_weight[i][knl_ptr:knl_ptr+25])+zeropad(cnst.L3_WEIGHT_PADLEN)+',\n')
            else:
                F1_PARAMS[j].append(''.join(knl_weight[i][knl_ptr:knl_ptr+25])+zeropad(cnst.L3_WEIGHT_PADLEN)+';')

            knl_ptr += 25

    #####################################
    #######    write to file    #########
    #####################################

    F1_PARAMS[cnst.L3_FILENUM-1] = bias

    for i in range(len(L3_FILES)):
        for j in range(cnst.L3_MEMDEPTH):
            fd = open(L3_FILEPATH + L3_FILES[i],'a')
            fd.writelines(str(F1_PARAMS[i][j]))
            fd.close()

    print('Layer 3(FULL1) parameter saving completed')


def L3_fileinit():

    L3_FILES = [] # conv2 file list
    L3_FILEPATH = 'L3_PARAMS/'
    L3_FILENAME = 'FULL1_PARAMS' # ソースネーム
    L3_BIASNAME = 'FULL1_BIAS.coe'
    string = ['memory_initialization_radix=2;','\n','memory_initialization_vector=','\n']

    # filelist create 

    for i in range(cnst.L3_FILENUM):
        if i != (cnst.L3_FILENUM-1):
            L3_FILES.append(L3_FILENAME + '%d' %i + '.coe')
        else:
            L3_FILES.append(L3_BIASNAME)

    # coe initialize

    for i in range(len(L3_FILES)):
        if os.path.isfile(L3_FILEPATH + L3_FILES[i]):
            os.remove(L3_FILEPATH + L3_FILES[i])

    for i in range(len(L3_FILES)):
        fd = open(L3_FILEPATH + L3_FILES[i],'a')
        fd.writelines(string)
        fd.close()

    return L3_FILES, L3_FILEPATH

def zeropad(zero_len):

    return str('0'*zero_len)