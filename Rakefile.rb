require "./rakelib/rake_gcc"
include RakeGcc

task :default => "debug:build"

# Global Build tool configuration
# ===============================

$CPP = ENV['CPP'] || "g++"
$CC = ENV['CC'] || "gcc"
$RUBY = ENV['RUBY'] || "ruby20_mingw"
$RUBYDLL = ENV['RUBYDLL'] || "x64-msvcrt-ruby200.dll"
$RUBYDO = ENV['RUBYDO'] || "C:/projects/rubydo"
$WXWIDGETS = ENV['WXWIDGETS'] || "C:/projects/lib/wxWidgets-3.0.1"

ruby_lib_files = FileList.new "ruby20_mingw/lib/**/*"
ruby_lib_files.exclude "**/tcltk/**/*"
ruby_lib_files.exclude "**/gems/**/doc/**/*"
ruby_lib_files.exclude "**/*.a"
ruby_lib_files = ruby_lib_files.select { |f| File.file? f }
ruby_lib_files_dest = ruby_lib_files.map { |f| f.sub %r[ruby20_mingw/], "" }

ruby_dll = FileList.new "ruby20_mingw/bin/x64-msvcrt-ruby200.dll"
ruby_dll_dest = ["x64-msvcrt-ruby200.dll"]

# debug build target
# ==================

build_target :debug do
  compiler $CPP

  resources_rc = "resources.rc"
  resources_obj = "#{@build_target.name}/obj/resources.o"
  
  
  file resources_obj => resources_rc do
    sh "windres \"-I#{$WXWIDGETS}/include\" #{resources_rc} #{resources_obj}"
  end

  compile [resources_obj] do
    define :DEBUG
    
    flag "-std=c++11"
    
    search [
      "include",
      "#{$WXWIDGETS}/include",
      "#{$WXWIDGETS}/lib/gcc_lib/mswu",
      "#{$RUBY}/include/ruby-2.0.0",
      "#{$RUBY}/include/ruby-2.0.0/x64-mingw32",
      "#{$RUBYDO}/include"
    ]
    
    sources "src/**/*.{c,cpp}"
  end
  
  link do
    flags []
    
    search [
      "#{$WXWIDGETS}/lib/gcc_lib",
      "#{$RUBY}/lib",
      "#{$RUBYDO}/release"
    ]
    
    libs [
      "wxmsw30u",
      "wxscintilla",
      "wxexpat",
      "wxjpeg",
      "wxpng",
      "wxregexu",
      "wxtiff",
      "wxzlib",
      "rubydo",
      $RUBYDLL,
      "Comctl32",
      "Ole32",
      "Gdi32",
      "Shell32",
      "uuid",
      "OleAut32",
      "Comdlg32",
      "Winspool"
    ]
    
    object "#{@build_target.name}/obj/resources.o"
      
    artifact "SequelPad.exe"
  end
  
  copy ["scripts/**/*.*", "icons/**/*.*", "app.xrc", {ruby_lib_files => ruby_lib_files_dest}, {ruby_dll => ruby_dll_dest}]
end

# Release Build Target
# ====================

build_target :release, :debug do
  compile do
    undefine :DEBUG
    define :RELEASE
  end
  
  link do
    flag "-mwindows"
  end
end

# Dist Build Target
# =================

namespace :dist do
  directory "dist"
  
  task :clean do
    rm_rf "dist"
  end
  
  task :build => ["clean", "release:build", "dist"] do
    Dir["release/*"].each do |file|
      next if File.basename(file) == "obj"
      if File.directory?(file)
        cp_r file, "dist/#{File.basename file}"
      elsif File.file?(file)
        cp file, "dist/#{File.basename file}"
      end
    end
    
    Dir["dist/**/*.{o,exe,dll,so}"].each do |binary|
      sh "strip --strip-unneeded #{binary}"
    end
  end
end

# Clean Task
# ==========

desc "Clean all build targets"
task :clean do
  rm_rf "debug" if File.exists? 'debug'
  rm_rf "release" if File.exists? 'release'
  rm_rf "dist" if File.exists? 'dist'
end
