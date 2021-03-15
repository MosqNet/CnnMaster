# UDP2Prob

Verilog-HDLで書かれた，ニューラルネットワーク回路を搭載したネットワークインタフェース．

## Description
画像データをUDPで受け取り，内部で構築されたLenet-5により推論を行い，結果を再びUDPで返す．

## Install
$git clone https://github.com/ThreeBridge/UDP2Prob.git  
Launch vivado  
$cd /PATH  
$source ./create_project.tcl  
or  
Tools > Run Tcl Script...  
Open "create_project.tcl"  
