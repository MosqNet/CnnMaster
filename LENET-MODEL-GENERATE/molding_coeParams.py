#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys

import cnst # header file
import read_srcCoe # read data program
import L1_getParams 
import L2_getParams 
import L3_getParams
import L4_getParams
import L5_getParams

#import F2_getParams


def main():

    if os.path.isfile('Lenet5_weights.coe'):
        print('Coe file available')
    else:
        print('Coe file does not exist')
        print('Program forced termination')
        sys.exit()

    #########################################
    ######### read original data ############
    #########################################

    # return value of ori_L1data :  Parameter list of unmolded layer1
    # return value of ori_L2data :  Parameter list of unmolded layer2
    # return value of ori_ : Parameter list of unmolded Dense layer
 
    ori_L1data, ori_L2data, ori_L3data, ori_L4data, ori_L5data = read_srcCoe.read_data()

    #########################################
    #### Get parameters for  each layer #####
    #########################################

    L1_getParams.conv1_params_molding(ori_L1data)

    L2_getParams.conv2_params_molding(ori_L2data)

    L3_getParams.full1_params_molding(ori_L3data)

    L4_getParams.full02_params_molding(ori_L4data)

    L5_getParams.out_params_molding(ori_L5data)

    #########################################
    ########### Update COE log ##############
    #########################################



if __name__ == '__main__':
    main()