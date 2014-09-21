task :default => "debug:build"

# Global Build tool configuration
# ======================

$CPP = ENV['CPP'] || "g++"
$CC = ENV['CC'] || "gcc"
$RUBY = ENV['RUBY'] || "ruby20_mingw"
$RUBYDLL = ENV['RUBYDLL'] || "x64-msvcrt-ruby200.dll"
$RUBYDO = ENV['RUBYDO'] || "C:/projects/rubydo"
$WXWIDGETS = ENV['WXWIDGETS'] || "C:/projects/lib/wxWidgets-3.0.1"

# Global Compilation Options
# ====================

$COMPILE_FLAGS = [
  "-std=c++11"
]

$INCLUDE_PATHS = [
  "include",
  "#{$WXWIDGETS}/include",
  "#{$WXWIDGETS}/lib/gcc_lib/mswu",
  "#{$RUBY}/include/ruby-2.0.0",
  "#{$RUBY}/include/ruby-2.0.0/x64-mingw32",
  "#{$RUBYDO}/include"
]

def compile_options
  flags = $COMPILE_FLAGS.join(" ")
  search_paths = $INCLUDE_PATHS.map { |path| "-I#{path}" }.join(" ")
  "#{flags} #{search_paths}"
end

# Global Linking Options
# ================

$ARTIFACT = "app.exe"

$LINK_FLAGS = []

$LIBRARY_PATHS = [
  "#{$WXWIDGETS}/lib/gcc_lib",
  "#{$RUBY}/lib",
  "#{$RUBYDO}/Release"
]

$LIBRARIES = [
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

def link_options
  flags = $LINK_FLAGS.join(" ")
  search_paths = $LIBRARY_PATHS.map { |path| "-L#{path}" }.join(" ")
  "#{flags} #{search_paths}"
end

def link_libraries
  $LIBRARIES.map { |lib| "-l#{lib}" }.join(" ")
end

# Global File Lists
# ===========
  
$SOURCE_FILES = FileList["src/**/*.{c,cpp}"]

# Debug Configuration Tasks
# ===================

namespace :debug do
  # Customize compile options for this configuration
  task :compile_options do
    $COMPILE_FLAGS += %w[-DDEBUG]
    $INCLUDE_PATHS += []
  end
  
  # Customize link options for this configuration
  task :link_options do
    $LINK_FLAGS += []
    $LIBRARY_PATHS += []
    $LIBRARIES += []
  end
  
  directory "Debug"
  
  # Derive the object files & output directories from the source files
  obj_files = $SOURCE_FILES.pathmap("Debug/obj/%X.o")
  output_directories = obj_files.map { |obj| File.dirname obj }
    
  # Make a directory task for each output folder
  output_directories.each { |dir| directory dir }
  
  # Make a file task for each object file
  $SOURCE_FILES.zip(obj_files).each do |source, obj|
    file obj => source do
      sh "#{$CPP} #{compile_options} -c #{source} -o #{obj}"
    end
  end
  
  # Copy over misc files/folders
  file "Debug/app.xrc" => "app.xrc" do
    cp "app.xrc", "Debug/app.xrc"
  end
  
  file "Debug/#{$RUBYDLL}" => "#{$RUBY}/bin/#{$RUBYDLL}" do
    cp "#{$RUBY}/bin/#{$RUBYDLL}", "Debug/#{$RUBYDLL}"
  end
  
  directory "Debug/lib/ruby" do
    mkdir_p "Debug/lib"
    cp_r "#{$RUBY}/lib/ruby", "Debug/lib"
  end
  
  task "scripts" do
    cp_r "scripts", "Debug"
  end
  
  desc "Copy over support files"
  task :support_files => ["Debug", "Debug/app.xrc", "Debug/#{$RUBYDLL}", "Debug/lib/ruby", "scripts"]
  
  desc "Compile the resources file"
  task :resources do
	sh "windres \"-I#{$WXWIDGETS}/include\" resources.rc Debug/resources.o"
  end
  
  desc "Compile all sources"
  task :compile => ([:compile_options] + output_directories + obj_files)
  
  desc "Link the Debug artifact"
  task :link => %w[link_options compile] do
    sh "#{$CPP} #{link_options} Debug/resources.o #{obj_files.join(' ')} #{link_libraries} -o Debug/#{$ARTIFACT}"
  end
  
  desc "Build the Debug configuration"
  task :build => ["Debug", "resources", "compile", "link", "support_files"]
end

# Release Configuration Tasks
# =====================

namespace :release do
  # Customize compile options for this configuration
  task :compile_options do
    $COMPILE_FLAGS += %w[-DRELEASE]
    $INCLUDE_PATHS += []
  end
  
  # Customize link options for this configuration
  task :link_options do
    $LINK_FLAGS += %w[-mwindows]
    $LIBRARY_PATHS += []
    $LIBRARIES += []
  end
  
  # Derive the object files & output directories from the source files
  obj_files = $SOURCE_FILES.pathmap("Release/obj/%X.o")
  output_directories = obj_files.map { |obj| File.dirname obj }
    
  # Make a directory task for each output folder
  output_directories.each { |dir| directory dir }
  
  # Make a file task for each object file
  $SOURCE_FILES.zip(obj_files).each do |source, obj|
    file obj => source do
      sh "#{$CPP} #{compile_options} -c #{source} -o #{obj}"
    end
  end
  
  # Copy over misc files/folders
  file "Release/app.xrc" => "app.xrc" do
    cp "app.xrc", "Release/app.xrc"
  end
  
  file "Release/#{$RUBYDLL}" => "#{$RUBY}/bin/#{$RUBYDLL}" do
    cp "#{$RUBY}/bin/#{$RUBYDLL}", "Release/#{$RUBYDLL}"
  end
  
  directory "Release/lib/ruby" do
    mkdir_p "Release/lib"
    cp_r "#{$RUBY}/lib/ruby", "Release/lib"
  end
  
  desc "Compile all sources"
  task :compile => ([:compile_options] + output_directories + obj_files)
  
  desc "Link the Release artifact"
  task :link => %w[link_options compile] do
    sh "#{$CPP} #{link_options} #{obj_files.join(' ')} #{link_libraries} -o Release/#{$ARTIFACT}"
  end
  
  desc "Build the Release configuration"
  task :build => ["compile", "link", "Release/app.xrc", "Release/#{$RUBYDLL}", "Release/lib/ruby"]
end

# Dist Configuration Tasks
# ==================

namespace :dist do
 
  directory "Dist"
  task :build => ["release:build", "Dist"] do
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

# Clean task
# ========

task :clean do
  rm_rf "Debug" if File.exists? "Debug"
  rm_rf "Release" if File.exists? "Release"
  rm_rf "Dist" if File.exists? "Dist"
end
