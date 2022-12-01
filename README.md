## What is this
TopDown Pose Estimation on iOS

- BBox: Yolov7-tiny
- Pose Estimation: ViTPose


## Install

```
$ git clone https://github.com/mbotsu/TopDownPoseExample.git
$ cd TopDownPoseExample/TopDownPoseExample
$ curl -OL https://github.com/mbotsu/KeypointDecoder/releases/download/0.0.1/vitpose-b256x192_fp16.mlmodel
$ curl -OL https://github.com/mbotsu/KeypointDecoder/releases/download/0.0.1/yolov7-tiny_fp16.mlmodel
```

## Example

![sample.png](sample.png)

## References

- ViTPose to CoreML
    - [mbotsu/20221128_convert.ipynb](https://gist.github.com/mbotsu/3de024c36582f21306e23473e9975841)
- Yolov7 to CoreML
    - [john-rocky/CoreML-Models](https://github.com/john-rocky/CoreML-Models#yolov7) 
        - [Yolov7 Google Colab](https://colab.research.google.com/drive/1QiTlFsN948Xt2e4WgqUB8DnGgwWwtVZS?usp=sharing)

