#!/usr/bin/env python
# -*- coding: utf-8 -*-

import random
import os
import sys
import math
import time, datetime
# import numpy as np

# Specifying the bit width
PAR_BIT_WIDTH = 8 # sign + bitwidth
BIT_WIDTH = 5 #
NEXT_PAR = 1 + BIT_WIDTH # next parameter

# bram memory width
BRAM_MEM_WIDTH = 1024

# Lenet parameters
LAY_1_PARM = 156   # cnv1 (karnel and bias parameter)
LAY_2_PARM = 2416  # cnv2 (karnel and bias parameter)
LAY_3_PARM = 48120 # fc1(dense1)
LAY_4_PARM = 10164 # fc2(dense2)
LAY_5_PARM = 850   # fc3(dense3)

# 各層の終端アドレス
LAY_1_LASTADD = LAY_1_PARM * PAR_BIT_WIDTH - PAR_BIT_WIDTH
LAY_2_LASTADD = LAY_2_PARM * PAR_BIT_WIDTH - PAR_BIT_WIDTH
LAY_3_LASTADD = LAY_3_PARM * PAR_BIT_WIDTH - PAR_BIT_WIDTH
LAY_4_LASTADD = LAY_4_PARM * PAR_BIT_WIDTH - PAR_BIT_WIDTH
LAY_5_LASTADD = LAY_5_PARM * PAR_BIT_WIDTH - PAR_BIT_WIDTH

# LAY_1_PADNUM = LAY_1_LASTADD % BRAM_MEM_WIDTH # LAY1_BORD_BIT > BRAM_MEM_WIDTH
LAY_1_PADNUM = BRAM_MEM_WIDTH % LAY_1_LASTADD # BRAM_MEM_WIDTH > LAY1_BORD_BIT
LAY_2_PADNUM = LAY_2_LASTADD % BRAM_MEM_WIDTH
LAY_3_PADNUM = LAY_3_LASTADD % BRAM_MEM_WIDTH
LAY_4_PADNUM = LAY_4_LASTADD % BRAM_MEM_WIDTH
LAY_5_PADNUM = LAY_5_LASTADD % BRAM_MEM_WIDTH

# 各層の先頭アドレス
LAY_1_FIRSTADD = 0
LAY_2_FIRSTADD = LAY_1_PARM * PAR_BIT_WIDTH + LAY_1_PADNUM
LAY_3_FIRSTADD = LAY_2_PARM * PAR_BIT_WIDTH + LAY_2_PADNUM
LAY_4_FIRSTADD = LAY_3_PARM * PAR_BIT_WIDTH + LAY_3_PADNUM
LAY_5_FIRSTADD = LAY_4_PARM * PAR_BIT_WIDTH + LAY_4_PADNUM

# プロセス番号
LAY_1_PRCS = 1
LAY_2_PRCS = 2
LAY_3_PRCS = 3
LAY_4_PRCS = 4
LAY_5_PRCS = 5
END_PRCS = 0

# read data
def read_data():

    with open('Lenet_pra.txt','r') as f:
        w_data = f.read()

    str_sum = '' # 文字結合用変数
    n_data = [] # 数値を格納する配列

    # 文字列を数値データに変換する
    for i in range(len(w_data)):
        if w_data[i] != ',' and w_data[i] != '\n':
            str_sum = str_sum + w_data[i] # 文字の結合
        else:
            n_data.append(float(str_sum)) # 文字列を数値データに変換して配列の要素に追加
            str_sum = '' # 初期化

    return n_data

def file_init():

    # テキストファイルの存在を確認する
    if os.path.isfile('Lenet5_weights.coe'):
        os.remove('Lenet5_weights.coe')# 前回保存した重みをクリア

    # f = open('Lenet5_weights.coe','a')
    # string = ['memory_initialization_radix=2;','\n','memory_initialization_vector=','\n']
    # f.writelines(string)
    # f.close()

    # テキストファイルの存在を確認する
    if os.path.isfile('Coe.log'):
        os.remove('Coe.log')# 前回保存した重みをクリア

    f = open('Coe.log','a')
    string = ['Update time : ']
    f.writelines(string)
    string = str(datetime.datetime.now()) + '\n'
    f.writelines(string)
    f.writelines('Layer 1 start address = 0 \n')
    f.close()

    return 0

