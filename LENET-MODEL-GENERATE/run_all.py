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

# include module
import LeNet5
import convert_to_coe
import Verific_LayerOUT

def main():

    # generate model
    LeNet5.main()
    # generate coe file
    convert_to_coe.main()
    # debug each layer result
    Verific_LayerOUT.main()

if __name__ == '__main__':
    main()