#!/usr/bin/env python
# -*- coding: utf-8 -*-

#####################################
######### import libraries ##########
#####################################

import os
import sys
import cnst

def conv2_params_molding(ori_L2data):

    # ori_L1data format 
    # width 1024
    # depth 2

    # List type : 2 dimensional array
    # list length : 256 [ weight : 200 | bias : 8 | dammy : 48]
    # list depth  : 16
    knl_weight = [[] for j in range(cnst.L2_MEMDEPTH)]

    # List length : 128 [(bias : 8)* 6 ]
    # List depth  : 1
    bias = []

    state = 0 # state register 
    knl_ptr = 0 # kernel pointer 

    ##############################################
    ##### file initialize and get conv2 list #####
    ##############################################

    L2_FILES, L2_FILEPATH = L2_fileinit() # return value : conv2_list[CONV2_PARAMS00.coe ........ CONV2_PARAMS05.coe]

    ##############################################
    ###### Allocate weights for each kernel ######
    ##############################################

    # ori_L2data depth 
    for i in range(len(ori_L2data)):

        # knl_ptr initialize
        knl_ptr = 0

        # Divide 1 word
        for j in range(cnst.PARAMNUM_PER_WORD):

            # if Deepest part and last parameter  
            if (i == len(ori_L2data)-1) & (j == cnst.L2_LASTPARM):
                state = 0
                break

            #############################################
            ##############  state machine  ##############
            #############################################

            # kernel1 -> kernel2 -> ....... -> kernel15 -> kernel16 -> kernel1
            
            if state != cnst.L2_BIAS_ST:
                knl_weight[state].append(str(ori_L2data[i][knl_ptr:knl_ptr+cnst.NEXT_PARM]))
            else:
                bias.append(str(ori_L2data[i][knl_ptr:knl_ptr+cnst.NEXT_PARM]))

            # next state 
            if (i == cnst.L2_BIAS_ROWPTR) & (j >= cnst.L2_BIAS_COLPTR):
                state = cnst.L2_BIAS_ST
            elif state != cnst.L2_UPDATETIMING:
                state += 1
            else:
                state = 0
            # pointer update
            knl_ptr += cnst.NEXT_PARM

    
    ###################################
    ###################################
    ###################################

    #リスト長256深さ16 {[ weight :  | dammy : 56] * 6}

    KNL00 = [[] for j in range(cnst.L2_MEMDEPTH)]
    KNL01 = [[] for j in range(cnst.L2_MEMDEPTH)]
    KNL02 = [[] for j in range(cnst.L2_MEMDEPTH)]
    KNL03 = [[] for j in range(cnst.L2_MEMDEPTH)]
    KNL04 = [[] for j in range(cnst.L2_MEMDEPTH)]
    KNL05 = [[] for j in range(cnst.L2_MEMDEPTH)]

    ##### add 12/30

    # for i in range(cnst.L2_MEMDEPTH):
    #     for j in range(cnst.L2_MEMWIDTH):

    #         if (j >= 0) & (j <= 24):
    #             KNL00[i].append(str(knl_weight[i][j]))
    #         elif (j >= 25) & (j <= 49):
    #             KNL01[i].append(str(knl_weight[i][j]))
    #         elif (j >= 50) & (j <= 74):
    #             KNL02[i].append(str(knl_weight[i][j]))
    #         elif (j >= 75) & (j <= 99):
    #             KNL03[i].append(str(knl_weight[i][j]))
    #         elif (j >= 100) & (j <= 124):
    #             KNL04[i].append(str(knl_weight[i][j]))
    #         else:
    #             KNL05[i].append(str(knl_weight[i][j]))



    ###############################
    ######## knl00 weight #########
    ###############################

    for i in range(cnst.L2_MEMDEPTH):
        for j in range(cnst.L2_MEMWIDTH):

            if state == cnst.L2_U00_ST:
                KNL00[i].append(str(knl_weight[i][j]))
            elif state == cnst.L2_U01_ST:
                KNL01[i].append(str(knl_weight[i][j]))
            elif state == cnst.L2_U02_ST:
                KNL02[i].append(str(knl_weight[i][j]))
            elif state == cnst.L2_U03_ST:
                KNL03[i].append(str(knl_weight[i][j]))
            elif state == cnst.L2_U04_ST:
                KNL04[i].append(str(knl_weight[i][j]))
            elif state == cnst.L2_U05_ST:
                KNL05[i].append(str(knl_weight[i][j]))
            else:
                sys.exit()

            # state update
            if state != cnst.L2_KUPDATETIMING:
                state += 1
            else:
                state = 0

    #####################################
    #######    Fit to 256bit    #########
    #####################################

    for i in range(cnst.L2_MEMDEPTH):
        if i != (cnst.L2_MEMDEPTH-1):
            KNL00[i] = ''.join(KNL00[i])+'00000000000000000000000000000000000000000000000000000000,\n'
            KNL01[i] = ''.join(KNL01[i])+'00000000000000000000000000000000000000000000000000000000,\n'
            KNL02[i] = ''.join(KNL02[i])+'00000000000000000000000000000000000000000000000000000000,\n'
            KNL03[i] = ''.join(KNL03[i])+'00000000000000000000000000000000000000000000000000000000,\n'
            KNL04[i] = ''.join(KNL04[i])+'00000000000000000000000000000000000000000000000000000000,\n'
            KNL05[i] = ''.join(KNL05[i])+'00000000000000000000000000000000000000000000000000000000,\n'
            bias[i]  = ''.join(bias[i]) +'000000000000000000000000,\n'
        else:
            KNL00[i] = ''.join(KNL00[i])+'00000000000000000000000000000000000000000000000000000000;'
            KNL01[i] = ''.join(KNL01[i])+'00000000000000000000000000000000000000000000000000000000;'
            KNL02[i] = ''.join(KNL02[i])+'00000000000000000000000000000000000000000000000000000000;'
            KNL03[i] = ''.join(KNL03[i])+'00000000000000000000000000000000000000000000000000000000;'
            KNL04[i] = ''.join(KNL04[i])+'00000000000000000000000000000000000000000000000000000000;'
            KNL05[i] = ''.join(KNL05[i])+'00000000000000000000000000000000000000000000000000000000;'
            bias[i]  = ''.join(bias[i]) +'000000000000000000000000;'

    #####################################
    #######    write to file    #########
    #####################################

    knl_flatten = [[] for j in range(len(L2_FILES))]

    knl_flatten[0] = ''.join(KNL00)
    knl_flatten[1] = ''.join(KNL01)
    knl_flatten[2] = ''.join(KNL02)
    knl_flatten[3] = ''.join(KNL03)
    knl_flatten[4] = ''.join(KNL04)
    knl_flatten[5] = ''.join(KNL05)
    knl_flatten[6] = ''.join(bias)
    
    for i in range(len(L2_FILES)):
        fd = open(L2_FILEPATH + L2_FILES[i],'a')
        fd.writelines(str(knl_flatten[i]))
        fd.close()

    print('Layer 2 parameter saving completed')

def L2_fileinit():

    L2_FILES = [] # conv2 file list
    L2_FILEPATH = 'L2_PARAMS/'
    L2_FILENAME = 'CONV2_PARAMS0' # ソースネーム
    L2_BIASNAME = 'CONV2_BIAS.coe'
    string = ['memory_initialization_radix=2;','\n','memory_initialization_vector=','\n']

    # filelist create 

    for i in range(cnst.L2_FILENUM):
        if i != (cnst.L2_FILENUM-1):
            L2_FILES.append(L2_FILENAME + '%d' %i + '.coe')
        else:
            L2_FILES.append(L2_BIASNAME)

    # coe initialize

    for i in range(len(L2_FILES)):
        if os.path.isfile(L2_FILEPATH + L2_FILES[i]):
            os.remove(L2_FILEPATH + L2_FILES[i])

    for i in range(len(L2_FILES)):
        fd = open(L2_FILEPATH + L2_FILES[i],'a')
        fd.writelines(string)
        fd.close()

    return L2_FILES , L2_FILEPATH