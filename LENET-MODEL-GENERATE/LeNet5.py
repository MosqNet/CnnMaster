#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import tensorflow as tf
import sys
import glob
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import keras
from math import modf
from keras import models
from keras.models import Sequential
from keras.layers import Dense, Flatten
from keras.layers import Conv2D, AveragePooling2D

def main():

    ############################################
    #######      データセットの取得     ########
    ############################################

    # データのロード(M)
    X_train_images = np.load('MNIST_DATASET/kmnist-train-imgs.npz')['arr_0']   # 学習用の画像データセット
    Y_train_labels = np.load('MNIST_DATASET/kmnist-train-labels.npz')['arr_0'] # 学習用のラベルデータセット
    # X_test_images = np.load('MNIST_DATASET/kmnist-test-images.npz')['arr_0']   # 検証用の画像データセット
    X_test_images = np.load('MNIST_DATASET/kmnist-test-imgs.npz')['arr_0']     # 検証用の画像データセット
    Y_test_labels = np.load('MNIST_DATASET/kmnist-test-labels.npz')['arr_0']   # 検証用のラベルデータセット

    # ラベルデータのロード
    label_map = pd.read_csv('http://codh.rois.ac.jp/kmnist/dataset/kmnist/kmnist_classmap.csv')['char']
    print(label_map)
    # 0    お
    # 1    き
    # 2    す
    # 3    つ
    # 4    な
    # 5    は
    # 6    ま
    # 7    や
    # 8    れ
    # 9    を
    # Name: char, dtype: object

    # 画像の数・サイズを確認
    print(X_train_images.shape, Y_train_labels.shape, X_test_images.shape, Y_test_labels.shape)
    # ((60000, 28, 28, 1), (60000, 10), (10000, 28, 28, 1), (10000, 10))

    # 値域を確認
    np.min(X_train_images), np.max(X_train_images), np.min(X_test_images), np.max(X_test_images)
    # (0, 255, 0, 255)

    # ラベルの偏りを確認
    print(np.unique(Y_train_labels, return_counts=True))
    # (array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], dtype=uint8), array([6000, 6000, 6000, 6000, 6000, 6000, 6000, 6000, 6000, 6000]))
    print(np.unique(Y_test_labels, return_counts=True))
    # (array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], dtype=uint8), array([1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]))

    # 学習データ36枚を表示
    plt.figure(figsize=(10,10))
    for i in range(36):
        plt.subplot(6, 6, i+1)
        plt.xticks([])
        plt.yticks([])
        plt.grid(False)
        plt.imshow(X_train_images[i])
        plt.xlabel(Y_train_labels[i])
    # 学習データの表示 適宜コメントアウト
    #plt.show()

    ############################################
    #########      データの前処理      #########
    ############################################

    # 正規化 : 画素を0~1の範囲に変換
    X_train = X_train_images.astype('float32') 
    X_test = X_test_images.astype('float32') # グレースケールで検証する場合はコメントアウト
    X_train /= 255
    X_test /= 255 # グレースケールで検証する場合はコメントアウト

    print(X_train.min(), X_train.max(), X_test.min(), X_test.max())
    # (0.0, 1.0, 0.0, 1.0)

    # チャネルの次元を加える
    X_train = X_train.reshape(X_train.shape + (1,))
    X_test = X_test.reshape(X_test.shape + (1,))

    print(X_train.shape, X_test.shape)
    # ((60000, 28, 28, 1), (10000, 28, 28, 1))

    # one-hotエンコーディング
    num_labels = label_map.size

    Y_train = keras.utils.to_categorical(Y_train_labels, num_labels)
    Y_test = keras.utils.to_categorical(Y_test_labels, num_labels)

    print(Y_train.shape, Y_test.shape)
    # ((60000, 10), (10000, 10))

    ############################################
    #########     モデルの作成      ############
    ############################################

    input_shape = (X_train.shape[1], X_train.shape[2], 1)

    model = Sequential()

    # #previous model
    # model.add(Conv2D(6, kernel_size=(5, 5), strides=(1, 1), padding='same', activation='tanh', input_shape=input_shape))
    # model.add(AveragePooling2D((2, 2), strides=(2, 2)))
    # model.add(Conv2D(16, kernel_size=(5, 5), strides=(1, 1), padding='valid', activation='tanh'))
    # model.add(AveragePooling2D((2, 2), strides=(2, 2)))
    # model.add(Flatten())
    # model.add(Dense(120, activation='tanh'))
    # model.add(Dense(84, activation='tanh'))
    # model.add(Dense(num_labels, activation='softmax'))

    # original
    # 畳み込み層とサンプリング層
    model.add(Conv2D(6, kernel_size=(5, 5), strides=(1, 1), padding='same', activation='relu', input_shape=input_shape))# 出力5×5×6
    model.add(AveragePooling2D((2, 2), strides=(2, 2)))
    model.add(Conv2D(16, kernel_size=(5, 5), strides=(1, 1), padding='valid', activation='relu'))
    model.add(AveragePooling2D((2, 2), strides=(2, 2)))
    # 1次元に変換
    model.add(Flatten())
    # 全結合層
    model.add(Dense(120, activation='relu'))
    model.add(Dense(84, activation='relu'))
    # 出力層
    model.add(Dense(num_labels, activation='softmax')) 
    

    model.compile(
        loss=keras.losses.categorical_crossentropy,
        optimizer=keras.optimizers.Adadelta(),
        metrics=['accuracy']
    )
    # モデルの概要を表示
    print(model.summary())

    # 小数点以下の桁数のを指定
    # np.set_printoptions(precision=8)

    # numpy配列に変換
    # np_weight = np.array(model.get_weights())

    # 型の表示
    # print("type=", type(np_weight))

    # 次元数を調べる
    # print("shape=", np_weight.shape)

    # 配列の最小, 最大値を表示
    # print(np_weight.min())
    # print(np_weight.max())


    # 入力層の重みをテキスト出力
    #print("[0]=", np_weight[0])


    ############################################
    ##########   モデルの学習と検証    #########
    ############################################
    epochs = 30
    batch_size = 1000 #データセットを1000ずつ分ける

    history = model.fit(x=X_train,y=Y_train, epochs=epochs, batch_size=batch_size, validation_data=(X_test, Y_test), verbose=1)

    # Train on 60000 samples, validate on 10000 samples
    # Epoch 1/30
    # 60000/60000 [==============================] - 25s 423us/step - loss: 1.0245 - acc: 0.6948 - val_loss: 1.0961 - val_acc: 0.6553
    # Epoch 2/30
    # 60000/60000 [==============================] - 26s 431us/step - loss: 0.5329 - acc: 0.8411 - val_loss: 0.7834 - val_acc: 0.7537
    # ...
    # Epoch 30/30
    # 60000/60000 [==============================] - 26s 431us/step - loss: 0.0280 - acc: 0.9933 - val_loss: 0.2718 - val_acc: 0.9298

    # 損失関数の値の推移
    # epoch_array = np.array(range(30))
    epoch_array = np.array(range(30))
    plt.plot(epoch_array, history.history['loss'], history.history['val_loss'])
    plt.legend(['loss', 'val_loss'])
    # plt.show()

    ############################################
    ##############  重みの量子化  ##############
    ############################################

    # numpy配列に変換
    np_weight = np.array(model.get_weights())
    #np_weight_int = np.array(model.get_weights())
    # list_weight = np_weight.tolist()

    # 型の表示
    print("type=", type(np_weight))
    # print("type=", type(list_weight))

    # 次元数を調べる
    print("shape=", np_weight.shape)
    print("size=", np_weight.size)

    # 配列の最小, 最大値を表示
    #print(np_weight.min())
    #print(np_weight.max())

    # np.packbits(np_weight)
    # np_weight = bin(np_weight)
    
    for i in range(10):
        np_weight[i] = np.round(np_weight[i] * 32.0) / 32.0
        # np_weight[i] = np.round(np_weight[i])
        # np_weight[i] = np.round(np_weight[i] * 64.0) / 64.0
        # np_weight[i] = np.round(np_weight[i] * 32.0) / 32.0
        # np_weight[i] = np.round(np_weight[i] * 4.0) / 4.0
        # np_weight[i] = np.round(np_weight[i] * 512.0) / 512.0
    # np_weight_int[0] = np.round(np_weight[0] * 256.0) / 256.0
    # np_weight_int[1] = np.round(np_weight[1] * 256.0) / 256.0

    ############################################
    ####### モデルの各層の重みをtxtに保存 ######
    ############################################

    # 配列の要素の表示する際の省略を避ける
    np.set_printoptions(threshold=np.inf)

    # 指数表記を禁止にして常に小数で表示
    np.set_printoptions(suppress=True)


    # テキストファイルの存在を確認する
    if os.path.isfile('Lenet_pra.txt'):
        os.remove('Lenet_pra.txt')# 前回保存した重みをクリア

    # 重みをテキストに保存
    with open('Lenet_pra.txt','ab') as f:
        for i in range(10):
            v_np_weight = np_weight[i].flatten()
            np.savetxt(f, v_np_weight[np.newaxis], fmt='%.8f', delimiter=',', newline='\n')

    # 量子化した重みを再セット
    model.set_weights(np_weight)

    # 学習済みのモデルを保存する
    json_string = model.to_json()
    open('lenet_model.json', 'w').write(json_string)

    # モデルの重みを保存する
    model.save_weights('lenet_weights.hdf5')



    # 再度
    # np_weight2 = np.array(model.get_weights())

    # # 型の表示
    # print("type=", type(np_weight2))
    # # print("type=", type(list_weight))

    # # 次元数を調べる
    # print("shape=", np_weight2.shape)
    # print("size=", np_weight2.size)

    # print(np_weight2[0])
    # print(np_weight2[1])
    # print(np_weight2[2])

    ############################################
    #######      モデルを使った予測      #######
    ############################################

    Y_predict = model.predict(X_test)

    # 誤ったテストデータを取得
    labels_predict = np.argmax(Y_predict, axis=1)
    labels_test = np.argmax(Y_test, axis=1)

    miss_indexes = np.where(labels_predict != labels_test)[0]
    print('Classification miss : ',len(miss_indexes)) # 間違ったデータの個数

    miss_predict = labels_predict[miss_indexes]
    miss_test = labels_test[miss_indexes]

    print(np.unique(miss_test, return_counts=True))
    # (array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
    #  array([ 62, 102, 134,  45,  83,  80,  35,  69,  50,  64]))

    # 誤った36枚を表示
    plt.figure(figsize=(10,10))
    for i in range(36):
        plt.subplot(6, 6, i+1)
        plt.xticks([])
        plt.yticks([])
        plt.grid(False)
        plt.imshow(X_test_images[miss_indexes[i]])
        plt.xlabel(f'{miss_test[i]} -> {miss_predict[i]}')
    #plt.show()

    print('Model_generation_complete!')

if __name__ == '__main__':
    main()
