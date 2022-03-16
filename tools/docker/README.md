The Dockerfile in this directory sets up an Ubuntu Bionic image ready to build
a variety of Android branches (>= Lollipop). It's particulary useful to build
older branches that required 14.04 if you've upgraded to something newer.

First, build the image:
```
# Copy your host gitconfig, or create a stripped down version
$ cp ~/.gitconfig gitconfig
$ docker build --build-arg userid=$(id -u) --build-arg groupid=$(id -g) --build-arg username=$(id -un) -t android-build-bionic .
```

Then you can start up new instances with:
```
$ docker run -it --rm -v $ANDROID_BUILD_TOP:/src android-build-bionic
> cd /src; source build/envsetup.sh
> lunch aosp_arm-eng
> m -j50
```
