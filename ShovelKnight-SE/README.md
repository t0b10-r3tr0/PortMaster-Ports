## Notes

Special thank you goes to [**João Henrique**](https://github.com/johnnyonflame) for creating the [original port](https://portmaster.games/detail.html?name=shovel.knight), which made this one possible. Also big thank you to the [**PortMaster**](https://portmaster.games) team and community. Finally, big thanks to the developers of the Shovel Knight series, [**Yacht Club Games**](https://www.yachtclubgames.com/).


## Controls

Controls can be mapped in-game. Use the D-PAD with the A and B buttons to configure in-game.


## Compile

```shell
# building 32-bit ARM code on aarch64 requires this armhf gcc cross-compiler toolchain
sudo apt install gcc-arm-linux-gnueabihf  
git clone https://github.com/ptitSeb/box86
cd box86
mkdir build; cd build; cmake .. -DARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo; make -j3
sudo make install
sudo systemctl restart systemd-binfmt
```