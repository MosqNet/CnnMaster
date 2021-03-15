#!/usr/bin/env python
# -*- coding: utf-8 -*-
# 32x32[px]の2値画像の送信 & 確率の受信

from socket import *
import numpy as np
import sys
import cv2
import time
import struct

if __name__ == "__main__":
    # txtから画像の取り込み
    f = open('Kuzushimoji-images.txt','r')
    # f = open('su.txt','r')
    img = f.readlines()
    with open('Kuzushimoji-labels.txt') as f:
        labels = f.readlines()
    imgsize = 1024
    #a = a.tostring()    # numpy行列からバイトデータに変換

    # socket
    HOST = ''
    PORT = 5000
    #ADDRESS = '127.0.0.1'   # 自分に
    ADDRESS = '172.31.210.160'   # 相手に

    sock = socket(AF_INET, SOCK_DGRAM)
    length = 90
    maxtime = 0
    mintime = 100
    true = 0
    false = 0
    total = 0
    # img_keep = [[]for j in range(10000)]
    
    #start = time.time()
    for i in range(10000):
        img_keep = bytearray()
        for j in range(imgsize):
            if img[i][j] == '0':
                img_keep.append(0x00)
            else :
                img_keep.append(0x01)
        # print(img_keep)
        # if i == 0:
        #     print('---start---')

        recvimg = bytes()
        start = time.time()
        sock.sendto(img_keep, (ADDRESS, PORT))
    
        buff, address = sock.recvfrom(length)
        end = time.time()
        recvimg = recvimg + buff

        a = struct.unpack('>BqBqBqBqBqBqBqBqBqBq',recvimg)
        maxid = -10
        # print(float(a[1]))
        for j in range(10):
            class_num = j
            prob = float(a[2*j+1]/(2**34))
            if maxid < prob:
                maxid = prob
                maxclass = class_num
            # print('Class : ' + str(class_num) + '  Prob : ' + str(prob))
        if int(labels[i]) == maxclass:
            true += 1
        else :
            false += 1
        
        # elapsed_time = end - start
        # print(elapsed_time)
        # if elapsed_time > maxtime :
        #     maxtime = elapsed_time
        # if elapsed_time < mintime :
        #     mintime = elapsed_time
        # total += elapsed_time
    
    # avg = total/10000.0
    # print('最大 : ' + str(maxtime))
    # print('最小 : ' + str(mintime))
    # print('平均 : ' + str(avg))
    print('True : ' + str(true) + '    False : ' + str(false))
    tf = true / 10000.0 * 100
    print('正答率 : ' + str(tf) + '%')
    sock.close()