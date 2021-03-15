#!/usr/bin/env python
# -*- coding: utf-8 -*-

#####################################
######### import libraries ##########
#####################################

import os
import sys
import cnst

def conv1_params_molding(ori_L1data):

    # ori_L1data format 
    # width 1024
    # depth 2

    # List length : 256 [ weight : 200 | bias : 8 | dammy : 48]
    # list depth  : 6
    u00_weight = [] # layer1 list 
    u01_weight = [] # layer2 list
    u02_weight = [] # layer3 list
    u03_weight = [] # layer4 list
    u04_weight = [] # layer5 list
    u05_weight = [] # layer6 list

    state = 0 # state register 
    knl_ptr = 0 # kernel pointer 

    # ori_L1data depth 
    for i in range(len(ori_L1data)):

        # knl_ptr initialize 
        knl_ptr = 0

        # Divide 1 word
        for j in range(cnst.PARAMNUM_PER_WORD): # 1word : 128 parameter

            # if Deepest part and last parameter  
            if (i == len(ori_L1data)-1) & (j == cnst.L1_LASTPARM):
                state = 0
                break

            #############################################
            ##############  state machine  ##############
            #############################################
            
            # kernel1 -> kernel2 -> kernel3 -> kernel4 -> kernel5 -> kernel6 -> kernel1

            if state == cnst.L1_U00_ST:
                u00_weight.append(str(ori_L1data[i][knl_ptr:knl_ptr+cnst.NEXT_PARM]))
            elif state == cnst.L1_U01_ST:
                u01_weight.append(str(ori_L1data[i][knl_ptr:knl_ptr+cnst.NEXT_PARM]))
            elif state == cnst.L1_U02_ST:
                u02_weight.append(str(ori_L1data[i][knl_ptr:knl_ptr+cnst.NEXT_PARM]))
            elif state == cnst.L1_U03_ST:
                u03_weight.append(str(ori_L1data[i][knl_ptr:knl_ptr+cnst.NEXT_PARM]))
            elif state == cnst.L1_U04_ST:
                u04_weight.append(str(ori_L1data[i][knl_ptr:knl_ptr+cnst.NEXT_PARM]))
            elif state == cnst.L1_U05_ST:
                u05_weight.append(str(ori_L1data[i][knl_ptr:knl_ptr+cnst.NEXT_PARM]))
            else:
                print('Layer1 error !')

            # state update
            if state != cnst.L1_UPDATETIMING:
                state += 1
            else:
                state = 0

            # pointer update
            knl_ptr += cnst.NEXT_PARM

    #####################################
    #######    Fit to 256bit    #########
    #####################################

    u00_weight.append('000000000000000000000000000000000000000000000000,\n')
    u01_weight.append('000000000000000000000000000000000000000000000000,\n')
    u02_weight.append('000000000000000000000000000000000000000000000000,\n')
    u03_weight.append('000000000000000000000000000000000000000000000000,\n')
    u04_weight.append('000000000000000000000000000000000000000000000000,\n')
    u05_weight.append('000000000000000000000000000000000000000000000000;')    
    
    #####################################
    ##  Combine elements of each layer ##
    #####################################
    u00_weight = ''.join(u00_weight)
    u01_weight = ''.join(u01_weight)
    u02_weight = ''.join(u02_weight)
    u03_weight = ''.join(u03_weight)
    u04_weight = ''.join(u04_weight)
    u05_weight = ''.join(u05_weight)

    #####################################
    #######    write to file    #########
    #####################################

    # Check if there is a previous parameter of CONV1
    if os.path.isfile('L1_PARAMS/CONV1_PARAMS.coe'):
        os.remove('L1_PARAMS/CONV1_PARAMS.coe')

    # Write according to coe format
    f = open('L1_PARAMS/CONV1_PARAMS.coe','a')
    string = ['memory_initialization_radix=2;','\n','memory_initialization_vector=','\n']
    f.writelines(string)

    # Write the weight of each layer
    f.writelines(u00_weight)
    f.writelines(u01_weight)
    f.writelines(u02_weight)
    f.writelines(u03_weight)
    f.writelines(u04_weight)
    f.writelines(u05_weight)

    f.close()

    print('Layer 1 parameter saving completed')