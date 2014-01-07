require 'formula'

class Ffmpeg07 < Formula
 homepage 'http://ffmpeg.org/'
 url 'http://ffmpeg.org/releases/ffmpeg-0.7.16.tar.bz2'
 sha1 '22b49fa8e4416bffc56f9cd6016499c60320b1f5'

 head 'git://git.videolan.org/ffmpeg.git'

 conflicts_with "ffmpeg",
    :because => "gagaga"

 depends_on 'pkg-config' => :build

 # manpages won't be built without texi2html
 depends_on 'texi2html' => :build if MacOS.version >= :mountain_lion
 depends_on 'yasm' => :build

 depends_on 'x264' unless build.include? 'without-x264'
 depends_on 'faac' unless build.include? 'without-faac'
 depends_on 'lame' unless build.include? 'without-lame'
 depends_on 'xvid' unless build.include? 'without-xvid'

 depends_on 'openjpeg' if build.include? 'with-openjpeg'

 def install
   args = ["--prefix=#{prefix}",
           "--enable-shared",
           "--enable-pic",
           "--cc=#{ENV.cc}",
           "--host-cflags=#{ENV.cflags}",
           "--host-ldflags=#{ENV.ldflags}",
           "--enable-libmp3lame"
          ]

   if build.include? 'with-openjpeg'
     args << '--enable-libopenjpeg'
     args << '--extra-cflags=' + %x[pkg-config --cflags libopenjpeg].chomp
   end

   # For 32-bit compilation under gcc 4.2, see:
   # http://trac.macports.org/ticket/20938#comment:22
   ENV.append_to_cflags "-mdynamic-no-pic" if MacOS.version == :leopard or Hardware.is_32_bit?

   system "./configure", *args

   if MacOS.prefer_64_bit?
     inreplace 'config.mak' do |s|
       shflags = s.get_make_var 'SHFLAGS'
       if shflags.gsub!(' -Wl,-read_only_relocs,suppress', '')
         s.change_make_var! 'SHFLAGS', shflags
       end
     end
   end

   system "make install"

   if build.include? 'with-tools'
     system "make alltools"
     bin.install Dir['tools/*'].select {|f| File.executable? f}
   end
 end

end

