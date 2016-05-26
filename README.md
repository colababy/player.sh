# shell_player
一个shell脚本，实现命令行音乐播放器.

## 说明
播放音乐使用了play命令，如果没有play，可以尝试mplay替换。
脚本实现了创建播放列表、播放、上一首、下一首、随机等功能。

## 使用方法
##### 开始播放
```/home/pi/player.sh start```
##### 下一首
```/home/pi/player.sh next```
##### 随机一首
```/home/pi/player.sh random```
##### 上一首
```/home/pi/player.sh prev```
##### 停止
```/home/pi/player.sh stop```

## 目的
配合[pi_weixin_server](https://github.com/wfd0807/pi_weixin_server.git)实现微信控制家庭媒体播放器.
