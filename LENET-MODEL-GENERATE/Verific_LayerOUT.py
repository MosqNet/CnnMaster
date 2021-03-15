#!/usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np
from PIL import Image
from PIL import ImageOps
from keras.models import model_from_json
from keras import backend as K

import pandas as pd
import matplotlib.pyplot as plt

def main():

    # LYAER_NUM = 

    # def main():

    # init()

    #############################################
    ############### Load Images #################
    #############################################

    # test datas
    X_test_img = np.load('MNIST_DATASET/kmnist-test-images.npz')['arr_0']

    img28x28 = X_test_img[0]
    print('Shape : ', img28x28.shape)
    print(img28x28)

    img28x28 = img28x28.reshape(1,28,28,1)
    print(img28x28)
    # image size
    print('Shape : ', img28x28.shape)

    # max and min
    print('Range : ', X_test_img.min(), X_test_img.max())

    # print(img28x28)
    # plt.imshow(img28x28)
    # plt.show()

    # print('Shape : ', X_test_img.shape)

    #images = X_test_img[0].shape(1, 28, 28, 1)

    #############################################
    ######### load model and weights ############
    #############################################

    json_string = open('lenet_model.json').read()
    model = model_from_json(json_string)

    model.load_weights('lenet_weights.hdf5')

    model.summary()

    # predict
    # ret = model.predict(X_test_img, 1, 1)
    # print(ret)

    # 配列の要素の表示する際の省略を避ける
    np.set_printoptions(threshold=np.inf)

    # 指数表記を禁止にして常に小数で表示
    np.set_printoptions(suppress=True)

    LAYER_NUM = 8

    FILES  = []
    FILEPATH = 'LENET_EACHLAYER_RESULT/'
    ELE_NUM = [784,196,100,25,400,120,84,10]
    DIM_NUM = [6,6,16,16,1,1,1,1]

    for i in range(LAYER_NUM):
        FILES.append('LAYER' + '%d' %i + '.txt')

    #############################################
    ############ Each layer result ##############
    #############################################
    for i in range(LAYER_NUM):
        each_layer_output = K.function([model.layers[0].input],[model.layers[i].output])
        layer_output = each_layer_output([img28x28,])
        print(layer_output[0].shape)
        RESULT = layer_output[0].reshape(ELE_NUM[i],DIM_NUM[i])
        np.savetxt(FILEPATH + FILES[i],RESULT,fmt='%.8f')

if __name__ == '__main__':
    main()