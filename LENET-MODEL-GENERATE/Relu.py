# -*- coding: utf-8 -*-
import numpy as np
import matplotlib.pyplot as plt

# xの値（-8～8で0.1刻みで配列生成）
x = np.arange(-8, 8, 0.1) #

#　ランプ関数
y = x * (x > 0)

# グラフの設定
plt.plot(x, y, lw=5) # プロット
plt.xlim(-8, 8)  # x軸の範囲
plt.ylim(-2, 8) # y軸の範囲
plt.grid() # グリッド描画
plt.show() # グラフを出力
