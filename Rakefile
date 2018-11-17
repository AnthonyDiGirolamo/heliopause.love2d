source_files = Rake::FileList["*.lua", "shine/*.lua"]

LOVEFILE = File.basename(File.expand_path('.')) + ".love"

system = "linux"
lovefile_dest = "./#{LOVEFILE}"

if ENV["PATH"] =~ /com.termux/
  system = "android"
  lovefile_dest = "~/storage/downloads/#{LOVEFILE}"
end

moonc = "~/.luarocks/bin/moonc"
moonc = "moonc" if !File.exists? moonc

task default: [LOVEFILE, :launch]
# file LOVEFILE => source_files do |t|
task LOVEFILE do |t|
  rm_f LOVEFILE
  sh "#{moonc} *.moon"
  sh "zip -r #{LOVEFILE} *"
  sh "cp #{LOVEFILE} #{lovefile_dest}"
end

task :launch do
  if system == "android"
    sh "am start -d 'file:///sdcard/Download/#{LOVEFILE}' --user 0 -t 'application/*' -n org.love2d.android/org.love2d.android.GameActivity"
  # -a android.intent.action.VIEW"
  else
    sh "love #{LOVEFILE}"
  end
end
