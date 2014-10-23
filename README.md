# Gif2gfy

An FFmpeg frontend for converting gifs into standalone gfy files.

## What is a gfy?

[As coined by Gfycat:](https://gfycat.com/about#gfy)

    A gfy is a short, looped, soundless video moment that includes GIF as one
    of the available formats.

    The name stands for "GIF Format Yoker" (we pronounce it "jiffy"). And the
    purpose is to bridge the gap between gif and html5 video by providing
    both-- allowing users much faster delivery, and more playback options

## Goals of this project

One particular shortcoming of Gfycat's gfy format is not being able to be saved
to the desktop and shared as a single file, which is an advantage gif has
enjoyed since its inception in 1987.

Gif2gfy overcomes Gfycat's lack of desktop support by distilling the essence of
the gfy format, i.e., a looping video, and putting it into a self-contained
HTML5 container for easy saving.

The ultimate goal of this project is to become redundant with the advent of
proper replacements for the gif format. In the meantime, this project serves as
a stopgap solution so that users can benefit from much smaller and smoother
animations.

## Dependencies

    ffmpeg
    python2.7 or newer

#### Installing FFmpeg in Ubuntu 14.04 LTS

Current releases of Ubuntu don't have FFmpeg in the main repository, but adding
a PPA is a simple solution:

    sudo add-apt-repository -y ppa:mc3man/trusty-media
    sudo apt-get update
    sudo apt-get install -y ffmpeg

#### Using Linux static builds

Alternatively, static builds endorsed by the [FFmpeg project](https://www.ffmpeg.org/download.html#build-linux) can be found at the
link below:

    http://johnvansickle.com/ffmpeg/  

An example of using Gif2gfy with static 64-bit FFmpeg:

    mkdir ffmpeg
    wget http://johnvansickle.com/ffmpeg/releases/ffmpeg-2.4.2-64bit-static.tar.xz -O - | tar xfJ - -C ffmpeg --strip-components 1
    gif2gfy -p ffmpeg/ -i infile.gif
    
## Usage

####Getting information

    $ gif2gfy -h
    usage: gif2gfy [-h] -i INFILE [-c COLOR] [-o OUTFILE] [-p PATH] [-q QUALITY]
                   [-t TITLE] [-v]

    An FFmpeg frontend for converting gifs into standalone gfy files.

    optional arguments:
      -h, --help            show this help message and exit
      -i INFILE, --infile INFILE
                            Input file
      -c COLOR, --color COLOR
                            Choose background color of gfy; default is black
      -o OUTFILE, --outfile OUTFILE
                            Set filename of output; default is o.(mp4|webm).html
      -p PATH, --path PATH  Specify a custom directory to look for FFmpeg and
                            FFprobe
      -q QUALITY, --quality QUALITY
                            Set bitrate in MBs for gif-to-webm conversion; default
                            is 2
      -t TITLE, --title TITLE
                            Set title in HTML page; default is whatever -o is set
                            to
      -v, --video           Output pure video instead of HTML

