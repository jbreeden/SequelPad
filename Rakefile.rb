require "./rakelib/rake_gcc"
include RakeGcc

task :default => "debug:build"

# Global Build tool configuration
# ======================

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

# debug build target
# =================

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
      "#{$RUBYDO}/Release"
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
      
    artifact "app.exe"
  end
  
  copy ["scripts/**/*.rb", "icons/**/*.png", "app.xrc", {ruby_lib_files => ruby_lib_files_dest}]
end

build_target :release, :debug do
  compile do
    undefine :DEBUG
    define :RELEASE
  end
end

# Dist Configuration Tasks
# ==================

namespace :dist do
  directory "dist"
  
  task :clean do
    rm_rf "dist"
  end
  
  task :build => ["clean", "release:build", "dist"] do
    Dir["Release/*"].each do |file|
      next if File.basename(file) == "obj"
      if File.directory?(file)
        cp_r file, "Dist/#{File.basename file}"
      elsif File.file?(file)
        cp file, "Dist/#{File.basename file}"
      end
    end
    
    Dir["Dist/**/*.{o,exe,dll,so}"].each do |binary|
      sh "strip --strip-unneeded #{binary}"
    end
  end
end

