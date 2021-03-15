#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import cnst

def read_data():

    with open('Lenet5_weights.coe','r') as f:
        all_data = f.read()

    keep_data = all_data.split(',\n') # カンマと改行を取り除いてリストで返す

    ori_L1data = [] # layer1のパラメータリスト
    ori_L2data = [] # layer2のパラメータリスト
    ori_L3data = [] # full1 layerのパラメータリスト
    ori_L4data = [] # full2  layerのパラメータリスト
    ori_L5data = [] # 出力層のパラメータリスト

    # 各laerのリストにパラメータを割り振る
    for i in range(len(keep_data)):
        if (i >= cnst.L1_ST) & (i <= cnst.L1_END):
            ori_L1data.append(keep_data[i])
        elif (i >= cnst.L2_ST) & (i <= cnst.L2_END):
            ori_L2data.append(keep_data[i])
        elif (i >= cnst.L3_ST) & (i <= cnst.L3_END):
            ori_L3data.append(keep_data[i])
        elif (i >= cnst.L4_ST) & (i<= cnst.L4_END):
            ori_L4data.append(keep_data[i])
        else :
            ori_L5data.append(keep_data[i])

    return ori_L1data, ori_L2data, ori_L3data, ori_L4data, ori_L5data # それぞれのレイヤーのパラメータを返す