#実数を2進数へ変換
def  hex_conv(rn):

    b_list = [] # バイナリーリスト

    # 符号判定
    if rn > 0:
        b_list.append(0) # プラス
    elif rn == 0.0:
        return bin_str([0]*PAR_BIT_WIDTH) # 何もせずに終了
    else:
        b_list.append(1) # マイナス

    rn = abs(rn)

    # 整数部の処理
    if rn != 1:
        b_list.append(0)
    else:
        b_list.append(1)


    # print('rn=',rn)

    # loop
    while rn != 1.0:
        # print('rn=',rn)
        rn = rn*2
        f,i = math.modf(rn) # f : 小数, i : 整数
        if i != 0:#整数部の判断
            b_list.append(1)
            if i+f != 1.0:
                rn = f # 小数部の値を代入
            else:
                rn = 1.0
        else:
            b_list.append(0)
    
    # sign + パラメータのビット幅になるまで0で埋める
    while len(b_list) != PAR_BIT_WIDTH:
        b_list.append(0)

    return bin_str(b_list) 

# 数値データを文字列に変換
def bin_str(b_list):

    b_str = '' # 初期化

    # 文字の結合
    for i in b_list:
        b_str += str(i) 
        
    return b_str # 2進数

def file_write(f,w_data,word_cnt):

    if len(w_data) == BRAM_MEM_WIDTH: # str_buffが1word分に達したら
        f.writelines(w_data) # ファイルへ書き込む
        if word_cnt == 484: # add 20201215
            f.write(';')
        else :
            f.write(',\n')
        w_data = []
        word_cnt += 1

    # elif len(w_data) >= BRAM_MEM_WIDTH: # 
    #     str_buff = [] # メモリ幅を超過したパラメータを格納
    #     w_len = len(w_data) - BRAM_MEM_WIDTH
    #     for j in range(w_len): # 
    #         str_buff += w_data[BRAM_MEM_WIDTH] # 余分な要素を保持
    #         del w_data[BRAM_MEM_WIDTH] # 余分な要素を削除
        
    #     f.writelines(w_data)
    #     f.write(',\n')
    #     w_data = str_buff
    #     # f.close()

    return w_data, word_cnt


# パラメータのポインタを更新
def update_ptr(w_data,parm_ptr,where_prcs,word_cnt):

    if (parm_ptr == LAY_1_LASTADD) & (where_prcs == LAY_1_PRCS): # 1層の終端アドレス
        w_data += bin_str([0]*(BRAM_MEM_WIDTH-len(w_data)))
        write_log('Layer 2 start address = ' + str(word_cnt * 128) + '\n')
        return w_data, 0, LAY_2_PRCS # 次の層の先頭ポインタを返す

    elif (parm_ptr == LAY_2_LASTADD) & (where_prcs == LAY_2_PRCS):
        w_data += bin_str([0]*(BRAM_MEM_WIDTH-len(w_data)))
        write_log('Layer 3 start address = ' + str(word_cnt * 128) + '\n')
        return w_data, 0, LAY_3_PRCS

    elif (parm_ptr == LAY_3_LASTADD) & (where_prcs == LAY_3_PRCS):
        w_data += bin_str([0]*(BRAM_MEM_WIDTH-len(w_data)))
        write_log('Layer 4 start address = ' + str(word_cnt * 128) + '\n')
        return w_data, 0, LAY_4_PRCS

    elif (parm_ptr == LAY_4_LASTADD) & (where_prcs == LAY_4_PRCS):
        w_data += bin_str([0]*(BRAM_MEM_WIDTH-len(w_data)))
        write_log('Layer 3 start address = ' + str(word_cnt * 128) + '\n')
        return w_data, 0, LAY_5_PRCS

    elif (parm_ptr == LAY_5_LASTADD) & (where_prcs == LAY_5_PRCS):
        w_data += bin_str([0]*(BRAM_MEM_WIDTH-len(w_data)))
        return w_data, 0, END_PRCS

    else:
        return w_data, parm_ptr + PAR_BIT_WIDTH, where_prcs # ポインタの更新(次のパラメータのポインタ)

def write_log(str):

    fd = open('Coe.log','a')
    fd.writelines(str)
    fd.close()

def main():

    n_data = [] # 数値を格納する配列
    w_data = [] # 
    word_cnt = 1

    parm_ptr = 0 # パラメータのポインタ
    where_prcs = LAY_1_PRCS # 

    n_data = read_data() # データ読み込み

    file_init() # coe and log file initialize

    f = open('Lenet5_weights.coe','a')

    for i in range(len(n_data)):

        w_data += hex_conv(n_data[i])
        w_data, parm_ptr, where_prcs = update_ptr(w_data,parm_ptr,where_prcs,word_cnt)
        w_data,word_cnt = file_write(f,w_data,word_cnt)
            
    f.close()

if __name__ == '__main__':
    main()